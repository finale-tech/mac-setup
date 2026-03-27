---
description: Comprehensive weekly code analysis - PMD, Checkstyle, coverage, dependencies
---

# Deep Analysis (Comprehensive Review)

Runs extensive code quality analysis generating detailed reports. This is your weekly health check or pre-PR comprehensive review.

## What This Does

Executes four comprehensive analyses:
1. **PMD Analysis** - Full static analysis with HTML report
2. **Checkstyle Analysis** - Complete style check with text report
3. **Test Coverage** - Jacoco coverage analysis with HTML report
4. **Dependency Analysis** - Maven dependency vulnerability check

## When to Use

- **Weekly** - Regular code health checks
- **Before Pull Requests** - Comprehensive pre-PR validation
- **Onboarding** - Establish quality baseline for new projects
- **After Major Changes** - Verify large refactorings
- **Quality Reviews** - Deep dive into code quality metrics

## Execution

Run the deep analysis script:

```bash
./dev-scripts/deep-analysis.sh
```

This will take several minutes as it runs comprehensive checks and generates multiple reports.

## Output

```
🔬 Running deep code analysis...

This may take several minutes...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1/4 Running comprehensive PMD analysis...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  PMD found issues (see pmd-report.html)
✅ PMD report generated: pmd-report.html

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2/4 Running Checkstyle analysis...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  Checkstyle found issues (see checkstyle-report.txt)
✅ Checkstyle report generated: checkstyle-report.txt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3/4 Running tests with coverage analysis...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Coverage report generated: target/site/jacoco/index.html

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4/4 Checking for dependency vulnerabilities...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ No dependency issues found

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Deep analysis complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Generated reports:
  📊 PMD:        pmd-report.html
  📋 Checkstyle: checkstyle-report.txt
  📈 Coverage:   target/site/jacoco/index.html

To view PMD report:        open pmd-report.html
To view coverage report:   open target/site/jacoco/index.html
```

## Generated Reports

### 1. PMD Report (pmd-report.html)
- **Location:** `pmd-report.html` in project root
- **Format:** HTML with interactive navigation
- **Contains:** 
  - Security vulnerabilities
  - Potential bugs
  - Performance issues
  - Best practice violations
  - Code smells
- **View:** `open pmd-report.html`

### 2. Checkstyle Report (checkstyle-report.txt)
- **Location:** `checkstyle-report.txt` in project root
- **Format:** Text with file:line numbers
- **Contains:**
  - Style violations
  - Naming convention issues
  - Javadoc problems
  - Import issues
  - Code structure violations
- **View:** `cat checkstyle-report.txt` or open in editor

### 3. Coverage Report (Jacoco)
- **Location:** `target/site/jacoco/index.html`
- **Format:** HTML with drill-down capability
- **Contains:**
  - Line coverage percentages
  - Branch coverage
  - Method coverage
  - Class coverage
  - Package-level summaries
- **View:** `open target/site/jacoco/index.html`

### 4. Dependency Analysis
- **Output:** Console output only
- **Contains:**
  - Used undeclared dependencies
  - Unused declared dependencies
  - Dependency warnings

## Requirements

- `pmd`: `brew install pmd`
- `checkstyle`: `brew install checkstyle`
- Maven (already have)
- Jacoco plugin configured in pom.xml (already configured)

## Performance

Expected execution time: **3-5 minutes**
- PMD: 30-60 seconds
- Checkstyle: 10-20 seconds
- Tests + Coverage: 2-3 minutes
- Dependency check: 10-20 seconds

## Workflow Integration

**Recommended usage patterns:**

### Weekly Health Check
```
Monday morning:
1. Run /deep-analysis
2. Review reports to identify trends
3. Create tickets for major issues
4. Track improvement over time
```

### Pre-Pull Request
```
Before creating PR:
1. Run /deep-analysis
2. Use deep-analyzer agent to interpret results
3. Fix critical issues found
4. Re-run to verify clean reports
5. Include report summaries in PR description
```

### Post-Refactoring
```
After major refactoring:
1. Run /deep-analysis
2. Compare coverage with baseline
3. Ensure no new PMD violations introduced
4. Verify improvements in metrics
```

## Next Steps

**After running deep analysis:**

1. **View the reports** - Open HTML reports in browser
2. **Use deep-analyzer agent** - Get AI interpretation: "Run deep-analyzer agent to consolidate findings"
3. **Prioritize fixes** - Agent will categorize CRITICAL → HIGH → MEDIUM → LOW
4. **Fix issues** - Use api-implementer for corrections
5. **Track progress** - Save reports to compare with next run

**Alternative: Use comprehensive agent**
Instead of manually reviewing reports, invoke the `deep-analyzer` agent:
```
"Run deep-analyzer agent to review all reports and prioritize issues"
```

The agent will:
- Read all generated reports
- Consolidate findings
- Prioritize by severity
- Provide specific fix recommendations
- Hand off to api-implementer

## Report Persistence

Reports are generated in the project root and are git-ignored. For tracking:
- Save reports to a `reports/` directory with timestamps
- Archive weekly for trend analysis
- Include key metrics in sprint retrospectives

## Troubleshooting

**PMD not installed:**
```bash
brew install pmd
```

**Checkstyle not installed:**
```bash
brew install checkstyle
```

**Checkstyle config not found:**
The script looks for `google_checks.xml` in:
1. `$HOME/Downloads/google_checks.xml`
2. `/google_checks.xml` (system default)

Download Google checks if needed:
```bash
curl -o ~/Downloads/google_checks.xml https://raw.githubusercontent.com/checkstyle/checkstyle/master/src/main/resources/google_checks.xml
```

**Tests fail:**
Fix test failures before analyzing coverage:
1. Run `test-runner` agent to diagnose
2. Use `api-implementer` to fix
3. Re-run `/deep-analysis`
