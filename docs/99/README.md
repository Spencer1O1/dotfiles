# Upstream contributions for [ThePrimeagen/99](https://github.com/ThePrimeagen/99)

## Rules

1. **Agents never open pull requests.** You open PRs manually after each fix is verified.
2. **Test one fork branch at a time.** Do not advance Lazy to the next branch until the current fix passes manual checks.

## Fork (`Spencer1O1/99`)

Local clone: `C:/Dev/99`

| Branch | Contents | Test status |
|--------|----------|-------------|
| `integration/cursor-agent` | Base: `upstream/master` + [#178](https://github.com/ThePrimeagen/99/pull/178) + [#138](https://github.com/ThePrimeagen/99/pull/138) | Base layer |
| `fix/cursor-agent-prompt` | Base + prompt `@file` delivery | **Verified** — [draft + logs](fixes/pr-cursor-agent-prompt-delivery.md) |
| `fix/cursor-agent-workspace` | Above + `--workspace`, cwd, tmp paths | Check 2 pending |
| `fix/cursor-agent-response` | Above + citation → qfix, stdout guard | Check 3 pending |

Dotfiles Lazy spec: advance branch in `nvim/lua/spencerls/plugins/99.lua` after each check passes. Draft PR bodies + log proof in `docs/99/fixes/` as you go.

## Sequential workflow

```
1. Lazy → fix/cursor-agent-prompt
2. Manual test (see TESTING.md) → check off prompt checklist
3. Lazy → fix/cursor-agent-workspace → test workspace checklist
4. Lazy → fix/cursor-agent-response → test response checklist
5. Merge verified branches into `integration/cursor-agent` locally
6. Draft PR body + logs in `docs/99/fixes/pr-*.md` (copy-paste section ready for GitHub)
7. You open upstream PRs when ready (one per fix)
```

## Open upstream PRs (merged into fork base only)

| PR | Topic | In fork base? |
|----|--------|---------------|
| [#178](https://github.com/ThePrimeagen/99/pull/178) | Windows qfix, closes #155 | Yes |
| [#138](https://github.com/ThePrimeagen/99/pull/138) | stdout → temp file for `--print` providers | Yes |
| [#152](https://github.com/ThePrimeagen/99/pull/152) | Alternate qfix fix | No — redundant with #178 |
| [#146](https://github.com/ThePrimeagen/99/pull/146) | stdin hook, OpenCode only | No — watch for prompt pattern |

## Filed issues

| # | Topic |
|---|--------|
| [#180](https://github.com/ThePrimeagen/99/issues/180) | Prompt via `@` file, not multiline argv |
| [#181](https://github.com/ThePrimeagen/99/issues/181) | `--workspace`, cwd, tmp path alignment |

Response-format issue not filed — citation hunt often writes proper qfix to TEMP_FILE when prompt + workspace work.

## PR drafts (for when you file upstream)

| Branch | Draft | Closes |
|--------|-------|--------|
| `fix/cursor-agent-prompt` | [fixes/pr-cursor-agent-prompt-delivery.md](fixes/pr-cursor-agent-prompt-delivery.md) | #180 |
| `fix/cursor-agent-workspace` | [fixes/pr-cursor-agent-workspace-tmp.md](fixes/pr-cursor-agent-workspace-tmp.md) | #181 |
| `fix/cursor-agent-response` | [fixes/pr-cursor-agent-response-format.md](fixes/pr-cursor-agent-response-format.md) | — |

## Fix vs workaround (current)

| Change | Status |
|--------|--------|
| qfix `parse_line` for `C:\...` | **In fork base** via #178 |
| Stdout → TEMP_FILE | **In fork base** via #138 |
| Prompt via `@` file | **`fix/cursor-agent-prompt`** — verified, [PR draft](fixes/pr-cursor-agent-prompt-delivery.md) |
| `--workspace` + cwd + tmp paths | **`fix/cursor-agent-workspace`** — not yet |
| Citation → qfix + stdout guard | **`fix/cursor-agent-response`** — not yet |
| Dotfiles `agent_workspace` | **Workaround** until workspace fix verified |

See [TESTING.md](TESTING.md) for checklists per branch.
