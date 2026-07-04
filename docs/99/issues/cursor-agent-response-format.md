# Title (GitHub)

`CursorAgentProvider: markdown citations are not parsed as qfix lines for search/vibe`

**File at:** https://github.com/ThePrimeagen/99/issues/new (Base / bug template)  
**Labels:** `bug`  
**Link in body:** #135, #138 (stdout → TEMP_FILE)

---

<!-- Copy everything below the line into the GitHub issue body -->

## 1. Steps to reproduce

1. Windows 11, Neovim 0.11.x, 99 with `CursorAgentProvider` and stdout capture ([#138](https://github.com/ThePrimeagen/99/pull/138) or equivalent) so agent output reaches TEMP_FILE
2. Prompt delivery working (agent receives full search instructions — may require prompt fix or local patch; note below if so)
3. Setup:
   ```lua
   require("99").setup({
     provider = require("99").Providers.CursorAgentProvider,
     tmp_dir = "./tmp",
   })
   ```
4. Open a project with a known entrypoint (e.g. `test.js` with `function main()`)
5. Run search (`9s`), prompt: `Find the main entrypoint`
6. Agent completes and returns markdown citations in the response
7. Quickfix / Trouble stays empty

## 2. Relevant text / action taken

**Expected:** Quickfix shows file locations from the search.

**Actual:** Agent response uses Cursor markdown citations, not 99's qfix format:

````markdown
```6:11:C:\Dev\test\test.js
function main() { ... }
```
````

99 expects lines like:

```text
absolute_path:lnum:cnum,line_count,notes
```

`QFixHelpers.create_qfix_entries` does not parse citation blocks → `"qf_list":[]` even when the agent found the right code.

**Note for repro:** If prompt delivery (#154-class) or workspace alignment is broken on stock `master`, say so here — e.g. "Reproduced on branch with #138 merged and prompt delivered via `@` file." The citation parsing gap remains in upstream `CursorAgentProvider`.

Related: #135 (results on stdout; #138 addresses capture for this provider).

## 3. Logs

Captured via `require("99").view_logs()` after the repro above (see [LOGS.md](../LOGS.md)).

<!-- PASTE LOGS HERE — include at least:
  - {"retrieve_results","results":"```6:11:C:\\..."}
  - {"qf_list created","qf_list":[]}
-->

```
(paste JSON log lines here)
```

---

## Proposed fix

In `CursorAgentProvider:_retrieve_response` (after reading TEMP_FILE / BaseProvider path):

1. For `search` and `vibe`: pass text through a `normalize_qfix_response` helper.
2. Keep existing qfix lines unchanged; parse ` ```startLine:endLine:path ` blocks into qfix lines.
3. For visual/tutorial: return raw text without normalization.

Do **not** duplicate #138's stdout capture — build on `_stdout_as_response()` + BaseProvider `make_request`.

## Is this a hack?

Citation normalization is adapter work. cursor-agent does not emit 99's qfix format. Converting citations in `CursorAgentProvider` is the correct integration point unless cursor-agent gains structured output.
