# Upstream contributions for [ThePrimeagen/99](https://github.com/ThePrimeagen/99)

## Rules

1. **Agents never open pull requests.**
2. **Test one fork branch at a time** — advance Lazy only after the checklist passes.
3. **Two branch names per fix:** `fix/…` for local testing; `fix/…-pr` for upstream (cherry-pick onto `upstream/master`, or stack on `master` while earlier PRs are open).
4. **Fork contributors cannot stack PRs on upstream** with a fork-only base branch — open against `master`, note `Depends on #N`, mark draft until deps merge.

## Fork (`Spencer1O1/99`)

Local clone: `C:/Dev/99`

| Fix | Test branch | Upstream PR branch | Status |
|-----|-------------|-------------------|--------|
| Prompt `@file` | `fix/cursor-agent-prompt` | `fix/cursor-agent-prompt-pr` | [#185](https://github.com/ThePrimeagen/99/pull/185) open |
| Workspace / tmp | `fix/cursor-agent-workspace` | `fix/cursor-agent-workspace-pr` | Stacked on `master` (depends #185) |
| Response / qfix | `fix/cursor-agent-response` | `fix/cursor-agent-response-pr` | Verified — [draft](fixes/pr-cursor-agent-response-format.md) |
| Integration | `integration/cursor-agent` | — | #178 + #138 merged locally |

**Lazy spec:** `nvim/lua/spencerls/plugins/99.lua` → `fix/cursor-agent-response`

### Create a clean `-pr` branch (when filing)

```bash
cd C:/Dev/99
git fetch upstream origin
git checkout -B fix/cursor-agent-response-pr upstream/master
git cherry-pick 121599a   # response commit only, after prior PRs merge
git push origin fix/cursor-agent-response-pr --force-with-lease
```

Only `lua/99/providers.lua` and `lua/99/test/providers_spec.lua` in the PR — no README, `.gitignore`, or qfix-helpers.

## Workflow

1. Test on `fix/cursor-agent-*` (see [TESTING.md](TESTING.md))
2. Fill [fixes/pr-*.md](fixes/) with verification lines
3. Cherry-pick onto `fix/cursor-agent-*-pr` from `upstream/master` (or stack on `master`)
4. You open the GitHub PR

## Issues

| # | Topic |
|---|--------|
| [#180](https://github.com/ThePrimeagen/99/issues/180) | Prompt via `@` file |
| [#181](https://github.com/ThePrimeagen/99/issues/181) | `--workspace`, tmp paths |
| [#178](https://github.com/ThePrimeagen/99/pull/178) | Windows qfix drive-letter parsing (`C:` → filename `"C"`) |

## Dotfiles workaround

`agent_workspace.sync_99_tmp()` — revisit after workspace PR merges; upstream uses `./tmp` relative to `:pwd`.
