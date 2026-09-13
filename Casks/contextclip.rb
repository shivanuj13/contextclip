# Homebrew cask for ContextClip.
# Copy this file into a tap (e.g. homebrew-tap/Casks/contextclip.rb)
# and fill url + sha256 from a GitHub Release zip of ContextClip.app.
cask "contextclip" do
  version "1.0.0"
  sha256 :no_check # replace with `shasum -a 256 ContextClip-1.0.0-macos.zip`

  url "https://github.com/buffersync/contextclip/releases/download/v#{version}/ContextClip-#{version}-macos.zip"
  name "ContextClip"
  desc "Keyboard-first clipboard workspace that redacts secrets before paste"
  homepage "https://github.com/buffersync/contextclip"

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
