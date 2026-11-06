// USAGE
//   Run:    canary          (zsh alias for ~/canary_extend/canary_extend; add & to background it)
//   Stop:   Ctrl-C, or `pkill canary_extend` — Caps Lock is restored on exit
//   Build:  swiftc -O canary_extend.swift -o canary_extend && codesign -s - -f canary_extend
//   Needs:  Canary.keylayout selected as the input source; Accessibility + Input Monitoring for the app that launches it (Terminal)
//   Note:   rebuilding changes the ad-hoc signature, which can reset the permissions above
//
// canary_extend — minimal Extend layer. Canary.keylayout does all typing, including the Extend symbols.
// Hold Caps Lock (hidutil -> F18):
//   * symbol keys get an Option flag; the layout's Option map outputs the symbol
//   * IJKL -> arrows, Space -> Delete, Return -> end of line + ';'
// Tap Caps Lock alone (no other key while held): toggles real Caps Lock
import Cocoa
import IOKit.hidsystem

let F18: Int64 = 79
let MARK: Int64 = 0x4B4D5348
let symbolKeys: Set<Int64> = [12, 13, 14, 15, 0, 1, 2, 3, 6, 7, 8, 9, 46, 35]  // q w e r a s d f z x c v m p
// Extend+Cmd rescue: every letter key except IJKL keeps its QWERTY letter (e.g. Cmd+A = Select All). Value = physical key that types that letter in Canary.
let rescue: [Int64: Int64] = [0: 41, 11: 5, 8: 0, 2: 8, 14: 40, 3: 4, 5: 9, 4: 46, 46: 45, 45: 38, 31: 34, 35: 15, 12: 11, 15: 1, 1: 2, 17: 3, 32: 31, 9: 7, 13: 12, 7: 32, 16: 14, 6: 16]
let arrows: [Int64: Int64] = [34: 126, 38: 123, 40: 125, 37: 124]              // i j k l -> up left down right
let SPACE: Int64 = 49, DELETE: Int64 = 51, RETURN: Int64 = 36, RIGHT: Int64 = 124, SEMICOLON: Int64 = 35  // physical P types ';' in Canary

var extend = false
var used = false  // another key was pressed during this Caps hold, so it's not a tap
var held: [Int64: (code: Int64, flags: CGEventFlags)] = [:]  // key-down rewrite, reused on key-up
var tap: CFMachPort?

func post(_ code: Int64, down: Bool, flags: CGEventFlags) {
  guard let e = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: down) else { return }
  e.flags = flags
  e.setIntegerValueField(.eventSourceUserData, value: MARK)
  e.post(tap: .cgSessionEventTap)
}

let callback: CGEventTapCallBack = { _, type, event, _ in
  if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
    extend = false; held = [:]
    if let t = tap { CGEvent.tapEnable(tap: t, enable: true) }
    return Unmanaged.passUnretained(event)
  }
  if event.getIntegerValueField(.eventSourceUserData) == MARK { return Unmanaged.passUnretained(event) }

  let down = type == .keyDown
  let code = event.getIntegerValueField(.keyboardEventKeycode)
  if code == F18 {
    if down { if !extend { used = false } }       // ignore key-repeat while held
    else if extend && !used { toggleCapsLock() }  // tap alone
    extend = down; return nil
  }

  var flags = event.flags
  var out = code

  if down {
    guard extend else { return Unmanaged.passUnretained(event) }
    used = true
    if code == RETURN {
      post(RIGHT, down: true,  flags: [.maskCommand, .maskSecondaryFn]); post(RIGHT, down: false, flags: [.maskCommand, .maskSecondaryFn])
      post(SEMICOLON, down: true, flags: []);                           post(SEMICOLON, down: false, flags: [])
      return nil
    }
    let cmdOnly = flags.contains(.maskCommand) && flags.isDisjoint(with: [.maskAlternate, .maskControl])
    if let r = rescue[code], cmdOnly { out = r }
    else if let a = arrows[code] { out = a; flags.insert(.maskSecondaryFn) }
    else if code == SPACE { out = DELETE }
    else if symbolKeys.contains(code), !flags.contains(.maskCommand), !flags.contains(.maskControl) { flags.insert(.maskAlternate) }
    held[code] = (out, flags)
  } else if let h = held.removeValue(forKey: code) {
    out = h.code; flags = h.flags
  }

  event.setIntegerValueField(.keyboardEventKeycode, value: out)
  event.flags = flags
  return Unmanaged.passUnretained(event)
}

func hidutil(_ json: String) {
  let p = Process()
  p.executableURL = URL(fileURLWithPath: "/usr/bin/hidutil")
  p.arguments = ["property", "--set", json]
  p.standardOutput = FileHandle.nullDevice
  try? p.run(); p.waitUntilExit()
}
func capsToF18()   { hidutil(#"{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771181}]}"#) }
func restoreCaps() { hidutil(#"{"UserKeyMapping":[]}"#) }
func toggleCapsLock() {
  let svc = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(kIOHIDSystemClass))
  defer { IOObjectRelease(svc) }
  var conn: io_connect_t = 0
  guard IOServiceOpen(svc, mach_task_self_, UInt32(kIOHIDParamConnectType), &conn) == KERN_SUCCESS else { return }
  defer { IOServiceClose(conn) }
  var on = false
  IOHIDGetModifierLockState(conn, Int32(kIOHIDCapsLockState), &on)
  IOHIDSetModifierLockState(conn, Int32(kIOHIDCapsLockState), !on)
}
func err(_ s: String) { FileHandle.standardError.write((s + "\n").data(using: .utf8)!) }

if !CGPreflightListenEventAccess() { _ = CGRequestListenEventAccess(); err("Input Monitoring not granted.") }
if !AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary) { err("Accessibility not granted.") }

let mask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
guard let t = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
                                eventsOfInterest: CGEventMask(mask), callback: callback, userInfo: nil) else {
  err("Could not create event tap (missing permissions?)."); exit(1)
}
tap = t
CFRunLoopAddSource(CFRunLoopGetCurrent(), CFMachPortCreateRunLoopSource(nil, t, 0), .commonModes)

capsToF18()
atexit { restoreCaps() }
var sources: [DispatchSourceSignal] = []
for s in [SIGINT, SIGTERM, SIGHUP] {
  signal(s, SIG_IGN)
  let src = DispatchSource.makeSignalSource(signal: s, queue: .main)
  src.setEventHandler { restoreCaps(); exit(0) }
  src.resume(); sources.append(src)
}
err("canary_extend running. Ctrl-C quits and restores Caps Lock.")
CFRunLoopRun()
