# Mac Setup

Step-by-step checklist for setting up a new Mac. Do the sections in order, because later steps depend on earlier ones (noted under each heading). Each section links to a detailed reference doc where applicable.

---

## 1. Homebrew

The installer also installs the Xcode Command Line Tools, which include `git` (needed in step 2).

1. Install
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Put `brew` on your PATH for every new shell, and for the current one
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```
   Don't skip this. Without it, the tools in step 3 install fine but never load, and the `.zshrc` guards skip them silently, so you get no error.

3. Check
```bash
brew --version && git --version
```

---

## 2. Clone this repo

> Needs: `git` (step 1)

```bash
mkdir -p ~/Documents/gits && cd ~/Documents/gits
git clone https://github.com/finale-tech/mac-setup.git
cd mac-setup
```

Run every later `cp home/…` command from this folder.

---

## 3. Shell (zsh)

> Needs: Homebrew (step 1), this repo (step 2)

Reference config: [home/.zshrc](home/.zshrc). It adds smart `cd` (zoxide), fuzzy search (fzf), inline history suggestions, a large shared history, and a short cyan prompt. It also puts `~/.local/bin` on PATH, where Claude Code installs in step 6.

1. Install the tools (all from Homebrew core)
```bash
brew install zoxide fzf zsh-autosuggestions node
```

2. Back up the existing config, then copy the reference
```bash
cp ~/.zshrc ~/.zshrc.bak 2>/dev/null; cp home/.zshrc ~/.zshrc
```

3. Open a **new** terminal tab and check
```bash
z --help >/dev/null && echo zoxide ok   # smart cd
which npm                               # expect /opt/homebrew/bin/npm
```

Notes:
- Every tool line is guarded (`command -v` / `[ -f ]`), so the file can be copied before the tools are installed. Each feature turns on once its tool exists, with no errors before that.
- Homebrew is assumed at `/opt/homebrew` (the Apple Silicon default).
- Put machine-only settings in `~/.claude/claude.local.zsh`. It's sourced if present and isn't tracked in the repo.
- Keyboard: **Ctrl-R** fuzzy history search, **Ctrl-T** insert file path, **Alt-C** cd into a subfolder (needs Option as Alt, step 4), **→** accept the grey suggestion, and a leading space keeps a command out of history.

---

## 4. Ghostty

> Needs: Homebrew (step 1), this repo (step 2)

1. Install
```bash
brew install --cask ghostty
```

2. Copy the config ([home/.config/ghostty/config](home/.config/ghostty/config))
```bash
mkdir -p ~/.config/ghostty && cp home/.config/ghostty/config ~/.config/ghostty/config
```
   It sets the theme (auto light/dark), native tabs, copy-on-select, paste protection, clickable URLs, notifications, and **Option as Alt** (needed for Alt-C in fzf). Alternative themes are listed at the bottom, commented out.

3. Reload config anytime with **Cmd+Shift+,** (no restart needed)

Shortcuts:

| Shortcut | What it does |
|---|---|
| Cmd+D | Split pane right |
| Cmd+Shift+D | Split pane down |
| Cmd+[ / Cmd+] | Move focus between panes |
| Cmd+T | New tab |
| Cmd+1, Cmd+2, … | Jump to tab by number |
| Cmd+W | Close current pane/tab |
| Cmd+N | New window |
| Cmd+, | Open config file in editor |
| Cmd+Shift+, | Reload config |
| Cmd+click | Open URL |

To try another theme, browse the built-in list with `ghostty +list-themes`, then set `theme = dark:<Dark>, light:<Light>` in the config.

---

## 5. Keyboard layout

> Needs: Homebrew (step 1), this repo (step 2)
> Reference: [Keyboard layout](canary-extend-layout.svg) — Canary (matrix) on U.S. QWERTY, with Extend layer (Caps Lock): IJKL arrows, symbol grid, Space→Backspace, and Extend+⌘ physical-position rescues for Z/X/C/V

Pick **one** of the two options. Both give the same layout. Running both at once remaps every key twice.

| | 5A. Karabiner | 5B. Hammerspoon |
|---|---|---|
| Use on | Personal machines | Managed/work machines where Karabiner's driver is blocked |
| How it works | Driver extension (virtual keyboard) | `hidutil` + an event tap (needs only Accessibility) |
| Password fields | Canary works | **Types QWERTY** (see 5B notes) |
| Source file | [karabiner-canary-final.json](karabiner-canary-final.json) (source of truth) | [home/.hammerspoon/init.lua](home/.hammerspoon/init.lua) (port of the JSON) |

### 5A. Karabiner

1. Install
```bash
brew install --cask karabiner-elements
```

2. Open Karabiner-Elements and follow its first-launch prompts: allow the **driver extension** and **Input Monitoring** in System Settings. When asked for the keyboard type, choose **ANSI**.

3. Copy the layout rule ([karabiner-canary-final.json](karabiner-canary-final.json)) into Karabiner's import folder
```bash
mkdir -p ~/.config/karabiner/assets/complex_modifications
cp karabiner-canary-final.json ~/.config/karabiner/assets/complex_modifications/
```

4. Optional: validate it with Karabiner's own linter (expect `ok`)
```bash
"/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" \
  --lint-complex-modifications ~/.config/karabiner/assets/complex_modifications/karabiner-canary-final.json
```

5. Enable it: Karabiner-Elements → **Complex Modifications** → **Add predefined rule** → "Canary (matrix) + Extend + Symbol Grid (left-shifted) + Chain-dot" → **Enable**

Notes:
- The file uses Karabiner's import format: a `title` plus a `rules` list (one rule, 61 manipulators). A file without a `rules` list shows up with nothing to enable, and the linter still says `ok`, so keep the wrapper.
- Karabiner copies the rule into `~/.config/karabiner/karabiner.json` when you click Enable. Editing the repo file later doesn't change the live config. Re-import, or edit the live rule directly.
- Device-specific settings (e.g., `ignore_vendor_events` for a Logitech keyboard) aren't in the repo. Set them in the **Devices** tab if needed.

### 5B. Hammerspoon

Hammerspoon can't hold Caps Lock as a layer key, so the config splits the job in two:
1. `hidutil`, Apple's built-in tool, remaps Caps Lock to F18 in the keyboard driver. Nothing to install.
2. An event tap in `init.lua` sees every key press, swallows the physical key, and posts the Canary key instead. While F18 (Caps Lock) is held, the Extend layer is checked first.

The config applies the `hidutil` mapping itself every time it loads, so there is no LaunchAgent to install.

1. Install
```bash
brew install --cask hammerspoon
```

2. Back up any existing config, then copy the reference ([home/.hammerspoon/init.lua](home/.hammerspoon/init.lua))
```bash
mkdir -p ~/.hammerspoon
cp ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.bak 2>/dev/null
cp home/.hammerspoon/init.lua ~/.hammerspoon/init.lua
```

3. Open Hammerspoon and grant **Accessibility** when prompted (System Settings → Privacy & Security → Accessibility). If it also asks for **Input Monitoring**, allow that too. In Hammerspoon's **Preferences**, tick **Launch Hammerspoon at login**.

4. Reload: menu bar icon → **Reload Config**. Expect a "Canary layout loaded" alert. If it doesn't appear, open menu bar icon → **Console** to see the error.

5. Check
```bash
hidutil property --get UserKeyMapping   # expect Src 0x700000039 → Dst 0x70000006D
```
   Then type on the physical `A S D F` keys (expect `crst`), and hold Caps Lock + `J` (expect the cursor to move left).

Notes:
- **The JSON stays the source of truth.** To change the layout, edit `karabiner-canary-final.json` first, then mirror the change in the `BASE` / `EXTEND` / `RESCUE` tables in `init.lua`. Key names in the Lua match Karabiner's `key_code` names, so you can compare them line by line.
- **Password fields type QWERTY.** When a password field or a terminal password prompt (e.g., `sudo`) has focus, macOS turns on *Secure Input*, which hides keystrokes from all event taps. Hammerspoon never sees those keys, so you get plain QWERTY there. Type passwords by QWERTY position. Karabiner doesn't have this problem because it remaps inside the driver.
- Tapping Caps Lock alone (under 1 second, no other key pressed) still toggles Caps Lock, as `to_if_alone` does in Karabiner.
- One small difference: the Extend+⌘ rescues accept either ⌘ key. Karabiner's rule only matches left ⌘.
- If **System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys** remaps Caps Lock, set it back to Caps Lock. Otherwise the `hidutil` mapping never sees it.
- Undo everything: quit Hammerspoon, then run `hidutil property --set '{"UserKeyMapping":[]}'`. The mapping also clears on reboot if Hammerspoon doesn't start.

---

## 6. Claude Code

> Needs: this repo (step 2), `~/.local/bin` on PATH (step 3)

1. Install with the native installer. It puts `claude` in `~/.local/bin`.
```bash
curl -fsSL https://claude.ai/install.sh | bash
```
   To read the script before running it: `curl -fsSL https://claude.ai/install.sh | less`

2. Copy the settings (back up any existing file first)
```bash
mkdir -p ~/.claude/output-styles
cp ~/.claude/settings.json ~/.claude/settings.json.bak 2>/dev/null
cp home/.claude/settings.json ~/.claude/settings.json
```
   [home/.claude/settings.json](home/.claude/settings.json) sets plan mode as the default, the permission allow/deny/ask lists, the status line, the output style, high effort, and voice.

3. Copy the output style (the settings file refers to it by name)
```bash
cp home/.claude/output-styles/pedagogical.md ~/.claude/output-styles/
```

4. Copy the status line script
```bash
cp home/.claude/statusline.sh ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
```
   Shows: `📁 cwd | 🤖 model (effort) | context % | ↑sent ↓recv | 🌿 branch +ins/-del | 🔥 cache | 💰 cost | 5h/7d limits`. It's a self-owned bash script, so nothing to install and no third-party code. It needs only `jq` (ships with macOS 15+ at `/usr/bin/jq`) and `git`.

5. Verify the status line by piping in a sample payload
```bash
echo '{"cwd":"'"$PWD"'","model":{"display_name":"Opus 5"},"effort":{"level":"high"},"context_window":{"used_percentage":42},"cost":{"total_cost_usd":1.23}}' | ~/.claude/statusline.sh
```
   Expect one rendered line and exit 0. Cache, token and rate-limit segments only appear once Claude Code has made an API call, so they're absent here.

6. Start Claude Code and sign in
```bash
claude
```

Notes:
- To change status line segments, edit the script directly, or run `/statusline` inside Claude Code to regenerate it.
- Fields are joined with `0x1F`, not tab: bash `read` collapses runs of whitespace IFS characters, so an empty field would shift every later field left.

---

## 7. Display (HiDPI Fix) — optional

> Needs: Homebrew (step 1). Only for external monitors with scaling issues.

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
