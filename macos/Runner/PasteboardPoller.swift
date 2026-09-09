import Cocoa
import FlutterMacOS

final class PasteboardPoller {
  private let channel: FlutterMethodChannel
  private var lastChangeCount: Int
  private var timer: Timer?
  private let maxBytes = 2 * 1024 * 1024

  private let concealedTypes: Set<NSPasteboard.PasteboardType> = [
    NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType"),
    NSPasteboard.PasteboardType("com.agilebits.onepassword"),
    NSPasteboard.PasteboardType("org.keepassxc.keepassxc"),
    NSPasteboard.PasteboardType("de.bernhard-baehr.strongbox"),
  ]

  init(channel: FlutterMethodChannel) {
    self.channel = channel
    self.lastChangeCount = NSPasteboard.general.changeCount
    start()
  }

  func start() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
      self?.poll()
    }
    if let timer {
      RunLoop.main.add(timer, forMode: .common)
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
  }

  private func poll() {
    let pasteboard = NSPasteboard.general
    let changeCount = pasteboard.changeCount
    guard changeCount != lastChangeCount else { return }
    lastChangeCount = changeCount

    let types = Set(pasteboard.types ?? [])
    if !types.isDisjoint(with: concealedTypes) {
      return
    }

    guard var content = pasteboard.string(forType: .string), !content.isEmpty else {
      return
    }

    if (content.utf8.count > maxBytes) {
      let data = Data(content.utf8.prefix(maxBytes))
      let truncated = String(data: data, encoding: .utf8) ?? String(content.prefix(10_000))
      content = truncated + "\n…[truncated]"
    }

    channel.invokeMethod("onNewClip", arguments: content)
  }
}
