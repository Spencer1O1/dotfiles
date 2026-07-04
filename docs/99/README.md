# 99 + cursor-agent (Spencer1O1/99)

Daily driver: **`Spencer1O1/99` branch `master`** via Lazy.

Includes cursor-agent prompt / workspace / response fixes plus upstream #178 (Windows qfix) and #138 (stdout capture).

## Neovim setup

- **`<leader>cd`** — `:lcd` to git root of current buffer (aligns `tmp_dir = "./tmp"` with `--workspace`)
- Launch Neovim from the project root when possible; use `<leader>cd` when `:pwd` drifted

After fork updates: `:Lazy sync` and restart.

## Upstream PRs (filed)

| PR | Fix |
|----|-----|
| [#185](https://github.com/ThePrimeagen/99/pull/185) | Prompt `@file` |
| workspace (stacked) | `--workspace` + tmp paths |
| response (stacked) | Citation → qfix normalization |

Issues: [#180](https://github.com/ThePrimeagen/99/issues/180), [#181](https://github.com/ThePrimeagen/99/issues/181)

## Fork maintenance

```bash
cd C:/Dev/99
git fetch upstream
git checkout integration/cursor-agent
git merge upstream/master
git branch -f master integration/cursor-agent
git push origin master integration/cursor-agent
```

Local clone: `C:/Dev/99`
