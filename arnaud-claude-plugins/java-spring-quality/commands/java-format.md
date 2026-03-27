---
description: Quick format changed Java files using google-java-format
---

# Format Changed Files

Automatically formats all changed Java files in the current branch using google-java-format to ensure consistent code style.

## What This Does

- Identifies Java files modified since last commit
- Applies Google Java Style formatting
- Reports files that were formatted

## When to Use

- Before committing changes
- After making code modifications
- To fix formatting violations quickly

## Execution

Run the formatting script:

```bash
./dev-scripts/format.sh
```

The script will:
1. Find all changed Java files using `git diff`
2. Format them with `google-java-format`
3. Report how many files were formatted

## Output

You'll see output like:
```
🎨 Formatting changed Java files...
✅ Formatted 3 files

Files formatted:
src/main/java/api/costco/gdx/pcp/admin/dlq/controller/DlqProcessingController.java
src/main/java/api/costco/gdx/pcp/admin/dlq/service/BigQueryDlqService.java
src/main/java/api/costco/gdx/pcp/admin/dlq/model/DlqMessage.java
```

## Requirements

- `google-java-format` must be installed: `brew install google-java-format`
- Must have uncommitted changes to format

## Next Steps

After formatting:
- Review the changes: `git diff`
- Stage the formatted files: `git add .`
- Continue with your commit workflow
