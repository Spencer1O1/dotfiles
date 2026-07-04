# Testing 99 fork + cursor-agent

## Current step: 3 — Response format

Lazy: `fix/cursor-agent-response` → `:Lazy sync` → restart Neovim.

Branch stacks on workspace (`1629aec`) + prompt (`242d8b5`).

---

## Step 1 — Prompt delivery ✓

[#185](https://github.com/ThePrimeagen/99/pull/185) · closes [#180](https://github.com/ThePrimeagen/99/issues/180)

---

## Step 2 — Workspace / tmp ✓

Stacked PR on `master` (depends #185) · closes [#181](https://github.com/ThePrimeagen/99/issues/181)

Repro: `cd C:\Dev`, open `C:\Dev\test\test.js`, `9s`.

- [x] `command` includes `--workspace`
- [x] Agent output path matches TEMP_FILE in prompt
- [x] Windows + Linux verified

---

## Step 3 — Response format ✓

Branch: `fix/cursor-agent-response` / `fix/cursor-agent-response-pr` (`121599a`)

Draft: [fixes/pr-cursor-agent-response-format.md](fixes/pr-cursor-agent-response-format.md) — ready to file

---

## After each verified fix

```bash
cd C:/Dev/99
git fetch upstream
git checkout -B fix/cursor-agent-<name>-pr upstream/master
git cherry-pick <commit-sha>
git push origin fix/cursor-agent-<name>-pr --force-with-lease
```

Or stack on `master` while earlier PRs are open (note `Depends on #N` in body).

Merge into `integration/cursor-agent` locally when you want all fixes together for daily use.
