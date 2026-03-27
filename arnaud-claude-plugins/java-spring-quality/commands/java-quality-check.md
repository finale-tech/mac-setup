---
description: Pre-commit quality checks - format validation, PMD analysis, and tests
---

# Quality Check (Pre-Commit Gate)

Runs comprehensive quality checks before committing code. This is your pre-commit safety net that validates formatting, runs static analysis, and executes tests.

## What This Does

Executes three validation steps:
1. **Format Check** - Verifies code formatting (doesn't fix, just checks)
2. **PMD Static Analysis** - Detects bugs, code smells, security issues (Priority 3+)
3. **Test Execution** - Runs all unit tests

## When to Use

- **Before committing** - Essential pre-commit validation
- **Before pushing** - Catch issues before they reach remote
- **After fixing issues** - Verify all quality gates pass
- After making changes to verify quality

## Execution

Run the quality check script:

```bash
./dev-scripts/quality-check.sh
```

The script will run all checks sequentially and fail fast if any check fails.

## Output Examples

### ✅ All Checks Pass
```
🔍 Running quality checks...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1/3 Checking code formatting...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Code formatting looks good

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2/3 Running PMD static analysis...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ PMD checks passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3/3 Running tests...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ All quality checks passed!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### ❌ Format Issues Found
```
1/3 Checking code formatting...
❌ Code formatting issues found. Run ./dev-scripts/format.sh to fix
```

### ❌ PMD Issues Found
```
2/3 Running PMD static analysis...
[PMD violation details...]
❌ PMD found issues. Review output above or run ./dev-scripts/deep-analysis.sh for full report
```

### ❌ Tests Failed
```
3/3 Running tests...
[Test failure details...]
❌ Tests failed. Fix issues before committing
```

## Requirements

- `google-java-format` (optional, for format checks): `brew install google-java-format`
- `pmd` (optional, for static analysis): `brew install pmd`
- Maven for tests

## Workflow Integration

**Recommended pre-commit workflow:**
```
1. Make code changes
2. Run /format (fix formatting)
3. Run /quality-check (validate everything)
4. If fails: fix issues → repeat step 3
5. If passes: commit with confidence
```

## Exit Codes

- `0` - All checks passed, safe to commit
- `1` - One or more checks failed, do not commit

## Performance

- **Fast checks first** - Format validation is quick
- **Medium checks** - PMD analysis takes 10-30 seconds
- **Slower checks last** - Tests take 1-2 minutes

Total time: ~2-3 minutes depending on test suite size

## Next Steps

**If checks pass:**
- Proceed with commit: `git commit`
- Or use `/explainchanges` to generate commit message

**If checks fail:**
- Format issues: Run `/format` to auto-fix
- PMD issues: Use `quality-gate` agent to interpret and fix
- Test failures: Use `test-runner` agent to diagnose
