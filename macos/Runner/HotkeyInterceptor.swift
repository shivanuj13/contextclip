import Cocoa
import FlutterMacOS

struct HotkeySpec: Equatable {
  var enabled: Bool
  var keyCode: Int64
  var command: Bool
  var shift: Bool
  var option: Bool
  var control: Bool
  var action: String

  static func defaults() -> [HotkeySpec] {
    [
      HotkeySpec(
        enabled: true, keyCode: 9, command: true, shift: true,
        option: false, control: false, action: "contextPaste"
      ),
      HotkeySpec(
        enabled: true, keyCode: 9, command: true, shift: false,
        option: true, control: false, action: "markdownPaste"
      ),
      HotkeySpec(
        enabled: true, keyCode: 9, command: false, shift: false,
        option: true, control: false, action: "showPalette"
      ),
    ]
  }

  func matches(keyCode: Int64, flags: CGEventFlags) -> Bool {
    guard enabled else { return false }
    guard self.keyCode == keyCode else { return false }

    let wantCmd = command
    let wantShift = shift
    let wantOpt = option
    let wantCtrl = control

    let hasCmd = flags.contains(.maskCommand)
    let hasShift = flags.contains(.maskShift)
    let hasOpt = flags.contains(.maskAlternate)
    let hasCtrl = flags.contains(.maskControl)

    return hasCmd == wantCmd
      && hasShift == wantShift
      && hasOpt == wantOpt
      && hasCtrl == wantCtrl
  }
}

final class HotkeyInterceptor {
  private var eventTap: CFMachPort?
  private let channel: FlutterMethodChannel
  private var bindings: [HotkeySpec]

  init(channel: FlutterMethodChannel) {
    self.channel = channel
    self.bindings = HotkeySpec.defaults()
    setupEventTap()
  }

  deinit {
    if let tap = eventTap {
      CGEvent.tapEnable(tap: tap, enable: false)
    }
  }

  func updateBindings(_ specs: [HotkeySpec]) {
    bindings = specs
  }

  func updateBindings(fromMaps maps: [[String: Any]]) {
    var next: [HotkeySpec] = []
    for map in maps {
      guard let action = map["action"] as? String else { continue }
      next.append(
        HotkeySpec(
          enabled: map["enabled"] as? Bool ?? true,
          keyCode: Int64(map["keyCode"] as? Int ?? 9),
          command: map["command"] as? Bool ?? false,
          shift: map["shift"] as? Bool ?? false,
          option: map["option"] as? Bool ?? false,
          control: map["control"] as? Bool ?? false,
          action: action
        )
      )
    }
    if !next.isEmpty {
      bindings = next
    }
  }

  private func setupEventTap() {
    let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
    let observer = Unmanaged.passRetained(self).toOpaque()

    eventTap = CGEvent.tapCreate(
      tap: .cgSessionEventTap,
      place: .headInsertEventTap,
      options: .defaultTap,
      eventsOfInterest: mask,
      callback: { _, type, event, refcon -> Unmanaged<CGEvent>? in
        guard let refcon = refcon else {
          return Unmanaged.passUnretained(event)
        }

        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
          let interceptor = Unmanaged<HotkeyInterceptor>.fromOpaque(refcon).takeUnretainedValue()
          if let tap = interceptor.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
          }
          return Unmanaged.passUnretained(event)
        }

        let interceptor = Unmanaged<HotkeyInterceptor>.fromOpaque(refcon).takeUnretainedValue()
        let flags = event.flags.intersection([
          .maskCommand, .maskShift, .maskAlternate, .maskControl,
        ])
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        for binding in interceptor.bindings {
          if binding.matches(keyCode: keyCode, flags: flags) {
            let method: String
            switch binding.action {
            case "contextPaste":
              method = "triggerContextPaste"
            case "markdownPaste":
              method = "triggerMarkdownPaste"
            case "showPalette":
              method = "triggerShowPalette"
            default:
              continue
            }
            DispatchQueue.main.async {
              interceptor.channel.invokeMethod(method, arguments: nil)
            }
            return nil
          }
        }

        return Unmanaged.passUnretained(event)
      },
      userInfo: observer
    )

    if let tap = eventTap {
      let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
      CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
      CGEvent.tapEnable(tap: tap, enable: true)
    }
  }
}
