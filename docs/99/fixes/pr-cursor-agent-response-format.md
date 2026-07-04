# fix(providers): normalize CursorAgent citations and guard stdout tmp writes

## Summary

cursor-agent `--print` often returns citation blocks or status-only stdout ("Task complete. Results are in..."). For search/vibe:

1. Normalize citation blocks to 99 qfix lines in `_retrieve_response`
2. Skip writing status-only stdout over agent-written TEMP_FILE content

Complements #138. Does not re-implement stdout capture.

Builds on prompt (#180) and workspace (#181) fixes.

## Verification

<!-- paste log lines after Check 3 -->

## Test plan

- [ ] Unit test: `normalize_qfix_response` converts citation → qfix line
- [ ] Unit test: existing qfix lines pass through
- [ ] Manual Windows: search — qfix populated, status stdout does not clobber TEMP_FILE
- [ ] Manual Linux
