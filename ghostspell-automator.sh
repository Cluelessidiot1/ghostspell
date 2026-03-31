#!/bin/bash

# GhostSpell Automator Wrapper
# This handles the way Automator passes text input

# Read all input from arguments (when pass input = as arguments)
for INPUT in "$@"; do
    if [ -n "$INPUT" ]; then
        /Users/user/.openclaw/workspace/fixit/ghostspell.sh "$INPUT"
        exit 0
    fi
done

# If no args, try stdin
INPUT=$(cat)
if [ -n "$INPUT" ]; then
    /Users/user/.openclaw/workspace/fixit/ghostspell.sh "$INPUT"
    exit 0
fi

# Still nothing
echo ""
