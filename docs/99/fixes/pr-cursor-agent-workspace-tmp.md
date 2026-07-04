# fix(providers): CursorAgent --workspace and tmp path resolution

## Summary

Pass `--workspace` on the cursor-agent command. Resolve `context.tmp_file` under Neovim's cwd (and absolute paths as-is) so cursor-agent writes TEMP_FILE where 99 reads it — especially when Neovim cwd is a parent directory (e.g. `C:\Dev` with project at `C:\Dev\test`).

Closes #181

## Verification

Repro: Neovim `:pwd` → `C:\Dev`, buffer `C:\Dev\test\test.js`, search "Find the main entrypoint".

Agent targets project tmp, not parent `C:\Dev\tmp`:

```
{"path":"C:\\Dev\\test\\tmp/99-1644-prompt","msg":"saved prompt to file"}
{"command":["cursor-agent","--workspace","C:\\Dev","--trust","--force","--model","composer-2.5-fast","--print",...]}
{"msg":"stdout","data":"Task complete. Output written to `C:\\Dev\\test\\tmp\\99-1644`.\n"}
```

## Test plan

- [x] Provider spec: command includes `--workspace`
- [x] Manual Windows: Neovim cwd ≠ project — TEMP_FILE paths align
- [ ] Manual Linux
