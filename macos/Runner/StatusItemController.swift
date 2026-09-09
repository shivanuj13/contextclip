import Cocoa
import FlutterMacOS
import ServiceManagement

final class StatusItemController: NSObject {
  private let channel: FlutterMethodChannel
  private var statusItem: NSStatusItem?
  private var launchAtLoginItem: NSMenuItem?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
    setup()
  }

  private func setup() {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = item.button {
      if let image = NSImage(
        systemSymbolName: "doc.on.clipboard",
        accessibilityDescription: "ContextClip"
      ) {
        image.isTemplate = true
        button.image = image
      } else {
        button.title = "CC"
      }
      button.toolTip = "ContextClip"
    }

    let menu = NSMenu()
    menu.addItem(
      NSMenuItem(
        title: "Open Palette",
        action: #selector(openPalette),
        keyEquivalent: "v"
      )
    )
    menu.items.last?.keyEquivalentModifierMask = [.option]
    menu.items.last?.target = self

    let launchItem = NSMenuItem(
      title: "Launch at Login",
      action: #selector(toggleLaunchAtLogin),
      keyEquivalent: ""
    )
    launchItem.target = self
    launchItem.state = Self.isLaunchAtLoginEnabled() ? .on : .off
    launchAtLoginItem = launchItem
    menu.addItem(launchItem)

    let settingsItem = NSMenuItem(
      title: "Settings…",
      action: #selector(openSettings),
      keyEquivalent: ","
    )
    settingsItem.target = self
    menu.addItem(settingsItem)

    menu.addItem(NSMenuItem.separator())

    let quitItem = NSMenuItem(
      title: "Quit ContextClip",
      action: #selector(quitApp),
      keyEquivalent: "q"
    )
    quitItem.target = self
    menu.addItem(quitItem)

    item.menu = menu
    statusItem = item
  }

  @objc private func openPalette() {
    channel.invokeMethod("triggerShowPalette", arguments: nil)
  }

  @objc private func openSettings() {
    channel.invokeMethod("triggerShowSettings", arguments: nil)
  }

  @objc private func toggleLaunchAtLogin() {
    let enabled = Self.isLaunchAtLoginEnabled()
    _ = Self.setLaunchAtLogin(enabled: !enabled)
    launchAtLoginItem?.state = Self.isLaunchAtLoginEnabled() ? .on : .off
  }

  @objc private func quitApp() {
    NSApp.terminate(nil)
  }

  static func isLaunchAtLoginEnabled() -> Bool {
    SMAppService.mainApp.status == .enabled
  }

  @discardableResult
  static func setLaunchAtLogin(enabled: Bool) -> Bool {
    do {
      if enabled {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
      return true
    } catch {
      NSLog("ContextClip launch-at-login error: \(error.localizedDescription)")
      return false
    }
  }
}
