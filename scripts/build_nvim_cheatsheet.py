#!/usr/bin/env python3
"""Build a one-page landscape cheat sheet from the Neovim keymap sources."""

from __future__ import annotations

import html
import re
import shutil
from datetime import date
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


ROOT = Path(__file__).resolve().parents[1]
NVIM = ROOT / "nvim" / "lua" / "spencerls"
TMP_DIR = ROOT / "tmp" / "pdfs"
OUT_DIR = ROOT / "output" / "pdf"
TMP_PDF = TMP_DIR / "nvim-cheatsheet.pdf"
OUT_PDF = OUT_DIR / "nvim-cheatsheet.pdf"

NAVY = colors.HexColor("#1f2a44")
BLUE = colors.HexColor("#3d66a5")
PALE_BLUE = colors.HexColor("#e9eef8")
INK = colors.HexColor("#172033")
MUTED = colors.HexColor("#687386")
RULE = colors.HexColor("#c9d1df")
CODE_BG = colors.HexColor("#f7f8fb")
WHITE = colors.white

SKIP_FILES = {"keymap.lua", "bind.lua"}
LUA_STRING = re.compile(r"""(?:"((?:\\.|[^"\\])*)"|'((?:\\.|[^'\\])*)')""")
LEADER_GROUPS_RE = re.compile(
    r'(\w+)\s*=\s*\{\s*key\s*=\s*"(\w)"\s*,\s*name\s*=\s*"([^"]+)"',
)


def ascii_safe(text: str) -> str:
    replacements = {
        "\u2013": "-",
        "\u2014": "-",
        "\u2018": "'",
        "\u2019": "'",
        "\u201c": '"',
        "\u201d": '"',
        "\u2026": "...",
        "\u00a0": " ",
        "\u2192": "->",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text


def first_string(text: str) -> str | None:
    match = LUA_STRING.search(text)
    if not match:
        return None
    return (match.group(1) or match.group(2) or "").encode("utf-8").decode("unicode_escape")


def field(chunk: str, name: str) -> str | None:
    match = re.search(rf'{name}\s*=\s*"((?:\\.|[^"\\])*)"', chunk)
    return match.group(1) if match else None


def is_commented(text: str, pos: int) -> bool:
    line_start = text.rfind("\n", 0, pos) + 1
    return text[line_start:pos].lstrip().startswith("--")


def pretty_key(lhs: str) -> str:
    key = lhs.replace("<leader>", "<Leader>")
    key = re.sub(r"<C-S-([A-Za-z0-9-]+)>", r"Ctrl-Shift-\1", key)
    key = re.sub(r"<C-([A-Za-z0-9-]+)>", r"Ctrl-\1", key)
    key = re.sub(r"<M-([A-Za-z0-9-]+)>", r"Alt-\1", key)
    key = key.replace("<CR>", "Enter").replace("<BS>", "Backspace")
    key = key.replace("<Tab>", "Tab").replace("<S-Tab>", "S-Tab")
    return key


def pretty_mode_key(lhs: str, mode: str | None) -> str:
    key = pretty_key(lhs)
    if mode == "v":
        return f"v {key}"
    return key


def call_span(text: str, open_paren: int) -> str:
    i = open_paren + 1
    depth = 1
    quote = None
    escape = False
    while i < len(text) and depth:
        if quote:
            if escape:
                escape = False
            elif text[i] == "\\":
                escape = True
            elif text[i] == quote:
                quote = None
            i += 1
            continue
        if text.startswith("[[", i):
            end = text.find("]]", i + 2)
            i = end + 2 if end >= 0 else len(text)
            continue
        char = text[i]
        if char in "\"'":
            quote = char
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        i += 1
    return text[open_paren:i]


def parse_mode(chunk: str) -> str | None:
    single = re.search(r'mode\s*=\s*"(\w)"', chunk)
    if single:
        return single.group(1)
    table = re.search(r"mode\s*=\s*\{([^}]+)\}", chunk)
    if not table:
        return None
    modes = re.findall(r'"(\w)"', table.group(1))
    if len(modes) == 1:
        return modes[0]
    return None


def parse_leader_groups(text: str) -> dict[str, str]:
    return {name: key for name, key, _ in LEADER_GROUPS_RE.findall(text)}


def lua_files() -> list[Path]:
    return sorted(
        path
        for path in NVIM.rglob("*.lua")
        if path.name not in SKIP_FILES
    )


def each_call(text: str, name: str):
    needle = name + "("
    start = 0
    while True:
        pos = text.find(needle, start)
        if pos < 0:
            return
        start = pos + len(needle)
        if is_commented(text, pos):
            continue
        yield call_span(text, start - 1)


def parse_leader_maps(text: str, groups: dict[str, str]) -> list[tuple[str, str, str | None]]:
    found: list[tuple[str, str, str | None]] = []
    for chunk in each_call(text, "keymap.leader"):
        rest = chunk[1:].lstrip()
        if not rest.startswith(("'", '"')):
            continue
        suffix = first_string(rest)
        desc = field(chunk, "desc")
        if suffix is None or not desc:
            continue
        group = field(chunk, "group")
        prefix = groups.get(group, "") if group else ""
        found.append((f"<leader>{prefix}{suffix}", desc, parse_mode(chunk)))
    return found


def parse_set_maps(text: str) -> list[tuple[str, str, str | None]]:
    found: list[tuple[str, str, str | None]] = []
    for chunk in each_call(text, "keymap.set"):
        rest = chunk[1:].lstrip()
        if not rest.startswith(("'", '"')):
            continue
        lhs = first_string(rest)
        desc = field(chunk, "desc")
        if not lhs or not desc:
            continue
        found.append((lhs, desc, parse_mode(chunk)))
    for chunk in each_call(text, "map_99"):
        lhs = first_string(chunk)
        desc = field(chunk, "desc")
        if not lhs or not desc:
            continue
        found.append((lhs, desc, parse_mode(chunk)))
    return found


def parse_lazy_leader_keys(text: str) -> list[tuple[str, str, str | None]]:
    found: list[tuple[str, str, str | None]] = []
    for match in re.finditer(r'"(<leader>[^"]+)"', text):
        if is_commented(text, match.start()):
            continue
        chunk = text[match.start() : match.start() + 3000]
        desc = field(chunk, "desc")
        if desc:
            found.append((match.group(1), desc, None))
    return found


def parse_nav(path: Path, text: str) -> list[tuple[str, str, str | None]]:
    if path.name not in {"init.lua", "motions.lua"} or "/nav/" not in path.as_posix():
        return []
    found: list[tuple[str, str, str | None]] = []
    for letter, label in re.findall(
        r'list\.setup\(\s*"(\w)"\s*,\s*[^,]+,\s*"([^"]+)"',
        text,
    ):
        found.extend(nav_rows(letter, label))
        found.append((f"<leader>{letter.upper()}", f"Toggle {label} list", None))
    for letter, label in re.findall(
        r'(?<![A-Za-z0-9_])(\w)\s*=\s*\{\s*\n\s*"([^"]+)"',
        text,
    ):
        found.extend(nav_rows(letter, label))
    return found


def nav_rows(letter: str, label: str) -> list[tuple[str, str, str | None]]:
    cap = letter.upper()
    return [
        (f"]{letter}", f"Next {label}", None),
        (f"[{letter}", f"Previous {label}", None),
        (f"]{cap}", f"Last {label}", None),
        (f"[{cap}", f"First {label}", None),
    ]


def collect_maps() -> dict[str, str]:
    groups = parse_leader_groups((NVIM / "keymap.lua").read_text(encoding="utf-8"))
    maps: dict[str, str] = {}
    for path in lua_files():
        text = path.read_text(encoding="utf-8")
        rows = parse_leader_maps(text, groups)
        rows.extend(parse_set_maps(text))
        rows.extend(parse_lazy_leader_keys(text))
        rows.extend(parse_nav(path, text))
        for lhs, desc, mode in rows:
            maps[pretty_mode_key(lhs, mode)] = ascii_safe(desc)
    return maps


# Use order, not A-Z. A str pulls the parsed description; a pair is written as-is.
LAYOUT: list[list[tuple[str, list]]] = [
    [
        ("Everyday", [
            ("<Leader>", "Space"),
            "<Leader>w",
            "<Leader>q",
            "<Leader>qa",
            "<Leader>Q",
            "<Leader>d",
            "<Leader>r",
            "<Leader>u",
            "<Leader>p",
            "<Leader>X",
        ]),
        ("Yank and clipboard", [
            ("y  yy  Y", "Yank motion, line, or through line end"),
            ("<Leader>y", "Same yank to the system clipboard"),
            "<Leader>Y",
            "<Leader>Ctrl-y",
            "Ctrl-c",
            "Ctrl-v",
        ]),
        ("Editing", [
            ("Ctrl-d / Ctrl-u", "Half-page down / up, centered"),
            "J",
            ("v J / v K", "Move selection down / up"),
            ("n / N", "Next / previous search, centered"),
            "Q",
        ]),
        ("Files", [
            "<Leader>f",
            "<Leader>/",
            "<Leader>b",
            "<Leader>?",
            "<Leader>e",
            "<Leader>cd",
            ("Ctrl-j / Ctrl-k", "Next / previous Telescope match"),
            ("Enter (Oil)", "Open file or directory"),
            ("-  _", "Oil parent / open cwd"),
            ("g.  q", "Oil toggle hidden / close"),
            ("Ctrl-v/s/t", "Oil vsplit / split / tab"),
        ]),
    ],
    [
        ("Lists", [
            ("]x  [x", "Next / previous"),
            ("]X  [X", "Last / first"),
            ("x = i o p", "result, symbol, diagnostic"),
            ("x = t g d", "todo, git hunk, diff change"),
            "<Leader>i",
            "<Leader>o",
            "<Leader>I",
            "<Leader>O",
            "<Leader>P",
            ("Enter (qf)", "Jump and close list"),
        ]),
        ("Language", [
            "<Leader>lf",
            "<Leader>lr",
            "<Leader>la",
            "<Leader>K",
            "gd",
            "gD",
            "gi",
            "K",
        ]),
        ("Git", [
            "<Leader>gg",
            "<Leader>gf",
            "<Leader>gs",
            "<Leader>gS",
            "<Leader>gr",
            "<Leader>gR",
            "<Leader>gp",
            "<Leader>gb",
            "<Leader>gd",
            "<Leader>gD",
            "<Leader>gt",
        ]),
        ("Harpoon", [
            "<Leader>ha",
            "<Leader>h",
            ("Ctrl-h/j/k/l", "Harpoon files 1-4"),
        ]),
    ],
    [
        ("Insert", [
            ("() [] {}", "Openers pair; closers step over"),
            ("'  \"", "Quotes pair when it makes sense"),
            (">", "Close HTML/JSX tag"),
            ("Enter", "Expand empty pair or tag"),
            ("Backspace", "Delete empty pair/tag; collapse multiline"),
        ]),
        ("Completion", [
            ("Ctrl-n", "Open menu or next item"),
            ("Ctrl-p", "Previous item (opens menu if closed)"),
            ("Esc", "Dismiss menu; else leave insert"),
            ("Ctrl-f", "Confirm item, else accept suggestion"),
            ("Ctrl-Shift-f", "Accept next word of suggestion"),
        ]),
        ("99", [
            "9s",
            "9v",
            "v 9v",
            "9o",
            "9x",
            "9l",
            "9i",
            "9w",
            "9W",
            "9m",
            "9p",
        ]),
        ("Focus", [
            "<Leader>zz",
            "<Leader>zZ",
        ]),
    ],
]


def make_styles() -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "Title", parent=base["Title"], fontName="Helvetica-Bold", fontSize=20,
            leading=23, textColor=NAVY, spaceAfter=2, alignment=TA_LEFT,
        ),
        "subtitle": ParagraphStyle(
            "Subtitle", parent=base["Normal"], fontName="Helvetica", fontSize=8.5,
            leading=11, textColor=MUTED, spaceAfter=8,
        ),
        "cheat_section": ParagraphStyle(
            "CheatSection", parent=base["Heading3"], fontName="Helvetica-Bold",
            fontSize=9, leading=10.5, textColor=WHITE,
        ),
        "cheat_key": ParagraphStyle(
            "CheatKey", parent=base["Code"], fontName="Courier-Bold", fontSize=6.7,
            leading=8, textColor=NAVY, leftIndent=0, rightIndent=0, firstLineIndent=0,
        ),
        "cheat_desc": ParagraphStyle(
            "CheatDesc", parent=base["Normal"], fontName="Helvetica", fontSize=6.7,
            leading=8, textColor=INK,
        ),
    }


def page_chrome(canvas, doc) -> None:
    width, height = landscape(letter)
    canvas.saveState()
    canvas.setStrokeColor(RULE)
    canvas.setLineWidth(0.5)
    canvas.line(doc.leftMargin, height - 24, width - doc.rightMargin, height - 24)
    canvas.setFont("Helvetica", 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(doc.leftMargin, height - 18, "NEOVIM DOTFILES - KEYBINDING CHEAT SHEET")
    canvas.drawRightString(width - doc.rightMargin, 16, f"Page {doc.page}")
    canvas.drawString(
        doc.leftMargin,
        16,
        f"Generated {date.today().isoformat()} from nvim/lua/spencerls keymap sources.",
    )
    canvas.restoreState()


def cheat_category(title: str, entries: list[tuple[str, str]], styles: dict[str, ParagraphStyle]) -> list:
    heading = Table(
        [[Paragraph(title, styles["cheat_section"])]],
        colWidths=[3.02 * inch],
        style=TableStyle([
            ("BACKGROUND", (0, 0), (-1, -1), NAVY),
            ("LEFTPADDING", (0, 0), (-1, -1), 5),
            ("RIGHTPADDING", (0, 0), (-1, -1), 5),
            ("TOPPADDING", (0, 0), (-1, -1), 3),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
        ]),
    )
    rows = [
        [
            Paragraph(html.escape(ascii_safe(key)), styles["cheat_key"]),
            Paragraph(html.escape(ascii_safe(desc)), styles["cheat_desc"]),
        ]
        for key, desc in entries
    ]
    body = Table(rows, colWidths=[1.16 * inch, 1.86 * inch])
    body.setStyle(TableStyle([
        ("ROWBACKGROUNDS", (0, 0), (-1, -1), [WHITE, CODE_BG]),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LINEBELOW", (0, 0), (-1, -1), 0.25, RULE),
        ("LEFTPADDING", (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 1.5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 1.5),
    ]))
    return [heading, body, Spacer(1, 7)]


def resolve_section(items: list, maps: dict[str, str]) -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    for item in items:
        if isinstance(item, tuple):
            rows.append(item)
            continue
        desc = maps.get(item)
        if desc:
            rows.append((item, desc))
    return rows


def build_pdf() -> None:
    TMP_DIR.mkdir(parents=True, exist_ok=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    styles = make_styles()
    maps = collect_maps()

    rendered_columns = []
    for column in LAYOUT:
        flowables = []
        for title, items in column:
            entries = resolve_section(items, maps)
            if entries:
                flowables.extend(cheat_category(title, entries, styles))
        rendered_columns.append(flowables)

    doc = SimpleDocTemplate(
        str(TMP_PDF),
        pagesize=landscape(letter),
        leftMargin=0.48 * inch,
        rightMargin=0.48 * inch,
        topMargin=0.44 * inch,
        bottomMargin=0.38 * inch,
        title="Neovim dotfiles - keybinding cheat sheet",
        author="dotfiles",
    )
    story = [
        Paragraph("Neovim keybinding cheat sheet", styles["title"]),
        Spacer(1, 8),
        Table(
            [rendered_columns],
            colWidths=[3.18 * inch, 3.18 * inch, 3.18 * inch],
            style=TableStyle([
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 3),
                ("RIGHTPADDING", (0, 0), (-1, -1), 3),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
            ]),
        ),
    ]
    doc.build(story, onFirstPage=page_chrome, onLaterPages=page_chrome)
    shutil.copyfile(TMP_PDF, OUT_PDF)
    print(OUT_PDF)


if __name__ == "__main__":
    build_pdf()
