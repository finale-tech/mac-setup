#!/bin/bash

set -e

# Read JSON payload from stdin
PAYLOAD=$(cat)

# Extract file path
FILE=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

# Only format Java files
if [[ ! "$FILE" =~ \.java$ ]]; then
  exit 0
fi

# Try google-java-format if available (install with: brew install google-java-format)
if command -v google-java-format &> /dev/null; then
  if google-java-format --replace "$FILE" 2>&1; then
    echo "✓ Formatted: $FILE"
    exit 0
  else
    EXIT_CODE=$?
    echo "⚠️  Warning: Could not format $FILE (exit code: $EXIT_CODE)"
    echo "   File may have syntax errors or be malformed"
    exit 0
  fi
else
  # Fallback: just report that formatting should happen
  echo "ℹ️  Java file modified: $FILE (install google-java-format for auto-formatting)"
  echo "   Run: brew install google-java-format"
  exit 0
fi
