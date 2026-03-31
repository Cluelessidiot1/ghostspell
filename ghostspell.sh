#!/bin/bash

# GhostSpell - AI Spell & Grammar Fixer
# Sends selected text to Ollama and returns corrected version

TEXT="$1"
MODEL="${GHOSTSPELL_MODEL:-phi4-mini:latest}"

if [ -z "$TEXT" ]; then
    # If no argument, read from stdin
    TEXT=$(cat)
fi

if [ -z "$TEXT" ]; then
    # Still empty? Return empty
    echo ""
    exit 0
fi

# Build the prompt - escape the text properly for JSON
PROMPT=$(printf 'Fix the spelling and grammar in this text. Only return the corrected text, no explanations or quotes around it:\n\n%s' "$TEXT")

# Call Ollama using jq to properly escape JSON if available
if command -v jq &>/dev/null; then
    JSON_PAYLOAD=$(printf '%s' "$PROMPT" | jq -Rs '{"model": "'$MODEL'", "prompt": ., "stream": false}')
else
    # Fallback - basic escaping
    ESCAPED_PROMPT=$(printf '%s' "$PROMPT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g')
    JSON_PAYLOAD="{\"model\": \"$MODEL\", \"prompt\": \"$ESCAPED_PROMPT\", \"stream\": false}"
fi

RESPONSE=$(curl -s http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD" 2>/dev/null)

# Extract the response using jq if available
if command -v jq &>/dev/null; then
    CORRECTED=$(echo "$RESPONSE" | jq -r '.response // empty' 2>/dev/null)
else
    # Fallback to sed - just get between "response":" and ","
    CORRECTED=$(echo "$RESPONSE" | sed -n 's/.*"response":"\([^"]*\)".*/\1/p')
fi

# If empty or failed, return original
if [ -z "$CORRECTED" ] || [ "$CORRECTED" = "null" ]; then
    echo "$TEXT"
else
    # Remove any escaped newlines
    echo "$CORRECTED" | sed 's/\\n/\n/g'
fi
