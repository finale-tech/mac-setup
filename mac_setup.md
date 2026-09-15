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
brew tap jakehilborn/jakehilborn && brew install displayplacer
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

## 7. Claude Code Status Line (ccstatusline)

Custom status line: `📁 cwd | 🤖 model | context bar | 🌿 branch | (+ins,-del) … 💰 cost`

1. Install (Homebrew, via a third-party tap — not in homebrew-core)
```bash
brew tap chenrui333/tap && brew install ccstatusline
```

   The formula depends on the unversioned `node` formula (installed if absent). The binary lands in `/opt/homebrew/bin`, so it's on `PATH` for every shell and GUI launch — no nvm dependency.

2. Copy the widget config
```bash
mkdir -p ~/.config/ccstatusline
cp home/.config/ccstatusline/settings.json ~/.config/ccstatusline/settings.json
```

3. Point Claude Code at it. `home/.claude/settings.json` in this repo already has the block; set the same in `~/.claude/settings.json`:
```json
"statusLine": {
  "type": "command",
  "command": "ccstatusline",
  "padding": 0,
  "refreshInterval": 10
}
```

4. Verify without restarting Claude Code — feed it the payload shape Claude Code sends:
```bash
echo '{"session_id":"t","cwd":"'"$PWD"'","model":{"display_name":"Opus 5"},"version":"2.0.0","cost":{"total_cost_usd":0.01,"total_duration_ms":1000},"context_window":{"used_percentage":12}}' | ccstatusline
```
   Expect one rendered line. If the TUI opens instead, stdin wasn't connected.

Notes:
- Update with `brew upgrade ccstatusline`. The `installation` block in `settings.json` is stale metadata from the npm install — if the TUI offers to self-update, decline; brew owns updates.
- Why the tap is acceptable: the package has zero runtime deps and no install scripts; the tap (a Homebrew core maintainer's) ships a checksummed prebuilt bottle and pins the version, so upgrades are explicit rather than silent-latest. Upstream is a single maintainer either way.
- Config uses truecolor (`colorLevel: 3`) — fine in Ghostty.
- Git widgets have `hideNoGit` so they disappear outside repos.
- To tweak interactively: run `ccstatusline` with no stdin for the TUI configurator.
