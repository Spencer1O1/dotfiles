# Title (GitHub)

`CursorAgentProvider: --workspace and cwd must align with tmp_dir paths`

**File at:** https://github.com/ThePrimeagen/99/issues/new (Base / bug template)  
**Labels:** `bug`  
**Link in body:** #109, #180  
**Status:** Ready to file — split-evidence logs (E2E blocked by #180)

---

<!-- Copy everything below the line into the GitHub issue body -->

## 1. Steps to reproduce

1. Windows 11, Neovim 0.11.x, stock [ThePrimeagen/99](https://github.com/ThePrimeagen/99) `master`
2. `cursor-agent` installed and logged in
3. Setup:
   ```lua
   require("99").setup({
     provider = require("99").Providers.CursorAgentProvider,
     tmp_dir = "./tmp",
   })
   ```
4. **Case A (works):** launch Neovim with cwd = project dir (`C:\Dev\test`), open `test.js`, run search (`9s`).
5. **Case B (broken):** launch Neovim with cwd **above** the project (`C:\Dev`), open `C:\Dev\test\test.js`, run search (`9s`).

Pure stock repro for Case B is blocked by #180 (prompt never reaches the agent from parent cwd). Logs below use Case A plus Case B path metadata to show the split.

## 2. Relevant text / action taken

**Expected:** 99 and cursor-agent agree on where `tmp/99-XXXX` and `tmp/99-XXXX-prompt` live — whether Neovim cwd equals the project root or not.

**Actual (Case A — cwd matches project):** Agent completes and writes under the project tmp; 99 reads the same path. Search works (aside from unrelated Windows qfix parsing #155).

**Actual (Case B — cwd above project):** 99 resolves `tmp_dir = "./tmp"` relative to **Neovim cwd** (`C:\Dev\tmp\...`). cursor-agent has no `--workspace` flag and `vim.system` has no `cwd` override. When the agent runs against the subproject, it writes TEMP_FILE under the **project** tree (`C:\Dev\test\tmp\...` per Case A behavior). 99 then reads `C:\Dev\tmp\...` → empty `retrieve_results` / "unable to retrieve response from temp file".

Example stdout when paths align (Case A):

```text
Done. Output written to `C:\Dev\test\tmp\99-7428`.
```

99 `tmp_file` / prompt paths when cwd is the parent (Case B metadata from #180 repro):

```text
.\tmp/99-4723-prompt   → C:\Dev\tmp\99-4723-prompt
.\tmp/99-4723          → C:\Dev\tmp\99-4723
```

Stock `CursorAgentProvider._build_command` does not pass `--workspace`. Without an explicit project root, cursor-agent also searches the wrong trees under `C:\Dev\` (e.g. other repos siblings of the intended project).

Related: #109 (TEMP_FILE / tmp in project cwd), #180 (prompt delivery blocks full Case B repro on stock master).

## 3. Logs

Captured via `require("99").view_logs()` (`9l`). Full lines in `cursor-agent-workspace-tmp.log` (dotfiles).

### Case A — cwd `C:\Dev\test`, stock master (paths align; search retrieves)

```
{"msg":"make_request","Area":"CursorAgentProvider","tmp_file":".\\tmp/99-7428","level":"DEBUG","id":2}
{"msg":"make_request","Area":"CursorAgentProvider","id":2,"level":"DEBUG","command":["cursor-agent","--trust","--force","--model","composer-2.5-fast","--print","<Context>\n...(multiline prompt)..."]}
{"msg":"stdout","Area":"CursorAgentProvider","id":2,"data":"Done. Output written to `C:\\Dev\\test\\tmp\\99-7428`.\n","level":"DEBUG"}
{"msg":"retrieve_results","Area":"CursorAgentProvider","id":2,"level":"DEBUG","results":"C:\\Dev\\test\\test.js:51:1,1,Top-level main invocation is the script entrypoint that starts program execution\nC:\\Dev\\test\\test.js:6:1,6,Main function defines the primary startup routine invoked at entry"}
```

Note: no `--workspace` in `command`; agent still writes to **`C:\Dev\test\tmp`** when cwd equals the project.

### Case B — cwd `C:\Dev`, stock master (#180 — 99 tmp paths under parent cwd)

From #180 repro (prompt fails before agent runs; shows where **99** reads/writes):

```
{"msg":"saved prompt to file","path":".\\tmp/99-4723-prompt","level":"DEBUG","id":1}
{"msg":"make_request","Area":"CursorAgentProvider","tmp_file":".\\tmp/99-4723","level":"DEBUG","id":1}
{"msg":"retrieve_results","Area":"CursorAgentProvider","id":1,"level":"DEBUG","results":""}
```

With cwd `C:\Dev`, `.\tmp/...` → `C:\Dev\tmp\...`. When the agent completes against `C:\Dev\test` (Case A), it writes `C:\Dev\test\tmp\...` instead → mismatch.

### Supplemental — cwd `C:\Dev`, prompt `@file` only (no `--workspace`; agent searches wrong projects)

Prompt delivery workaround only (`@C:/Dev/tmp/99-3900-prompt`). Paths align at `C:\Dev\tmp` so retrieve succeeds, but agent searches unrelated dirs under `C:\Dev\`:

```
{"msg":"make_request","command":["cursor-agent","--trust","--force","--model","composer-2.5-fast","--print","Read and follow every instruction in @C:/Dev/tmp/99-3900-prompt using your file tools, then complete the task exactly as specified in that file."],"level":"DEBUG","Area":"CursorAgentProvider","id":1}
{"msg":"stdout","Area":"CursorAgentProvider","id":1,"data":"Task complete — results written to `C:\\Dev\\tmp\\99-3900`.\n","level":"DEBUG"}
{"msg":"retrieve_results","Area":"CursorAgentProvider","id":1,"level":"DEBUG","results":"C:/Dev/tmp/capacitor-nfc-scanner/src/index.ts:1:1,5,..."}
```

Still no `--workspace`; results are not from the intended subproject.

---

## Proposed fix

In `CursorAgentProvider`:

1. Pass `--workspace <path>` to `cursor-agent` (project root — at minimum `vim.fn.getcwd()`, ideally git root / buffer project).
2. Set `cwd` on `vim.system` to the same path.
3. In `_retrieve_response`, resolve `context.tmp_file` under that workspace before falling back to Neovim cwd.

Optional follow-up for all providers: document or auto-resolve `tmp_dir` under project root (#109).

## Is this a hack?

No. The provider and cursor-agent must share one project root for TEMP_FILE paths. Missing `--workspace`/cwd is an incomplete adapter, not a user configuration problem.
