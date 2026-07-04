# Upstream contributions for [ThePrimeagen/99](https://github.com/ThePrimeagen/99)

## Rules

1. **Agents never open pull requests.**
2. **Test one fork branch at a time** — advance Lazy only after the checklist passes.
3. **Two branch names per fix:** `fix/…` for local testing (integration base); `fix/…-pr` for upstream (cherry-pick onto `upstream/master`).

## Fork (`Spencer1O1/99`)

Local clone: `C:/Dev/99`

| Fix | Test branch | Upstream PR branch | Status |
|-----|-------------|-------------------|--------|
| Prompt `@file` | `fix/cursor-agent-prompt` | `fix/cursor-agent-prompt-pr` | Done — [#185](https://github.com/ThePrimeagen/99/pull/185) |
| Workspace / tmp | `fix/cursor-agent-workspace` | `fix/cursor-agent-workspace-pr` | Verified — [draft](fixes/pr-cursor-agent-workspace-tmp.md) |
| Response / qfix | `fix/cursor-agent-response` | `fix/cursor-agent-response-pr` | **Testing next** |
| Integration | `integration/cursor-agent` | — | Base: #178 + #138 merged |

**Lazy spec:** `nvim/lua/spencerls/plugins/99.lua` → advance to `fix/cursor-agent-response` for Check 3

### Create a clean `-pr` branch (when filing)

```bash
cd C:/Dev/99
git fetch upstream origin
git checkout -B fix/cursor-agent-workspace-pr upstream/master
git cherry-pick db5dd0e   # workspace commit only, after prompt PR merges
# or cherry-pick prompt + workspace if prompt is not merged yet
git push origin fix/cursor-agent-workspace-pr --force-with-lease
```

Only `lua/99/providers.lua` and `lua/99/test/providers_spec.lua` should land in the PR — no README, `.gitignore`, or qfix-helpers.

## Workflow

1. Test on `fix/cursor-agent-*` (see [TESTING.md](TESTING.md))
2. Fill [fixes/pr-*.md](fixes/) + `.log` with verification lines
3. Cherry-pick onto `fix/cursor-agent-*-pr` from `upstream/master`
4. You open the GitHub PR

## Issues

| # | Topic |
|---|--------|
| [#180](https://github.com/ThePrimeagen/99/issues/180) | Prompt via `@` file |
| [#181](https://github.com/ThePrimeagen/99/issues/181) | `--workspace`, cwd, tmp paths |

## Dotfiles workaround

`agent_workspace.sync_99_tmp()` — revisit after workspace fix is verified; may no longer be needed.
