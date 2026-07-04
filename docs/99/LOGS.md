# Capturing 99 logs for GitHub issues

99's bug template wants three sections. Section 3 is JSON log lines from `require("99").view_logs()`.

## Step-by-step: get logs

1. **Log in** — `cursor-agent` on PATH, `agent login` if needed.

2. **Reproduce once** — run the failing op (`9s`, etc.) and wait until it finishes (success or failure).

3. **Open log picker** — `9l` or:
   ```vim
   :lua require("99").view_logs()
   ```

4. **Pick the request** — a list of past 99 runs appears. Select the one that matches your repro (usually the top / most recent). Confirm.

5. **Copy log lines** — a full-screen buffer opens with JSON lines, e.g.:
   ```json
   {"command":["cursor-agent",...]}
   {"stdout","data":"..."}
   {"retrieve_results","results":"..."}
   {"qf_list created","qf_list":[]}
   ```
   - Scroll (`j`/`k` or mouse) to find `command`, `stdout`, `retrieve_results`, and `qf_list created`.
   - Visually select and yank (`V`, `y`) or `:w! %` to save the buffer to a scratch file.
   - Paste into the issue under **## Logs**.

6. **Multiple runs** — if you picked the wrong request, run `9l` again and choose prev/next entry in the **picker list** (not the log buffer — that is one request's full log).

---

## What to include per issue

| Issue | Must-have log lines |
|-------|---------------------|
| Prompt delivery | `command` (shows multiline `<Context>` on `--print`), `stdout` (incomplete message) |
| Workspace / tmp | `command` (no `--workspace` on stock), `stdout` (agent wrote to `project\tmp\...`), `retrieve_results` with empty `results` |
| Response format | `retrieve_results` (citation markdown in `results`), `qf_list created` with `"qf_list":[]` |

Redact secrets if any appear. Paths like `C:\Dev\test\...` are fine.

---

## Per-issue repro shortcuts

### Prompt delivery (#180)

1. Checkout upstream `master` (or a branch without the prompt fix).
2. Launch Neovim with cwd **above** the project (e.g. `cd C:\Dev`, open `C:\Dev\test\test.js`).
3. `9s` → submit search prompt → agent may reply with empty context instead of searching.
4. `9l` → copy logs (`command` with multiline `--print`, incomplete `stdout`).

### Workspace / tmp (#181)

1. Same parent-cwd setup as above, with prompt fix applied but without workspace/tmp alignment.
2. `9s` → search prompt → wait for agent to complete.
3. Expect: stdout mentions `project\tmp\...`, but `retrieve_results` is empty (99 reads parent `tmp\...`).
4. `9l` → copy logs.

### Response format (citation → qfix)

1. Use fork `integration/cursor-agent` with prompt + workspace fixes; disable citation normalization if testing raw agent output.
2. `cd C:\Dev\test`, open `test.js`.
3. `9s` → search prompt → wait for agent.
4. **Hit:** `retrieve_results` has ` ```line:line:path ` citations and `qf_list` is empty.
5. **Miss:** agent writes qfix lines to TEMP_FILE directly (still worth the normalization PR as a guard).

---

## Filing on GitHub

1. [New issue](https://github.com/ThePrimeagen/99/issues/new) → pick **Base** template (or Bug Report).
2. Title from the `# Title` line at the top of each draft in `docs/99/issues/`.
3. Paste sections **1–3** from the draft; replace the `<!-- PASTE LOGS HERE -->` block with real logs.
4. Keep **Proposed fix** below section 3.
5. Labels: `bug` (template adds it); add `CursorAgentProvider` / `Windows` in title or body if no label exists.
