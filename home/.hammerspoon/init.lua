-- Canary (matrix) + Extend layer, for machines where Karabiner isn't allowed.
--
-- Port of karabiner-canary-final.json. That JSON is the source of truth:
-- change it first, then mirror the change here.
--
-- How it works
--   1. hidutil (Apple's built-in tool) remaps Caps Lock to F18 in the keyboard
--      driver. Hammerspoon can't use Caps Lock as a hold-down layer key, but it
--      can watch an ordinary key like F18.
--   2. One event tap sees every key press. It swallows the physical key and
--      posts the Canary key instead. While F18 (Caps Lock) is held, the Extend
--      layer is checked first, the same order Karabiner uses.
--
-- Shown in the Hammerspoon console (menu bar icon → Console) if anything fails.

-- Physical key positions: macOS ANSI virtual keycodes (from Carbon's Events.h).
-- Named after Karabiner's key_code values so each line can be checked against the JSON.
local K = {
  a = 0x00, s = 0x01, d = 0x02, f = 0x03, h = 0x04, g = 0x05, z = 0x06, x = 0x07,
  c = 0x08, v = 0x09, b = 0x0B, q = 0x0C, w = 0x0D, e = 0x0E, r = 0x0F, y = 0x10,
  t = 0x11, o = 0x1F, u = 0x20, i = 0x22, p = 0x23, l = 0x25, j = 0x26, k = 0x28,
  n = 0x2D, m = 0x2E,
  ["1"] = 0x12, ["7"] = 0x1A, ["8"] = 0x1C, ["9"] = 0x19, ["0"] = 0x1D,
  equal_sign = 0x18, hyphen = 0x1B, open_bracket = 0x21, close_bracket = 0x1E,
  semicolon = 0x29, backslash = 0x2A, comma = 0x2B, slash = 0x2C, period = 0x2F,
  return_or_enter = 0x24, spacebar = 0x31, delete_or_backspace = 0x33,
  left_arrow = 0x7B, right_arrow = 0x7C, down_arrow = 0x7D, up_arrow = 0x7E,
  f18 = 0x4F,
}

-- An output key plus any modifiers it adds, e.g. key(K["9"], "shift") is "(".
local function key(code, ...) return { code = code, mods = { ... } } end

-- Base layer: Canary letters on QWERTY positions. Applies with any modifiers held,
-- so shortcuts follow the letters (physical Q types W, so Cmd+physical-Q is Cmd+W).
local BASE = {
  [K.q] = key(K.w), [K.w] = key(K.l), [K.e] = key(K.y), [K.r] = key(K.p), [K.t] = key(K.k),
  [K.y] = key(K.z), [K.u] = key(K.x), [K.i] = key(K.o), [K.o] = key(K.u), [K.p] = key(K.semicolon),
  [K.a] = key(K.c), [K.s] = key(K.r), [K.d] = key(K.s), [K.f] = key(K.t), [K.g] = key(K.b),
  [K.h] = key(K.f), [K.j] = key(K.n), [K.k] = key(K.e), [K.l] = key(K.i), [K.semicolon] = key(K.a),
  [K.z] = key(K.j), [K.x] = key(K.v), [K.c] = key(K.d), [K.v] = key(K.g), [K.b] = key(K.q),
  [K.n] = key(K.m), [K.m] = key(K.h), [K.comma] = key(K.slash), [K.period] = key(K.comma),
  [K.slash] = key(K.period),
}

-- Extend layer (Caps Lock held). Keys not listed fall through to BASE, as in Karabiner.
local EXTEND = {
  -- Navigation and editing
  [K.i] = key(K.up_arrow), [K.j] = key(K.left_arrow),
  [K.k] = key(K.down_arrow), [K.l] = key(K.right_arrow),
  [K.spacebar] = key(K.delete_or_backspace),
  [K.m] = key(K.period),
  -- Enter: jump to end of line, then type ";"
  [K.return_or_enter] = { macro = { key(K.right_arrow, "cmd"), key(K.semicolon) } },
  -- Symbol grid (shifted left): loners Q/A/Z, openers W/S/X, closers E/D/C, loners R/F/V
  [K.q] = key(K["1"], "shift"),             -- !
  [K.w] = key(K.open_bracket, "shift"),     -- {
  [K.e] = key(K.close_bracket, "shift"),    -- }
  [K.r] = key(K["7"], "shift"),             -- &
  [K.a] = key(K.hyphen, "shift"),           -- _
  [K.s] = key(K["9"], "shift"),             -- (
  [K.d] = key(K["0"], "shift"),             -- )
  [K.f] = key(K.equal_sign),                -- =
  [K.z] = key(K["8"], "shift"),             -- *
  [K.x] = key(K.open_bracket),              -- [
  [K.c] = key(K.close_bracket),             -- ]
  [K.v] = key(K.backslash, "shift"),        -- |
  [K.p] = key(K.equal_sign),                -- =
}

-- Extend + Cmd + one of these sends Cmd + the key's own QWERTY letter, so
-- undo/cut/copy/paste/find/save/new/quit/new-tab stay at their usual positions.
-- Only Cmd may be held (plus Shift for Z, which gives redo).
local RESCUE = {
  [K.z] = true, [K.x] = true, [K.c] = true, [K.v] = true, [K.f] = true,
  [K.s] = true, [K.n] = true, [K.q] = true, [K.t] = true,
}
local RESCUE_ALLOWS_SHIFT = { [K.z] = true }

-- Karabiner's default to_if_alone timeout: a Caps Lock tap shorter than this,
-- with no other key pressed, toggles Caps Lock.
local ALONE_TIMEOUT = 1.0

local LETTERS = {}
for ch in ("abcdefghijklmnopqrstuvwxyz"):gmatch(".") do LETTERS[K[ch]] = true end

local MARK = 0x43414E52  -- tags the events we post, so the tap never remaps its own output
local MOD_NAMES = { "cmd", "alt", "shift", "ctrl", "fn" }
local types = hs.eventtap.event.types
local props = hs.eventtap.event.properties

local extend, extendUsed, extendDownAt = false, false, 0
local capsOn = hs.hid.capslock.get()
local held = {}  -- physical keycode -> what its keyDown sent, so its keyUp releases the same key

-- Build one posted key event: the original's modifiers, plus the mapping's own.
local function synth(k, flags, isDown, isRepeat)
  local f = {}
  for _, m in ipairs(MOD_NAMES) do if flags[m] then f[m] = true end end
  for _, m in ipairs(k.mods) do f[m] = true end
  -- Posted events don't carry the Caps Lock state, so add Shift to plain letters ourselves.
  if capsOn and LETTERS[k.code] and not (f.cmd or f.ctrl or f.alt) then f.shift = true end
  local ev = hs.eventtap.event.newKeyEvent({}, k.code, isDown)
  ev:setFlags(f)
  ev:setProperty(props.eventSourceUserData, MARK)
  if isRepeat then ev:setProperty(props.keyboardEventAutorepeat, 1) end
  return ev
end

local function onlyCmd(flags, allowShift)
  return flags.cmd and not flags.alt and not flags.ctrl and not flags.fn
    and (allowShift or not flags.shift)
end

local function resolve(code, flags)
  if extend then
    if RESCUE[code] and onlyCmd(flags, RESCUE_ALLOWS_SHIFT[code]) then return { passthrough = true } end
    if EXTEND[code] then return EXTEND[code] end
  end
  return BASE[code]
end

local function onKey(e)
  if e:getProperty(props.eventSourceUserData) == MARK then return false end

  local code = e:getKeyCode()
  local isDown = e:getType() == types.keyDown
  local isRepeat = e:getProperty(props.keyboardEventAutorepeat) ~= 0
  local flags = e:getFlags()

  -- Caps Lock arrives as F18. Holding it turns Extend on; it never types anything itself.
  if code == K.f18 then
    if isDown then
      if not extend then
        extend, extendUsed, extendDownAt = true, false, hs.timer.secondsSinceEpoch()
      end
    else
      extend = false
      if not extendUsed and hs.timer.secondsSinceEpoch() - extendDownAt < ALONE_TIMEOUT then
        capsOn = hs.hid.capslock.set(not capsOn)
      end
    end
    return true
  end

  if isDown then
    if extend then extendUsed = true end
    -- A held key keeps its first meaning while it auto-repeats, even if Extend changes.
    local action = (isRepeat and held[code]) or resolve(code, flags)
    held[code] = action
    if not action or action.passthrough then return false end
    if action.macro then
      if isRepeat then return true end
      local out = {}
      for _, k in ipairs(action.macro) do
        out[#out + 1] = synth(k, flags, true)
        out[#out + 1] = synth(k, flags, false)
      end
      return true, out
    end
    return true, { synth(action, flags, true, isRepeat) }
  end

  -- keyUp: release whatever this key's keyDown sent.
  local action = held[code]
  held[code] = nil
  if not action or action.passthrough then return false end
  if action.macro then return true end
  return true, { synth(action, flags, false) }
end

-- Caps Lock → F18 (HID usage 0x39 → 0x6D). Lasts until reboot, so apply it on every load.
local HIDUTIL = [[/usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}']]
local function mapCapsToF18() hs.execute(HIDUTIL) end
mapCapsToF18()

-- Globals, not locals: Hammerspoon garbage-collects objects nothing refers to,
-- which would silently switch the layout off.
CanaryTap = hs.eventtap.new({ types.keyDown, types.keyUp }, onKey):start()

-- macOS can switch off a slow event tap. Turn it back on if that happens.
CanaryWatchdog = hs.timer.doEvery(5, function()
  if not CanaryTap:isEnabled() then CanaryTap:start() end
end)

-- In case macOS drops the hidutil mapping after sleep or when a keyboard is plugged in, re-apply it.
CanaryWake = hs.caffeinate.watcher.new(function(ev)
  if ev == hs.caffeinate.watcher.systemDidWake or ev == hs.caffeinate.watcher.screensDidUnlock then
    mapCapsToF18()
  end
end):start()
CanaryUsb = hs.usb.watcher.new(function(dev)
  if dev.eventType == "added" then mapCapsToF18() end
end):start()

hs.alert.show("Canary layout loaded")
