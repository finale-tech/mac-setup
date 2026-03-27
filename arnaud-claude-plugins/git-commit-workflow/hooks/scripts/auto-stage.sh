#!/bin/bash

# Read JSON payload from stdin
PAYLOAD=$(cat)

# Extract file path
FILE=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

# If no file, exit
if [[ -z "$FILE" ]]; then
  exit 0
fi

# Stage the file - run git from the file's directory (not project dir)
# This handles cases where edited files are in a different repo than the project
FILE_DIR=$(dirname "$FILE")

# Attempt to stage the file (using -C to run git in the file's directory)
if git -C "$FILE_DIR" add "$FILE" 2>&1; then
  echo "✓ Staged: $FILE"
  exit 0
else
  EXIT_CODE=$?
  echo "⚠️  Warning: Could not stage $FILE (exit code: $EXIT_CODE)"
  echo "   File may not be in git repository or may have been deleted"
  exit 0
fi
