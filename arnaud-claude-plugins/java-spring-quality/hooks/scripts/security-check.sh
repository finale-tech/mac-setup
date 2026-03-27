#!/bin/bash

# Security hook - blocks dangerous commands and sensitive file modifications
# This is a safety net in addition to permissions

# Read JSON payload from stdin
PAYLOAD=$(cat)

# Extract the tool name and relevant parameters
TOOL_NAME=$(echo "$PAYLOAD" | jq -r '.tool_name')
COMMAND=$(echo "$PAYLOAD" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

# Function to block with message
block_with_message() {
  local reason="$1"
  local item="$2"
  local suggestion="$3"
  
  echo "🚫 SECURITY BLOCK: $reason"
  echo ""
  echo "Blocked: $item"
  echo ""
  echo "⚠️  This action is blocked for safety."
  echo ""
  if [[ -n "$suggestion" ]]; then
    echo "Suggestion: $suggestion"
    echo ""
  fi
  echo "If you believe this is an error, check .claude/hooks/security-check.sh"
  
  exit 1  # Non-zero exit blocks the action
}

# Check for Write/Edit operations on sensitive files
if [[ "$TOOL_NAME" =~ ^(Write|Edit|MultiEdit)$ ]]; then
  if [[ -n "$FILE_PATH" ]]; then
    
    # Block production configuration files
    if [[ "$FILE_PATH" =~ application-prd\.(yaml|yml|properties)$ ]]; then
      block_with_message \
        "Production config modification" \
        "$FILE_PATH" \
        "Production configs should only be modified through proper deployment processes"
    fi
    
    # Block .env files (often contain secrets)
    if [[ "$FILE_PATH" =~ \.env$ ]] || [[ "$FILE_PATH" =~ \.env\. ]]; then
      block_with_message \
        "Environment file modification" \
        "$FILE_PATH" \
        "Environment files often contain secrets and should be managed carefully"
    fi
    
    # Block credential/secret files
    if [[ "$FILE_PATH" =~ (credentials|secrets|keystore|truststore|\.pem|\.key|\.p12)$ ]]; then
      block_with_message \
        "Credential file modification" \
        "$FILE_PATH" \
        "Credential files should not be modified through automated tools"
    fi
    
    # Block .git directory modifications
    if [[ "$FILE_PATH" =~ \.git/ ]]; then
      block_with_message \
        "Git internal file modification" \
        "$FILE_PATH" \
        "Git internal files should not be modified directly"
    fi
  fi
fi

# Check Bash commands
if [[ "$TOOL_NAME" == "Bash" ]] && [[ -n "$COMMAND" ]]; then
  
  # Check for forbidden command patterns
  FORBIDDEN_PATTERNS=(
    "git commit"
    "git.*commit"
    "git push"
    "git.*push"
    "git remote add"
    "git remote set-url"
    "rm -rf /"
    "rm -rf ~"
    "rm -rf \$HOME"
    "rm -rf \."
    ":(){ :|:& };:"  # fork bomb
    "chmod.*777"     # overly permissive permissions
    "chmod.*-R.*777" # recursive 777
  )

  for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qiE "$pattern"; then
      local suggestion=""
      if [[ "$pattern" =~ "git commit" ]]; then
        suggestion="Git commit commands must be run manually outside Claude Code"
      elif [[ "$pattern" =~ "git push" ]]; then
        suggestion="Git push commands must be run manually outside Claude Code"
      elif [[ "$pattern" =~ "chmod.*777" ]]; then
        suggestion="Use more restrictive permissions (e.g., 755 for dirs, 644 for files)"
      elif [[ "$pattern" =~ "rm -rf" ]]; then
        suggestion="Destructive commands should be run manually with caution"
      fi
      
      block_with_message \
        "Dangerous command pattern" \
        "$COMMAND" \
        "$suggestion"
    fi
  done
  
  # Check for potential credential exposure in commands
  if echo "$COMMAND" | grep -qiE "(password|token|secret|api[_-]?key).*="; then
    block_with_message \
      "Potential credential exposure in command" \
      "$COMMAND" \
      "Use environment variables or secret management for credentials"
  fi
  
  # Warn about direct production operations (don't block, just log)
  if echo "$COMMAND" | grep -qiE "(production|prod|prd)"; then
    echo "⚠️  WARNING: Command mentions production environment"
    echo "   Command: $COMMAND"
    echo "   Ensure this is intentional and safe"
    echo ""
  fi
fi

# All checks passed
exit 0
