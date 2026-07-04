# Testing 99 fork + cursor-agent

## Current step: 3 — Response format

Switch Lazy to `fix/cursor-agent-response`, `:Lazy sync`, restart Neovim.

---

## Step 1 — Prompt delivery ✓

[#185](https://github.com/ThePrimeagen/99/pull/185) · closes [#180](https://github.com/ThePrimeagen/99/issues/180)

---

## Step 2 — Workspace / tmp ✓

Repro: `cd C:\Dev`, open `C:\Dev\test\test.js`, `9s`.

- [x] `command` includes `--workspace` + `cwd` (`C:\Dev`)
- [x] `@` prompt points at `C:\Dev\test\tmp\...` (not parent `C:\Dev\tmp`)
- [x] Agent stdout references `C:\Dev\test\tmp\99-1644`
- [x] No doubled paths

Draft: [fixes/pr-cursor-agent-workspace-tmp.md](fixes/pr-cursor-agent-workspace-tmp.md)

---

## Step 3 — Response format

Branch: `fix/cursor-agent-response`

- [ ] `retrieve_results` has qfix lines (not status-only stdout)
- [ ] `qf_list` populated on search
- [ ] `9v` visual — no unwanted normalization

Draft: [fixes/pr-cursor-agent-response-format.md](fixes/pr-cursor-agent-response-format.md)

---

## After each verified fix

```bash
cd C:/Dev/99
git fetch upstream
git checkout -B fix/cursor-agent-<name>-pr upstream/master
git cherry-pick <commit-sha>
git push origin fix/cursor-agent-<name>-pr --force-with-lease
```

Merge into `integration/cursor-agent` locally when you want all fixes together for daily use.
