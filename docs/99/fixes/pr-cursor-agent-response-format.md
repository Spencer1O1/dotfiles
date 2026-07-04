# fix(providers): normalize CursorAgent citations to qfix lines

## Summary

cursor-agent often writes citation blocks (`` ```line:line:path ``) or mixed text to TEMP_FILE instead of 99 qfix lines. For search/vibe, normalize agent output to qfix format in `_retrieve_response` via `normalize_qfix_response`.

Depends on #185 and workspace PR. Rebase onto `master` after they merge.

<!-- Closes #XXX when response issue is filed -->

## Verification

<!-- paste log lines after Check 3: retrieve_results with qfix lines, qf_list populated -->

## Test plan

- [x] Unit test: `normalize_qfix_response` converts citation → qfix line
- [x] Unit test: existing qfix lines pass through
- [ ] Manual Windows: search — `qf_list` populated
- [ ] Manual Linux
