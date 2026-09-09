import Cocoa
import FlutterMacOS
import Security

final class BridgeChannel {
  static let name = "com.contextclip.mac/bridge"

  private let channel: FlutterMethodChannel
  private var hotkeyInterceptor: HotkeyInterceptor?
  private var pasteboardPoller: PasteboardPoller?
  private var statusItemController: StatusItemController?
  private weak var window: NSWindow?

  init(messenger: FlutterBinaryMessenger, window: NSWindow) {
    self.window = window
    channel = FlutterMethodChannel(name: Self.name, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call: call, result: result)
    }
    hotkeyInterceptor = HotkeyInterceptor(channel: channel)
    pasteboardPoller = PasteboardPoller(channel: channel)
    statusItemController = StatusItemController(channel: channel)
  }

  var methodChannel: FlutterMethodChannel { channel }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getClipboard":
      result(NSPasteboard.general.string(forType: .string) ?? "")
    case "setClipboard":
      guard let content = call.arguments as? String else {
        result(FlutterError(code: "bad_args", message: "Expected String", details: nil))
        return
      }
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      let ok = pasteboard.setString(content, forType: .string)
      result(ok)
    case "injectPaste":
      hideWindowInternal()
      SyntheticPaste.execute {
        result(true)
      }
    case "hideWindow":
      hideWindowInternal()
      result(true)
    case "showWindow":
      showWindowInternal()
      result(true)
    case "hasAccessibility":
      result(AXIsProcessTrusted())
    case "requestAccessibility":
      result(requestAccessibilityPrompt())
    case "getOrCreateDbKey":
      result(getOrCreateDbKey())
    case "showPasteFeedback":
      guard let args = call.arguments as? [String: Any],
            let label = args["label"] as? String else {
        result(FlutterError(code: "bad_args", message: "Expected feedback map", details: nil))
        return
      }
      let tokensSaved = args["tokensSaved"] as? Int ?? 0
      let redactionCount = args["redactionCount"] as? Int ?? 0
      var parts = [label]
      if tokensSaved > 0 {
        parts.append("−\(tokensSaved) tok")
      }
      if redactionCount > 0 {
        parts.append("\(redactionCount) redacted")
      }
      PasteFeedback.show(message: parts.joined(separator: " · "))
      result(true)
    case "isLaunchAtLoginEnabled":
      result(StatusItemController.isLaunchAtLoginEnabled())
    case "setLaunchAtLogin":
      guard let enabled = call.arguments as? Bool else {
        result(FlutterError(code: "bad_args", message: "Expected Bool", details: nil))
        return
      }
      result(StatusItemController.setLaunchAtLogin(enabled: enabled))
    case "setHotkeys":
      guard let maps = call.arguments as? [[String: Any]] else {
        result(FlutterError(code: "bad_args", message: "Expected hotkey list", details: nil))
        return
      }
      hotkeyInterceptor?.updateBindings(fromMaps: maps)
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func hideWindowInternal() {
    guard let window else { return }
    window.orderOut(nil)
    NSApp.hide(nil)
  }

  private func showWindowInternal() {
    guard let window else { return }
    if let mainWindow = window as? MainFlutterWindow {
      mainWindow.applyMaxSizeForCurrentScreen()
    }
    if let screen = window.screen ?? NSScreen.main {
      let frame = window.frame
      let visible = screen.visibleFrame
      // Keep current size, but clamp into the visible area if needed.
      var width = min(frame.width, visible.width)
      var height = min(frame.height, visible.height)
      width = max(width, MainFlutterWindow.defaultSize.width)
      height = max(height, MainFlutterWindow.defaultSize.height)
      let origin = NSPoint(
        x: visible.midX - width / 2,
        y: visible.midY - height / 2
      )
      window.setFrame(
        NSRect(origin: origin, size: NSSize(width: width, height: height)),
        display: true
      )
    }
    NSApp.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)
  }

  private func requestAccessibilityPrompt() -> Bool {
    let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    let options = [promptKey: true] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
  }

  private func getOrCreateDbKey() -> String {
    // Application Support (0600) — encrypts clipboard history at rest without
    // a macOS login-password Keychain prompt on debug/unsigned builds.
    if let fileKey = readKeyFile(), !fileKey.isEmpty {
      return fileKey
    }

    var bytes = [UInt8](repeating: 0, count: 32)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    let key: String
    if status == errSecSuccess {
      key = Data(bytes).base64EncodedString()
    } else {
      key = Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
    }
    storeKeyFile(key)
    return key
  }

  private func keyFileURL() -> URL {
    let base = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first!
    return base
      .appendingPathComponent("ContextClip", isDirectory: true)
      .appendingPathComponent("db-aes.key", isDirectory: false)
  }

  private func readKeyFile() -> String? {
    let url = keyFileURL()
    guard FileManager.default.fileExists(atPath: url.path),
          let raw = try? String(contentsOf: url, encoding: .utf8)
    else {
      return nil
    }
    return raw.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func storeKeyFile(_ value: String) {
    let url = keyFileURL()
    let dir = url.deletingLastPathComponent()
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    try? value.write(to: url, atomically: true, encoding: .utf8)
    try? FileManager.default.setAttributes(
      [.posixPermissions: 0o600],
      ofItemAtPath: url.path
    )
  }
}
