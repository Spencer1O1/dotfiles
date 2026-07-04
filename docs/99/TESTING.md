# Testing 99 fork + cursor-agent

## Rules

- **One branch at a time.** Change Lazy branch in `nvim/lua/spencerls/plugins/99.lua`, restart Neovim, run that branch's checklist, then move on.
- **Agents never open PRs.** You file upstream PRs only after a fix is verified.

## Fork setup

| | |
|--|--|
| Remote | `https://github.com/Spencer1O1/99` |
| Local | `C:/Dev/99` |
| Base branch | `integration/cursor-agent` (#178 qfix + #138 stdout) |

```bash
cd C:/Dev/99
git fetch origin
```

---

## Step 1 — Prompt delivery (`fix/cursor-agent-prompt`)

**Lazy branch:** `fix/cursor-agent-prompt` (current default in dotfiles)

After changing branch in `99.lua`:

1. `:Lazy sync` (or `:Lazy update 99`)
2. **Restart Neovim** — required so `require("99")` reloads

Verify the fix loaded:

```vim
:lua print(vim.inspect(require("99.providers").CursorAgentProvider._build_command(nil, "ignored", { model = "x", tmp_file = "tmp/99-test" })))
```

Last element should be a single line containing `@` and `99-test-prompt`, not `<Context>`.

### Checklist

- [x] `9l` → `command` shows single-line `--print` with `@.../99-*-prompt` (no multiline `<Context>` on argv)
- [x] `9s` → agent reads prompt and runs search (not "incomplete message")
- [ ] `9b` vibe, `9v` visual still work
- [ ] Regression: qfix paths show full `C:\...` (#178 base)

Log proof: [fixes/pr-cursor-agent-prompt-delivery.log](fixes/pr-cursor-agent-prompt-delivery.log) · [PR draft](fixes/pr-cursor-agent-prompt-delivery.md)

**When all pass:** change Lazy branch to `fix/cursor-agent-workspace` → Step 2. (Prompt PR draft is ready in [fixes/pr-cursor-agent-prompt-delivery.md](fixes/pr-cursor-agent-prompt-delivery.md).)

---

## Step 2 — Workspace / tmp (`fix/cursor-agent-workspace`)

**Lazy branch:** `fix/cursor-agent-workspace`

Includes prompt fix from Step 1.

### Checklist

- [ ] `9l` → `command` includes `--workspace` matching `:pwd`
- [ ] `cd C:\Dev`, open `C:\Dev\test\test.js` → `9s` → `retrieve_results` is non-empty (agent wrote to project tmp, 99 reads same path)
- [ ] No doubled paths like `C:/Dev/test/C:/Dev/test/tmp/...`
- [ ] Step 1 checks still pass

**When all pass:** add log proof to [fixes/pr-cursor-agent-workspace-tmp.md](fixes/pr-cursor-agent-workspace-tmp.md) + `.log`, then change Lazy branch to `fix/cursor-agent-response` → Step 3.

---

## Step 3 — Response format (`fix/cursor-agent-response`)

**Lazy branch:** `fix/cursor-agent-response`

Includes prompt + workspace fixes.

### Checklist

- [ ] Search with citation-only agent output → qfix populated (or warn is gone)
- [ ] Status-only stdout (`Done. Results are in...`) does not clobber agent-written TEMP_FILE
- [ ] `9v` visual / tutorial — no unwanted qfix normalization
- [ ] Steps 1–2 checks still pass

**When all pass:** add log proof to [fixes/pr-cursor-agent-response-format.md](fixes/pr-cursor-agent-response-format.md) + `.log`, merge branches into `integration/cursor-agent` locally, then you open upstream PRs.

---

## After all three verified

```bash
cd C:/Dev/99
git checkout integration/cursor-agent
git merge fix/cursor-agent-prompt --no-ff -m "merge verified: cursor-agent prompt delivery"
git merge fix/cursor-agent-workspace --no-ff -m "merge verified: cursor-agent workspace/tmp"
git merge fix/cursor-agent-response --no-ff -m "merge verified: cursor-agent response format"
git push origin integration/cursor-agent
```

Then open PRs on GitHub yourself (drafts in `docs/99/fixes/`).

---

## Automated tests

From `C:/Dev/99` on the branch under test:

```bash
make lua_test
```

Windows (requires `../plenary.nvim` sibling):

```powershell
nvim --headless --noplugin -u scripts/tests/minimal.vim `
  -c "PlenaryBustedDirectory lua/99 {minimal_init = 'scripts/tests/minimal.vim'}"
```

Run after each branch change.

---

## Shrinking dotfiles workarounds

| Verified fix | Dotfiles change |
|--------------|-----------------|
| workspace | Revisit `agent_workspace.sync_99_tmp()` — may no longer be needed |
