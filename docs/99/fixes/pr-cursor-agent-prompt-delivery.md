# PR draft: CursorAgent prompt delivery

**Local only (do not paste):** fork `fix/cursor-agent-prompt` → upstream `master`, closes #180, verified 2026-07-04 on Windows.

---

## GitHub PR — copy from here

**Title:** `fix(providers): CursorAgent deliver prompt via @path to saved file`

**Body:**

## Summary

99 saves the full prompt to `tmp/99-*-prompt` before `make_request`. Stock `CursorAgentProvider` passes the entire multiline XML `query` as the `--print` argv argument, which breaks on Windows when Neovim cwd differs from the project root.

Deliver the prompt via a single-line `--print` message that references the saved file with `@absolute/path` instead.

Same pattern as #154 proposes for OpenCode (`--file`).

Closes #180

## Verification

Windows 11, Neovim 0.12.3, `CursorAgentProvider`, search in `C:\Dev\test`.

**Before:** multiline `<Context>` on `--print` — agent responds with "Your message looks incomplete".

**After:** single-line `@path` to saved prompt file — agent completes the task.

```
{"msg":"saved prompt to file","path":"C:\\Dev\\test\\tmp/99-6155-prompt"}
{"msg":"make_request","command":["cursor-agent","--trust","--force","--model","composer-2.5-fast","--print","Read and follow every instruction in @C:/Dev/test/tmp/99-6155-prompt using your file tools, then complete the task exactly as specified in that file."]}
{"msg":"stdout","data":"Task complete. Results written to `C:/Dev/test/tmp/99-6155`.\n"}
```

## Test plan

- [x] Provider spec: print arg is single-line, contains `@` and `99-*-prompt`, no `<Context>`
- [x] Manual Windows: search — agent reads prompt file and runs task
- [ ] Manual Linux

---

## Local notes

Full repro logs, fail case, and vibe/visual regression tracking live here — not for the upstream PR.

<details>
<summary>Fail case (stock code — multiline argv)</summary>

```
{"msg":"make_request","command":["cursor-agent","--trust","--force","--model","composer-2.5-fast","--print","<Context>\n<Output>\n/path/to/project/src/foo.js:24:8,3,..."]}
{"msg":"stdout","data":"Your message looks incomplete — it only contains `<Context>` with no actual question or task.\n"}
```

</details>

<details>
<summary>Pass case (full log)</summary>

See `pr-cursor-agent-prompt-delivery.log`

</details>

Empty `qf_list` on prompt-only branch is expected — stdout status overwrites TEMP_FILE until the response-format fix (Check 3).

**Files on fork:** `lua/99/providers.lua`, `lua/99/test/providers_spec.lua`, `README.md`
