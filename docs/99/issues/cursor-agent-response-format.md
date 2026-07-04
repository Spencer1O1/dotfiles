# Title (GitHub)

`CursorAgentProvider: agent output is not parsed as qfix lines for search/vibe`

**File at:** https://github.com/ThePrimeagen/99/issues/new (Base / bug template)  
**Labels:** `bug`  
**Link in body:** #180, #181, #135  
**Status:** Ready to file

---

<!-- Copy everything below the line into the GitHub issue body -->

## 1. Steps to reproduce

1. Windows 11 or Linux, Neovim 0.11.x, `cursor-agent` installed and logged in
2. 99 with `CursorAgentProvider` and prompt delivery + workspace alignment working ([#180](https://github.com/ThePrimeagen/99/issues/180)-class prompt `@file` fix and [#181](https://github.com/ThePrimeagen/99/issues/181)-class `--workspace` / tmp path fix — required so the agent actually completes search and writes TEMP_FILE)
3. Setup:
   ```lua
   require("99").setup({
     provider = require("99").Providers.CursorAgentProvider,
     tmp_dir = "./tmp",
   })
   ```
4. Open a project with a known entrypoint (e.g. `test.js` with `function main()`)
5. Run search (`9s`), prompt: `Find the main entrypoint`
6. Agent completes (stdout often status-only or citation markdown)
7. Quickfix / Trouble stays **empty** on stock `CursorAgentProvider`

**Note:** Pure stock `master` may be blocked earlier by #180 / #181. The parsing gap below is independent — it appears once the agent runs and returns results.

## 2. Relevant text / action taken

**Expected:** Quickfix shows file locations from the search.

**Actual:** Agent finds the code but 99 does not populate `qf_list`. Common cases:

- **Status-only stdout** — agent writes qfix lines to TEMP_FILE but 99 reads conversational stdout or status text instead of parseable locations
- **Citation markdown** — agent returns `` `startLine:endLine:path` `` fenced blocks instead of 99 qfix lines

99 expects lines like:

```text
absolute_path:lnum:cnum,line_count,notes
```

`QFixHelpers.create_qfix_entries` does not parse citation blocks or status strings → `"qf_list":[]` even when the agent found the right code.

Related: #135 (results on stdout), #180 (prompt), #181 (workspace/tmp).

## 3. Logs

### Linux (before fix — workspace branch, prompt + `--workspace` working)

Agent completes; `qf_list` empty:

```
{"command":["cursor-agent","--workspace","/home",...]}
{"msg":"stdout","data":"Task complete. Results are in `/home/spencerls/tmp/99-5795`.\n"}
{"msg":"qf_list created","qf_list":[]}
```

Earlier run (prompt-only branch, no `--workspace`):

```
{"msg":"retrieve_results","results":"Done. Results written to `/home/spencerls/tmp/99-5294`."}
{"msg":"qf_list created","qf_list":[]}
```

### Windows (before fix — prompt + workspace working)

```
{"command":["cursor-agent","--workspace","C:\\Dev",...]}
{"msg":"stdout","data":"Task complete. Results are in `C:\\Dev\\test\\tmp\\99-1644`.\n"}
{"msg":"qf_list created","qf_list":[]}
```

### After fix (same repro, `normalize_qfix_response` in `_retrieve_response`)

Linux — `qf_list` populated:

```
{"msg":"qf_list created","qf_list":[
  {"filename":"/home/spencerls/test.js","lnum":2,"col":1,"text":"Main entry function..."},
  {"filename":"/home/spencerls/test.js","lnum":39,"col":1,"text":"Top-level main() invocation..."}
]}
```

Windows — `qf_list` populated (filename `"C"` is unrelated [#178](https://github.com/ThePrimeagen/99/pull/178) drive-letter parsing):

```
{"msg":"stdout","data":"(citation fence with C:\\Dev\\test\\test.js:51:1,1,...)"}
{"msg":"qf_list created","qf_list":[
  {"filename":"C","lnum":1,"col":1,"text":"Script entry point that invokes main to start program execution"}
]}
```

## Proposed fix

In `CursorAgentProvider:_retrieve_response` (after reading TEMP_FILE via workspace-aware paths):

1. For `search` and `vibe`: pass text through `normalize_qfix_response` — keep existing qfix lines; parse citation fences into qfix lines.
2. For `visual` / `tutorial`: return raw text (no normalization).

## Is this a hack?

Citation normalization is adapter work. cursor-agent does not emit 99's qfix format. Converting citations in `CursorAgentProvider` is the correct integration point unless cursor-agent gains structured output.
