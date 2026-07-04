# fix(providers): normalize CursorAgent citations to qfix lines

## Summary

cursor-agent often writes citation blocks (`startLine:endLine:filepath` fenced format) or mixed text to TEMP_FILE instead of 99 qfix lines. For search/vibe, normalize agent output to qfix format in `_retrieve_response` via `normalize_qfix_response`.

Depends on #185 and the workspace PR. Rebase onto `master` after they merge. When stacked on `master`, review only commit `121599a`.

<!-- Closes #XXX when response issue is filed -->

## Verification

### Linux

Repro: Neovim `:pwd` → `/home`, search "Find the main entrypoint".

Agent writes qfix lines to TEMP_FILE; `qf_list` populated with correct paths:

```
{"path":"/home/spencerls/tmp/99-8255-prompt","msg":"saved prompt to file"}
{"command":["cursor-agent","--workspace","/home",...]}
{"msg":"stdout","data":"Task complete. Results are in `/home/spencerls/tmp/99-8255`.\n"}
{"msg":"qf_list created","qf_list":[
  {"filename":"/home/spencerls/test.js","lnum":2,"col":1,"text":"Main entry function..."},
  {"filename":"/home/spencerls/test.js","lnum":39,"col":1,"text":"Top-level main() invocation..."}
]}
```

### Windows

Repro: `cd C:\Dev`, open `C:\Dev\test\test.js`, search "Find the main entrypoint".

`qf_list` populated (response fix works). Filename shows `"C"` instead of full path — separate upstream bug, fixed by [#178](https://github.com/ThePrimeagen/99/pull/178) (not in this PR stack):

````
{"path":"C:\\Dev\\test\\tmp/99-1626-prompt","msg":"saved prompt to file"}
{"command":["cursor-agent","--workspace","C:\\Dev",...]}
{"msg":"stdout","data":"```\nC:\\Dev\\test\\test.js:51:1,1,Script entry point...\n```\n"}
{"msg":"qf_list created","qf_list":[
  {"filename":"C","lnum":1,"col":1,"text":"Script entry point that invokes main to start program execution"}
]}
````

## Test plan

- [x] Unit test: `normalize_qfix_response` converts citation → qfix line
- [x] Unit test: existing qfix lines pass through
- [x] Manual Windows: search — `qf_list` populated (paths need #178)
- [x] Manual Linux: search — `qf_list` populated with correct filenames
- [x] Manual: `9v` visual — raw code replacement via TEMP_FILE (normalization skipped for `visual`)
