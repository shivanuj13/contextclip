import Cocoa

enum SyntheticPaste {
  static func execute(completion: (() -> Void)? = nil) {
    NSApp.hide(nil)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
      let source = CGEventSource(stateID: .combinedSessionState)
      let vKeyCode: CGKeyCode = 9

      guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true),
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false) else {
        completion?()
        return
      }

      keyDown.flags = .maskCommand
      keyUp.flags = .maskCommand

      keyDown.post(tap: .cghidEventTap)
      keyUp.post(tap: .cghidEventTap)
      completion?()
    }
  }
}
