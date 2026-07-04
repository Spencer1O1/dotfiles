# PR draft: CursorAgent response format

**Local only:** fork `fix/cursor-agent-response` → upstream `master`. Pending Check 3. Complements #138.

---

## GitHub PR — copy from here

**Title:** `fix(providers): normalize CursorAgent citations and guard stdout tmp writes`

**Body:**

## Summary

cursor-agent `--print` often returns citation blocks or status-only stdout ("Task complete. Results are in..."). For search/vibe:

1. Normalize citation blocks to 99 qfix lines in `_retrieve_response`
2. Skip writing status-only stdout over agent-written TEMP_FILE content

Complements #138. Does not re-implement stdout capture.

## Verification

<!-- paste log lines inline after Check 3 -->

## Test plan

- [ ] Unit test: `normalize_qfix_response` converts citation → qfix line
- [ ] Unit test: existing qfix lines pass through
- [ ] Manual Windows: search — qfix populated, status stdout does not clobber TEMP_FILE
- [ ] Manual Linux

---

## Local notes

Before state (prompt-only branch, Check 1):

```
{"msg":"stdout","data":"Task complete. Results written to `C:/Dev/test/tmp/99-6155`.\n"}
{"msg":"retrieve_results","results":"Task complete. Results written to `C:/Dev/test/tmp/99-6155`."}
{"msg":"qf_list created","qf_list":[]}
```

After Check 3, expect qfix lines in `retrieve_results` and populated `qf_list`.
