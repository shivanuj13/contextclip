import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var bridge: BridgeChannel?

  /// Default / minimum window size (MVP palette).
  static let defaultSize = NSSize(width: 680, height: 520)

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    // Match SignalDesk.panel (#0C0C0A) so rounded window corners never flash clear.
    let panel = NSColor(srgbRed: 0x0C / 255.0, green: 0x0C / 255.0, blue: 0x0A / 255.0, alpha: 1)
    flutterViewController.backgroundColor = panel

    let windowFrame = NSRect(origin: .zero, size: Self.defaultSize)
    contentViewController = flutterViewController
    setFrame(windowFrame, display: false)

    styleMask = [.titled, .fullSizeContentView, .closable, .resizable]
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    isOpaque = true
    backgroundColor = panel
    hasShadow = true
    level = .floating
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    isReleasedWhenClosed = false
    minSize = Self.defaultSize
    applyMaxSizeForCurrentScreen()

    RegisterGeneratedPlugins(registry: flutterViewController)

    bridge = BridgeChannel(
      messenger: flutterViewController.engine.binaryMessenger,
      window: self
    )

    orderOut(nil)
    super.awakeFromNib()
  }

  /// Caps resize to the screen the window is on (visible frame, excluding menu/dock).
  func applyMaxSizeForCurrentScreen() {
    let screen = self.screen ?? NSScreen.main
    if let visible = screen?.visibleFrame.size {
      maxSize = visible
    } else {
      maxSize = NSSize(
        width: CGFloat.greatestFiniteMagnitude,
        height: CGFloat.greatestFiniteMagnitude
      )
    }
  }
}
