# Remote Terminal Access: Complete Guide

## What This Solves

Access your Mac's terminal from your iPhone and seamlessly continue your work across devices - start on your Mac, continue on your phone at a coffee shop, pick up on your Mac later. All your terminal sessions, running programs, and context preserved.

## The Technology Stack

```
Layer 0: NETWORKING
  └── Tailscale - Makes your Mac accessible from anywhere

Layer 1: CONNECTION PROTOCOL  
  └── Mosh - Auto-reconnects when switching WiFi ↔ cellular

Layer 2: CLIENT APP (iPhone)
  └── Termius - SSH/Mosh client for iPhone

Layer 3: SESSION MANAGER (Mac)
  └── Zellij - Keeps terminal sessions alive and organized
```

**Why each layer matters:**
- **Tailscale**: Without it, you can only connect from home WiFi
- **Mosh**: Handles network transitions smoothly (alternative: SSH)
- **Termius**: The app you actually use on your iPhone (alternative: NeoServer, Secure ShellFish)
- **Zellij**: Keeps work alive even when disconnected (alternative: tmux, screen)

## Initial Setup

### 1. Install Tailscale (Both Devices)

**Mac:**
- Download from tailscale.com and install
- Sign in (Google, GitHub, etc.)
- Note your Tailscale IP from menu bar (looks like `100.x.x.x`)

**iPhone:**
- Install Tailscale from App Store
- Sign in with same account
- Keep app running in background

### 2. Install Software on Mac

```bash
# Install Mosh and Zellij
brew install mosh
brew install zellij
```

### 3. Enable Remote Login on Mac

System Settings > General > Sharing > Remote Login (turn ON)

### 4. Prevent Mac Sleep (for 24/7 access)

System Settings > Energy > "Prevent automatic sleeping when display is off"

Optional: Use `caffeinate` command temporarily when needed

### 5. Configure Termius on iPhone

1. Install Termius from App Store
2. Add new host:
   - **Hostname**: Your Mac's Tailscale IP (100.x.x.x)
   - **Username**: Your Mac username
   - **Protocol**: Select **Mosh** (not SSH)
   - **Authentication**: Password or SSH key
3. Save connection

## Core Concepts

### Understanding Background Processes

When you **detach** from Zellij, it becomes a background process (daemon) that runs independently of Terminal.app:

```
GUI Layer
  - Terminal.app (can close safely after detaching)
  
User Session Layer  
  - Zellij (runs here after detaching)
  - SSH server
  - Other background processes
  
System Layer
  - macOS itself
```

**Key insight**: Detached Zellij is NOT tied to Terminal anymore. It's a standalone process owned by your user account.

### The Detach Workflow

**NOT detached** = Zellij is a child of Terminal
- Closing Terminal kills Zellij ❌

**Detached** = Zellij is independent
- Closing Terminal is safe ✅
- Locking Mac is safe ✅
- Another user logging in is safe ✅

## Essential Workflows

### Starting a Session on Mac

```bash
# Start with a meaningful name
zellij --session work

# Or for a specific project
zellij --session backend-dev

# Do your work...

# ALWAYS detach before closing Terminal
Ctrl + o, then d

# Now safe to:
# - Close Terminal
# - Lock Mac  
# - Let another user log in
```

### Continuing from iPhone

1. Open Termius
2. Connect to your Mac (tap saved connection)
3. Once connected:
```bash
zellij attach work
```

Your session appears exactly as you left it!

### Switching Between Devices

**Mac → iPhone:**
```bash
# On Mac:
Ctrl + o, then d  # Detach

# On iPhone (via Termius):
zellij attach work
```

**iPhone → Mac:**
```bash
# On iPhone: Just close Termius
# Mosh and Zellij keep running

# On Mac:
zellij attach work
```

### Session Management

```bash
# List all running sessions
zellij list-sessions

# Attach to specific session  
zellij attach backend-dev

# Create or attach (creates if doesn't exist)
zellij attach -c mobile-work

# Delete a session (when truly done)
zellij delete-session old-project

# Kill all sessions
zellij kill-all-sessions
```

### Renaming Sessions

**Method 1: From inside session (easiest)**
1. `Ctrl + o` (Session mode)
2. `w` (opens session manager)
3. `Ctrl + r` (rename)
4. Type new name
5. Enter

**Method 2: From command line**
```bash
zellij action rename-session my-new-name
```

## Zellij Essentials

### The Mode System

Zellij uses **modes** instead of complex key combinations:

- **BASE** - Normal terminal use (default)
- **Pane** - Manage splits (`Ctrl + p`)
- **Tab** - Manage tabs (`Ctrl + t`)
- **Scroll** - View history (`Ctrl + s`)
- **Session** - Detach/manage (`Ctrl + o`)

**How it works**: Press a mode key, do your action, automatically return to BASE.

### Key Commands

**Pane Management:**
```
Ctrl + p, then n       New pane (split)
Ctrl + p, then x       Close current pane
Ctrl + p, then f       Toggle fullscreen

Navigation (iPhone-friendly):
Ctrl + p, then h       Move left
Ctrl + p, then j       Move down  
Ctrl + p, then k       Move up
Ctrl + p, then l       Move right
```

**Tab Management:**
```
Ctrl + t, then n       New tab
Ctrl + t, then x       Close current tab
Ctrl + t, then h       Previous tab
Ctrl + t, then l       Next tab
Ctrl + t, then r       Rename tab
```

**Scrollback (important on iPhone):**
```
Ctrl + s               Enter scroll mode
j / k                  Scroll down / up
Page Up/Down           Scroll by page
ESC                    Exit scroll mode
```

Note: Mosh doesn't have scrollback, so use Zellij's scroll mode!

**Session Management:**
```
Ctrl + o, then d       Detach (session keeps running)
Ctrl + o, then w       Session manager window
Ctrl + o, then q       Quit Zellij (kills session)
```

### iPhone-Specific Tips

**No arrow keys? Use vim keys:**
- `h` = left
- `j` = down
- `k` = up
- `l` = right

**Or enable swipe gestures in Termius:**
- Swipe on terminal area to navigate
- Check Termius keyboard settings for arrow key bar

## Common Scenarios

### Locking Your Mac

**What happens:**
- ✅ Zellij keeps running
- ✅ All programs continue
- ✅ Can connect from iPhone
- ✅ User session stays active

**Best practice:**
```bash
# Before locking:
Ctrl + o, then d
# Lock: Cmd + Ctrl + Q
```

### Another User Logs In (Fast User Switching)

**What happens:**
- ✅ Your session runs in background
- ✅ Zellij keeps running under YOUR account
- ✅ iPhone connects to YOUR account specifically
- ✅ Other user's activity doesn't affect you

**Why it works:**
- macOS runs both sessions simultaneously
- SSH/Mosh connects to your user, not the GUI user
- Your processes are isolated from other users

### Network Transitions (WiFi ↔ Cellular)

**What happens:**
- ⏳ Mosh shows "waiting for connection..."
- ✅ Auto-reconnects within seconds
- ✅ Zellij unaffected
- ✅ All programs keep running
- ✅ You see exactly what you had

**This is why Mosh is better than SSH for mobile!**

### Phone Battery Dies / Termius Closes

**What happens:**
- ❌ Mosh connection lost
- ✅ Zellij session keeps running on Mac

**Recovery:**
1. Charge phone / reopen Termius
2. Reconnect to Mac
3. `zellij attach work`
4. Everything exactly as you left it

### Mac Goes to Sleep

**What happens:**
- ⏸️ Everything pauses
- ❌ Can't connect (Mac offline)
- ✅ When Mac wakes, everything resumes

**Prevention:**
System Settings > Energy > Prevent automatic sleeping

### Terminal Closes Without Detaching

**What happens:**
- ❌ Kills Zellij session
- ❌ All programs stop
- ❌ Work lost

**Recovery:**
None. Session is gone. Always detach first!

**This is why detaching is critical!**

## Critical Best Practices

### ✅ Rule #1: ALWAYS Detach Before Closing

**WRONG:**
```bash
# Working in Zellij...
# [Close Terminal]
# ❌ Everything dies!
```

**RIGHT:**
```bash
# Working in Zellij...
Ctrl + o, then d  # Detach first
# [Close Terminal]  
# ✅ Everything keeps running
```

**Make it muscle memory**: `Ctrl + o, d` before closing anything.

### ✅ Use Named Sessions

**Good:**
```bash
zellij --session backend-api
zellij --session client-frontend  
zellij --session devops-scripts
```

**Bad:**
```bash
zellij  # Creates random name like "fascinating-capsicum"
```

Named sessions are easier to:
- Remember what's what
- Attach to later
- Communicate with teammates

### ✅ One Session Per Project/Context

Don't put everything in one session. Organize by:
- Project: `--session mobile-app`
- Task: `--session database-migration`
- Client: `--session acme-corp`
- Environment: `--session prod-monitoring`

### ✅ Use Tabs and Panes Within Sessions

**Within each session:**
- **Tabs** for different tasks (server, logs, git, etc.)
- **Panes** for side-by-side viewing (code + output)

Example layout in "backend-api" session:
- Tab 1: Development (pane: server, pane: logs)
- Tab 2: Git operations
- Tab 3: Database console

### ✅ Keep Mac Available

For reliable remote access:
1. Prevent sleep (Energy settings)
2. Stable internet connection
3. Tailscale running and logged in
4. Remote Login enabled

### ✅ Check Sessions Before Creating New Ones

```bash
# Before starting work:
zellij list-sessions

# You might already have what you need!
zellij attach existing-session
```

Prevents session clutter.

## Troubleshooting

### Can't Connect from iPhone

**Checklist:**
1. ✓ Tailscale running on both devices?
2. ✓ Both signed into same Tailscale account?
3. ✓ Mac's Remote Login enabled?
4. ✓ Mac awake and online?
5. ✓ Using Tailscale IP (100.x.x.x) in Termius?

**Test connectivity:**
```bash
# On iPhone via another terminal app:
ping 100.x.x.x  # Your Mac's Tailscale IP
```

### "Session Not Found"

**Cause:** Session was killed (Terminal closed without detaching)

**Check:**
```bash
zellij list-sessions
# If empty, session is gone
```

**Recovery:** Start fresh
```bash
zellij --session work
```

**Prevention:** Always detach!

### Mosh Won't Connect

**Try SSH first:**
- Change Termius to use SSH protocol
- If SSH works but Mosh doesn't: firewall issue
- If neither works: connectivity issue

**Mosh requirements:**
- UDP ports 60000-61000 open
- Some corporate networks block UDP

**Fallback:** Use SSH instead of Mosh
- Loses auto-reconnect feature
- But everything else works the same

### Keybindings Don't Work on iPhone

**Solutions:**
1. Use `h/j/k/l` instead of arrow keys
2. Enable Termius swipe gestures
3. Add arrow keys to Termius keyboard bar
4. Use Termius keyboard customization

### Zellij Feels Slow/Laggy

**Common causes:**
1. Slow network connection
2. Mosh server overwhelmed
3. Too many panes open

**Solutions:**
- Close unused panes/tabs
- Check network speed
- Restart Mosh connection
- Consider switching to SSH if on stable network

### Session Won't Detach

**If `Ctrl + o, d` doesn't work:**
1. Check you're in BASE mode (press ESC first)
2. Try `Ctrl + o, q` to quit entirely
3. Force kill: `zellij kill-session <name>`

## Advanced Tips

### Auto-Start Zellij on Login

Add to `~/.zshrc` or `~/.bashrc`:
```bash
if [[ -z "$ZELLIJ" ]]; then
    if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
        zellij attach -c default
    fi
fi
```

This auto-attaches to "default" session (or creates it) when opening terminal.

### Custom Keybindings

Edit `~/.config/zellij/config.kdl` to customize shortcuts. See Zellij docs for details.

### Layouts

Save common pane/tab arrangements:
```bash
zellij --layout my-layout.kdl
```

Useful for projects with standard setup (server + logs + editor).

### Sharing Sessions

Multiple users can attach to same session:
```bash
# User 1:
zellij --session pair-programming

# User 2 (different device):
zellij attach pair-programming
```

Both see and control the same session!

## Quick Reference

### Daily Commands
```bash
# Start/create session
zellij --session <name>

# List sessions  
zellij list-sessions

# Attach to session
zellij attach <name>

# Detach (CRITICAL)
Ctrl + o, then d

# Session manager
Ctrl + o, then w
```

### Pane Commands (iPhone-friendly)
```bash
Ctrl + p, n        New pane
Ctrl + p, h/j/k/l  Navigate  
Ctrl + p, x        Close pane
Ctrl + p, f        Fullscreen toggle
```

### Tab Commands
```bash
Ctrl + t, n        New tab
Ctrl + t, h/l      Switch tabs
Ctrl + t, x        Close tab
Ctrl + t, r        Rename tab
```

### Scroll Mode
```bash
Ctrl + s           Enter scroll mode
j/k                Scroll
ESC                Exit scroll mode
```

## The Complete Workflow

### Morning (Start on Mac)
```bash
# At home
zellij --session work

# Set up your workspace
Ctrl + p, n  # Split panes
Ctrl + t, n  # Multiple tabs

# Start servers, open files, etc.

# Before leaving:
Ctrl + o, d  # DETACH
# Lock Mac or leave it running
```

### Commute (Continue on iPhone)
```bash
# Open Termius on iPhone
# Connect to Mac
zellij attach work

# Continue exactly where you left off
# Edit files, check logs, restart services
# Everything works!

# When arriving at destination:
# Just close Termius (no need to detach)
```

### At Office (Back to Mac)
```bash
# Open Terminal on Mac
zellij attach work

# Same session, all context preserved
# No "where was I?" moments
# Just continue working
```

### Evening (From Anywhere)
```bash
# From home, coffee shop, wherever
# iPhone or Mac - doesn't matter
zellij attach work

# Your workspace follows you everywhere
```

## Why This Setup is Powerful

1. **No context switching overhead**: Your work environment persists
2. **Device flexibility**: Start anywhere, continue anywhere
3. **Network resilience**: Mosh handles transitions seamlessly  
4. **No "rebuilding environment"**: Everything stays running
5. **Multi-device workflow**: Same session on Mac and iPhone
6. **Background processes**: Long-running tasks continue
7. **Organization**: Named sessions keep projects separate

## Key Insights Learned

### About Background Processes
- Detaching makes Zellij independent of Terminal
- User sessions stay active when locked or when others log in
- macOS keeps multiple user sessions running simultaneously

### About Layering
- Each layer solves a specific problem
- Can mix and match (SSH instead of Mosh, tmux instead of Zellij)
- But recommended stack is well-tested together

### About Mobile Terminal Work
- Terminal work is MUCH more efficient than VNC/Remote Desktop
- Text-based protocols work great even on slow connections
- Proper session management is key to mobile productivity

### About Workflows
- Detaching is not optional - it's essential
- Named sessions prevent confusion
- One session per project keeps work organized
- The magic is in seamless device switching

## Remember

**The Golden Rule:** 
Always detach (`Ctrl + o, d`) before closing Terminal or locking your Mac.

**The Magic Moment:**
When you realize you can start work on your Mac, continue on your phone while commuting, and pick up on any device later - all in the same session with zero setup.

**The Time Saver:**
No more "let me SSH in and rebuild my environment." It's already there, exactly as you left it.

Welcome to persistent, location-independent terminal work! 🚀
