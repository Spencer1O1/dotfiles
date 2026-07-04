# PR draft: CursorAgent workspace / tmp paths

**Local only:** fork `fix/cursor-agent-workspace` → upstream `master`, closes #181. Pending Check 2.

---

## GitHub PR — copy from here

**Title:** `fix(providers): CursorAgent --workspace, cwd, and tmp path resolution`

**Body:**

## Summary

Pass `--workspace` and set `vim.system` `cwd` to the project root. Resolve `context.tmp_file` under that root so cursor-agent writes TEMP_FILE where 99 reads it — especially when Neovim cwd is a parent directory (e.g. `C:\Dev` with project at `C:\Dev\test`).

Builds on prompt @file delivery (Closes #180).

Closes #181

## Verification

<!-- paste log lines inline after Check 2 -->

Repro: Neovim cwd `C:\Dev`, buffer `C:\Dev\test\test.js`, run search.

## Test plan

- [ ] Provider spec: command includes `--workspace`
- [ ] Manual Windows: Neovim cwd ≠ project — TEMP_FILE read succeeds
- [ ] Manual Linux

---

## Local notes

Fill verification + `.log` after Check 2. Depends on prompt fix passing first.
