# Title (GitHub)

`CursorAgentProvider: multiline prompt on --print argv fails on Windows`

**File at:** https://github.com/ThePrimeagen/99/issues/new (Base / bug template)  
**Labels:** `bug`  
**Link in body:** #154 (same class of bug for OpenCode)

**Status:** Ready to file — logs captured.

---

<!-- Copy everything below the line into the GitHub issue body -->

## 1. Steps to reproduce

1. Windows 11, Neovim 0.11.x, stock [ThePrimeagen/99](https://github.com/ThePrimeagen/99) `master` (no custom provider patches)
2. `cursor-agent` installed and logged in (`agent login`)
3. Setup:
   ```lua
   require("99").setup({
     provider = require("99").Providers.CursorAgentProvider,
     tmp_dir = "./tmp",
   })
   ```
4. Launch Neovim with cwd **above** the project (e.g. `cd C:\Dev`, then open `C:\Dev\test\test.js`). Repro is intermittent when cwd equals the project dir.
5. Run search: `9s` or `require("99").search()`
6. When prompted, enter: `Find me the main entrypoint of this program so I can look at it with my two eyes.`
7. Wait for the agent to respond

## 2. Relevant text / action taken

**Expected:** The agent receives 99's full search instructions (XML `<Context>`, TEMP_FILE rules, etc.) and runs the search task.

**Actual:** cursor-agent rejects the prompt as incomplete and does not run the task:

```text
It looks like your message came through with an empty `<Context>` block and no specific request.

What would you like help with? For example:
...
```

`retrieve_results` is empty; quickfix list is empty.

Stock `CursorAgentProvider._build_command` passes the entire multiline prompt as the `--print` argument (see `command` in logs). 99 already saves the full prompt to `tmp/99-XXXX-prompt` before `make_request` (`saved prompt to file` in logs). The provider should reference that file (e.g. single-line `@path`) instead of passing the blob on argv.

Same *class* of problem as #154 (OpenCode + multiline argv). cursor-agent has no `--file` flag; it supports `@path` in the prompt string.

Affects search, vibe, and visual (any op with a large XML prompt).

## 3. Logs

Captured via `require("99").view_logs()` (`9l`).

```
{"msg":"99 Request","id":1,"level":"DEBUG","method":"search"}
{"msg":"capture_prompt","success":true,"id":1,"level":"DEBUG","response":"Find me the main entrypoint of this program so I can look at it with my two eyes."}
{"msg":"search","Area":"search","id":1,"level":"DEBUG","with opts":"Find me the main entrypoint of this program so I can look at it with my two eyes."}
{"msg":"saved prompt to file","path":".\\tmp/99-4723-prompt","level":"DEBUG","id":1}
{"msg":"start","prompt":"<Context>\n<Output>\n/path/to/project/src/foo.js:24:8,3,Some notes here about some stuff, it can contain commas\n...(truncated in display; full XML in log buffer)...","level":"DEBUG","id":1}
{"msg":"make_request","Area":"CursorAgentProvider","tmp_file":".\\tmp/99-4723","level":"DEBUG","id":1}
{"msg":"make_request","Area":"CursorAgentProvider","id":1,"level":"DEBUG","command":["cursor-agent","--trust","--force","--model","composer-2.5-fast","--print","<Context>\n<Output>\n/path/to/project/src/foo.js:24:8,3,Some notes here about some stuff, it can contain commas\n...(full multiline XML prompt on argv)..."]}
{"msg":"stdout","Area":"CursorAgentProvider","id":1,"data":"It looks like your message came through with an empty `<Context>` block and no specific request.\n\nWhat would you like help with? For example:\n\n- Debugging or building something in your codebase\n- Explaining how part of a project works\n- Implementing a feature or fix\n- Setting up Convex, Cursor hooks, or another tool\n\nShare the goal and any relevant files or errors, and I’ll take it from there.\n","level":"DEBUG"}
{"msg":"stderr","Area":"CursorAgentProvider","level":"DEBUG","id":1}
{"msg":"stdout","Area":"CursorAgentProvider","level":"DEBUG","id":1}
{"msg":"retrieve_results","Area":"CursorAgentProvider","id":1,"level":"DEBUG","results":""}
{"msg":"qf_list created","Area":"search","id":1,"level":"DEBUG","qf_list":[]}
```

---

## Proposed fix

In `CursorAgentProvider._build_command` only:

1. Do not pass `query` on argv (it remains saved to `context.tmp_file .. "-prompt"`).
2. Resolve absolute path to that prompt file.
3. Pass a **single-line** `--print` string using cursor-agent's `@` syntax:

   ```text
   Read and follow every instruction in @C:/project/tmp/99-1234-prompt using your file tools, then complete the task exactly as specified in that file.
   ```

No new files, no user config — use infrastructure 99 already has.

## Is this a hack?

No. It is how this CLI should be invoked when argv cannot carry multiline prompts. OpenCode's proposed fix in #154 uses `--file` for the same reason. For cursor-agent, `@` + the saved prompt file is the equivalent provider fix.
