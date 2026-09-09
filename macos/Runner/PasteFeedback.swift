import Cocoa

enum PasteFeedback {
  private static var panel: NSPanel?
  private static var hideWorkItem: DispatchWorkItem?

  static func show(message: String) {
    DispatchQueue.main.async {
      hideWorkItem?.cancel()
      panel?.orderOut(nil)
      panel = nil

      let padding: CGFloat = 14
      let label = NSTextField(labelWithString: message)
      label.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
      label.textColor = NSColor.white
      label.alignment = .center
      label.sizeToFit()

      let width = max(label.frame.width + padding * 2, 160)
      let height = label.frame.height + padding * 2
      let panel = NSPanel(
        contentRect: NSRect(x: 0, y: 0, width: width, height: height),
        styleMask: [.borderless, .nonactivatingPanel],
        backing: .buffered,
        defer: false
      )
      panel.isOpaque = false
      panel.backgroundColor = .clear
      panel.level = .floating
      panel.hasShadow = true
      panel.ignoresMouseEvents = true
      panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

      let container = NSView(frame: panel.contentView!.bounds)
      container.wantsLayer = true
      container.layer?.backgroundColor = NSColor(calibratedWhite: 0.08, alpha: 0.92).cgColor
      container.layer?.cornerRadius = 10

      label.frame = NSRect(
        x: padding,
        y: padding,
        width: width - padding * 2,
        height: label.frame.height
      )
      container.addSubview(label)
      panel.contentView = container

      if let screen = NSScreen.main {
        let visible = screen.visibleFrame
        let origin = NSPoint(
          x: visible.midX - width / 2,
          y: visible.minY + 48
        )
        panel.setFrameOrigin(origin)
      }

      panel.orderFrontRegardless()
      self.panel = panel

      let work = DispatchWorkItem {
        panel.orderOut(nil)
        if self.panel === panel {
          self.panel = nil
        }
      }
      hideWorkItem = work
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: work)
    }
  }
}
