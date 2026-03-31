# GhostSpell 👻✨

**System-wide AI spell checker for macOS**

Select text anywhere → Hit hotkey → Perfect spelling. Powered by your local Ollama (private, free, no API calls).

---

## What It Does

- Works in **any app**: Messages, Notes, Safari, Mail, etc.
- Uses **local AI** (phi4-mini or your choice) — no data leaves your Mac
- Shows notifications so you know it's working
- Fixes spelling and grammar in ~2 seconds

---

## Prerequisites

1. **Ollama installed and running**
   ```bash
   curl http://localhost:11434
   # Should return "Ollama is running"
   ```

2. **terminal-notifier installed**
   ```bash
   brew install terminal-notifier
   ```

3. **GhostSpell model downloaded** (optional - script uses phi4-mini:latest by default)
   ```bash
   ollama pull phi4-mini:latest
   ```

---

## Setup (10 minutes)

### Step 1: Create the Automator Quick Action

1. Open **Automator** (Cmd+Space → "Automator")
2. File → New → **Quick Action**
3. Set these at the top:
   - **Workflow receives current:** `text`
   - **in:** `any application`
   - ✅ **Output replaces selected text** (CHECK this box!)
   
4. In left sidebar, search for **Run AppleScript**
5. Drag it to the workflow area
6. **Replace** the default script with this:

```applescript
on run {input, parameters}
	try
		if input is {} or input is "" then
			return ""
		end if
		
		set inputText to input as string
		set iconPath to "/Users/user/Projects/GhostSpell/GhostSpell-icon-small.png"
		
		-- Show notification
		do shell script "/opt/homebrew/bin/terminal-notifier -title GhostSpell -message 'Fixing...' -appIcon " & quoted form of iconPath
		
		-- Run spell check
		set scriptPath to "/Users/user/Projects/GhostSpell/ghostspell-automator.sh"
		set correctedText to do shell script scriptPath & " " & quoted form of inputText
		
		-- Show done notification
		do shell script "/opt/homebrew/bin/terminal-notifier -title GhostSpell -message 'Fixed!' -appIcon " & quoted form of iconPath
		
		return correctedText
		
	on error errMsg
		display alert "GhostSpell Error" message errMsg
		return ""
	end try
end run
```

7. **File → Save** (Cmd+S)
8. Name it **GhostSpell**
9. Close Automator

---

### Step 2: Set Your Hotkey

1. Open **System Settings → Keyboard → Keyboard Shortcuts → Services**
2. Scroll down to **Text** section
3. Find **GhostSpell**
4. Click the blank space next to it
5. Press your hotkey combo:
   - Suggested: `⌃⌥⌘S` (Control+Option+Command+S)
   - Or: `⌃⌘G` (Control+Command+G)
6. Click **Done**

---

### Step 3: Test It!

1. Open **Notes** or **Messages**
2. Type: `Ths sentnce has speling erors`
3. **Select all the text** (Cmd+A)
4. Press your hotkey
5. Wait ~10 seconds...
6. It should become: `This sentence has spelling errors`

---

## Files

- `ghostspell.sh` - The AI spell checker script
- `GhostSpell-icon-small.png` - Your ghost icon (128x128)
- `README.md` - This file

Location: `/Users/user/Projects/GhostSpell/`

---

## Troubleshooting

### "No text selected" or nothing happens
- Make sure you **selected text first** before hitting the hotkey
- The hotkey only works when text is highlighted

### "GhostSpell is not allowed to send keystrokes" (if using the app version)
- This only applies if you tried the Script Editor app route
- Go to System Settings → Privacy & Security → Accessibility
- Add/enable GhostSpell (or just use the Automator version instead)

### Notifications don't show
- Check that terminal-notifier is installed: `which terminal-notifier`
- Should return `/opt/homebrew/bin/terminal-notifier`

### Ollama not responding
- Make sure Ollama is running: `curl http://localhost:11434`
- If not, run: `ollama serve`

### Slow response
- First run loads the model (~10 seconds)
- Subsequent runs are faster
- Can switch to a different model by editing `ghostspell.sh`:
  ```bash
  MODEL="${GHOSTSPELL_MODEL:-phi4-mini:latest}"
  ```
  
  **Small fast options:**
  - `phi4-mini:latest` (1.6GB) - Fast, no thinking
  - `qwen2.5:1.8b` (1.1GB) - Fast, good grammar
  - `gemma2:2b` (1.6GB) - Fast, direct output

---

## How It Works

1. You select text and hit the hotkey
2. macOS sends the selected text to the Automator service
3. The AppleScript calls `ghostspell.sh` with the text
4. The script sends it to Ollama with a prompt: "Fix the spelling and grammar..."
5. Ollama returns corrected text
6. The script puts the corrected text back, replacing your selection
7. Notifications show progress via terminal-notifier

---

## Why This Exists

Apple's spell check is... not great. GhostSpell uses actual AI that:
- Understands context
- Fixes grammar too
- Can figure out what you meant even with terrible spelling
- Works offline (no internet needed after setup)
- Keeps your text private (never leaves your computer)

---

## Built By

**CluelessIdiot** (with help from **Terry** 🦎)

March 26, 2026

First app/Automation project! 🎉
