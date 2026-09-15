# Mac Setup

Step-by-step checklist for setting up a new Mac. Each section links to a detailed reference doc where applicable.

---

## 1. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-install instructions to add brew to your PATH.

---

## 2. Display (HiDPI Fix)

For external monitors with scaling issues.

1. Install displayplacer
```bash
brew install displayplacer
```

2. List displays and find your display ID
```bash
displayplacer list
```

3. Copy the display ID of the display you want to fix

4. Find a resolution with `scaling: on` and copy its mode number

5. Apply the fix (replace placeholders)
```bash
displayplacer "id:<DISPLAY_ID> mode:<MODE_NUMBER>"
```

---

## 3. Ghostty

> Reference: [Terminal Tools Guide — Ghostty](terminal_tools_guide.md#ghostty-setup--shortcuts)

1. Install
```bash
brew install --cask ghostty
```

2. Create config file
```bash
mkdir -p ~/.config/ghostty && touch ~/.config/ghostty/config
```

3. Add your config (`~/.config/ghostty/config`):
```
# Theme — auto-switches with macOS appearance
theme = dark:Builtin Solarized Dark,light:Builtin Solarized Light

# Shell integration (auto-detects zsh)
shell-integration = detect

# Confirm before closing a session with running processes
confirm-close-surface = true

# macOS native tabs
macos-titlebar-style = tabs

# Copy on highlight (like iTerm2)
copy-on-select = clipboard

# Hide mouse while typing
mouse-hide-while-typing = true

# Warn before pasting suspicious content
clipboard-paste-protection = true

# URLs are clickable (Cmd+click)
link-url = true
```

4. Reload config anytime with **Cmd+Shift+,** (no restart needed)

---

## 4. Zellij

> Reference: [Terminal Tools Guide — Zellij](terminal_tools_guide.md#zellij-usage)

1. Install
```bash
brew install zellij
```

2. Start a named session
```bash
zellij -s work
```

3. Key shortcuts:

| Shortcut | What it does |
|---|---|
| Ctrl+P, r | Split pane right |
| Ctrl+P, d | Split pane down |
| Ctrl+P, x | Close pane |
| Alt+Arrow keys | Move focus between panes |
| Ctrl+T, n | New tab |
| Alt+1, Alt+2... | Jump to tab by number |
| Ctrl+O, d | Detach from session |

4. Reattach later
```bash
zellij attach work
```

---

## 5. Tailscale

> Reference: [Terminal Tools Guide — The Stack](terminal_tools_guide.md#the-stack)

Lets you SSH into your Mac from your iPhone (or anywhere) over a private network.

1. Install
```bash
brew install --cask tailscale
```

2. Open Tailscale from Applications and sign in

3. On iPhone: install Termius, connect via your Mac's Tailscale IP

---

## 6. Karabiner

> Reference: [Keyboard layout](canary-extend-layout.svg) — Canary (matrix) on U.S. QWERTY, with Extend layer (Caps Lock): IJKL arrows, symbol grid, Space→Backspace, and Extend+⌘ physical-position rescues for Z/X/C/V

1. Install
```bash
brew install --cask karabiner-elements
```

2. Grant accessibility permissions when prompted

3. Import the layout config from [karabiner-canary-final.json](karabiner-canary-final.json)

---

## 7. Claude Code Status Line

Custom status line: `📁 cwd | 🤖 model (effort) | context % | ↑sent ↓recv | 🌿 branch +ins/-del | 🔥 cache | 💰 cost | 5h/7d limits`

A self-owned bash script — nothing to install, no third-party code. Needs only `jq` (ships with macOS 15+ at `/usr/bin/jq`) and `git`.

1. Copy the script
```bash
cp home/.claude/statusline.sh ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
```

2. Point Claude Code at it in `~/.claude/settings.json` (`home/.claude/settings.json` has the same block):
```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh",
  "padding": 0
}
```

3. Verify without restarting Claude Code — pipe a sample payload:
```bash
echo '{"cwd":"'"$PWD"'","model":{"display_name":"Opus 5"},"effort":{"level":"high"},"context_window":{"used_percentage":42},"cost":{"total_cost_usd":1.23}}' | ~/.claude/statusline.sh
```
   Expect one rendered line and exit 0. Cache, token and rate-limit segments only appear once Claude Code has made an API call, so they're absent here.

Notes:
- To change segments, edit the script directly — or run `/statusline` inside Claude Code to regenerate it.
- Fields are joined with `0x1F`, not tab: bash `read` collapses runs of whitespace IFS characters, so an empty field would shift every later field left.
- The old `~/.claude/statusline.py` can be deleted.
