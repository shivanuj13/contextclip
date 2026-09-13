# Homebrew cask for ContextClip.
# Copy this file into shivanuj13/homebrew-tap as Casks/contextclip.rb
# and replace sha256 after each GitHub Release.
cask "contextclip" do
  version "1.0.0"
  sha256 :no_check # replace with `shasum -a 256 ContextClip-1.0.0-macos.zip`

  url "https://github.com/shivanuj13/contextclip/releases/download/v#{version}/ContextClip-#{version}-macos.zip"
  name "ContextClip"
  desc "Keyboard-first clipboard workspace that redacts secrets before paste"
  homepage "https://github.com/shivanuj13/contextclip"

  depends_on macos: ">= :ventura"

  app "ContextClip.app"

  zap trash: [
    "~/Library/Application Support/ContextClip",
    "~/Library/Preferences/com.buffersync.contextclip.plist",
  ]

  caveats <<~EOS
    ContextClip needs Accessibility permission for global shortcuts
    and sanitized paste.

      System Settings → Privacy & Security → Accessibility → ContextClip

    After enabling it, quit from the menu bar and reopen the app.

    Unsigned builds may be blocked by Gatekeeper. Right-click the app
    and choose Open, or run:

      xattr -cr /Applications/ContextClip.app
  EOS
end
