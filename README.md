# ContextClip

Keyboard-first clipboard workspace for macOS. Copy as usual. When you paste
into a terminal, an editor, or an AI agent, ContextClip can **mask secrets**
and **combine several clips** into one clean block.

It lives in the menu bar. Plain **⌘V** is never intercepted.

Bundle identifier: `com.buffersync.contextclip`

## Why it exists

Developer clipboards fill up with stack traces, `.env` lines, API keys, and
JSON dumps. ContextClip keeps that history local, redacts credentials before
they leave your machine, and lets you pick several clips and paste them as
one Markdown pack.

## Highlights

### Secret masking (the default paste path)

This is the main reason to use ContextClip.

When you paste sanitized context, ContextClip replaces credentials with
placeholders such as `[api_key]`, `[token]`, `[secret]`, `[private_key]`,
or `[connection]`. Built-in coverage includes:

- OpenAI / Anthropic-style secret keys
- GitHub PATs, Slack / Stripe / Google / Hugging Face / npm tokens
- JWTs and `Bearer` tokens
- AWS access-key IDs
- PEM private keys
- Database / broker URIs (`postgres://user:pass@…`)
- `.env`-style `SECRET` / `TOKEN` / `PASSWORD` / `API_KEY` lines

Add your own regex deny-list in Settings if a vendor or internal token
shape is missing. Secret clips store the **sanitized** text only.

`⌘⇧V` pastes the latest clip after masking. In the palette, **⇧Enter**
does the same for the highlighted row.

### Multi-select and pack-paste

Open the palette, mark several clips, then paste them as one fenced
Markdown context block — useful for an agent, a ticket, or a terminal.

1. `⌥V` opens the command palette.
2. Search or arrow to a clip.
3. **Space** toggles selection. Badges show paste order (`1`, `2`, `3`…).
4. **⌘Enter** packs the selection (or the highlighted clip if nothing is
   selected) and pastes a Markdown block.
5. `⌘⌥V` does the same pack from anywhere, using current selection or
   the latest clip.

Each packed item is already sanitized. You are not stitching secrets back
together by accident.

### Everything else

- **Encrypted history** — recent copies stay on disk, AES-GCM encrypted
  in Application Support. Nothing is uploaded.
- **Token-aware cleanup** — ANSI, timestamps, and noisy log / stack / JSON
  padding are trimmed so agent context stays smaller.
- **Command palette** — search, highlight, paste raw (**Enter**) or
  sanitized (**⇧Enter**).
- **Rebindable global shortcuts** — change keys in Settings. **⌘V** stays
  the system paste.
- **Launch at login** — optional, from Settings.

## Install

### Homebrew (recommended)

```bash
brew tap shivanuj13/tap
brew install --cask contextclip
```

First launch may need a Gatekeeper bypass on unsigned builds:

```bash
xattr -cr /Applications/ContextClip.app
open -a ContextClip
```

Or Right-click **ContextClip.app** → **Open**.

Source: [github.com/shivanuj13/contextclip](https://github.com/shivanuj13/contextclip).
The cask formula lives at [`Casks/contextclip.rb`](Casks/contextclip.rb)
and is published from the `shivanuj13/homebrew-tap` tap.

### Build from source

Needs [FVM](https://fvm.app) (Flutter 3.47.2) and Xcode.

```bash
git clone https://github.com/shivanuj13/contextclip.git
cd contextclip
fvm flutter pub get
fvm flutter build macos --release
rm -rf /Applications/ContextClip.app
cp -R build/macos/Build/Products/Release/ContextClip.app /Applications/
open -a ContextClip
```

## First-run setup

ContextClip is a menu-bar app (`LSUIElement`). There is no Dock icon by
default.

1. Open it from Spotlight or `open -a ContextClip`.
2. Read the **GNU GPLv3** text and accept it. The app will not continue
   until you do.
3. Grant **Accessibility** — required for global hotkeys and synthetic paste.
4. System Settings → Privacy & Security → **Accessibility** → enable
   **ContextClip**.
5. **Quit from the menu bar**, then reopen. macOS often applies the
   permission only on a new process.
6. Confirm the menu-bar extra is visible.

If onboarding stays up after you toggle the switch, you granted a stale
binary (an old debug build). Remove every ContextClip row in Accessibility,
quit, open **only** `/Applications/ContextClip.app`, enable it, quit, reopen.

## How to use

| Shortcut | Action |
| --- | --- |
| `⌥V` | Open the command palette |
| `⌘⇧V` | Paste the latest clip, secrets masked |
| `⌘⌥V` | Paste a Markdown pack of the selection (or latest clip) |
| `⌘V` | System paste — ContextClip does not touch this |

Inside the palette:

| Key | Action |
| --- | --- |
| Type | Filter history |
| `↑` / `↓` | Move highlight (`⌃P` / `⌃N` also work) |
| `Space` | Multi-select / deselect (order is preserved) |
| `Enter` | Paste the highlighted clip **raw** |
| `⇧Enter` | Paste the highlighted clip **masked** |
| `⌘Enter` | Pack selected clips and paste Markdown |
| `Esc` | Dismiss |

Settings (deny-list, hotkeys, launch at login) are available from the
menu-bar extra.

## Privacy

- History is local only: `~/Library/Application Support/ContextClip`
- Encryption key is a 0600 file next to the database (not iCloud Keychain)
- Sandbox is off so global hotkeys and paste-into-other-apps can work
- No telemetry in this build

## License

ContextClip is **open source** under the
[GNU General Public License v3](LICENSE) (or, at your option, any later
version).

You may run, study, share, and modify it — including at work. The control
is copyleft:

- Distributed copies (and modified builds you ship) must stay under GPLv3
- Recipients must get the same freedoms, including source
- You cannot fold ContextClip into a proprietary product without a
  separate grant

The first launch shows the full license. You must read and accept it
before the app continues.

If you need to distribute a closed-source fork or embed ContextClip in a
proprietary product, see [COMMERCIAL-LICENSE.md](COMMERCIAL-LICENSE.md).

## Requirements

- macOS (Ventura or later recommended)
- Accessibility permission
- Apple Developer ID + notarization are **not** required to run a build
  you compiled yourself. Public Homebrew installs without notarization
  will show Gatekeeper warnings (see Install).

## Development

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run -d macos
```

Hotkeys, pasteboard polling, and the status item are native Swift
(`macos/Runner`). Dart owns sanitization, history, and UI.

## Publishing a Homebrew release

Official `homebrew/cask` prefers notarized Developer ID builds. For now,
ship from your own tap: [shivanuj13/homebrew-tap](https://github.com/shivanuj13/homebrew-tap).

1. Bump `version` in `pubspec.yaml` if needed (currently `1.0.0+1`).
2. Build and zip:

   ```bash
   fvm flutter build macos --release
   VERSION=1.0.0
   cd build/macos/Build/Products/Release
   ditto -c -k --keepParent ContextClip.app "ContextClip-${VERSION}-macos.zip"
   shasum -a 256 "ContextClip-${VERSION}-macos.zip"
   ```

3. Create a GitHub Release `v1.0.0` on
   [shivanuj13/contextclip](https://github.com/shivanuj13/contextclip/releases)
   and attach that zip. The asset name must match the cask URL:
   `ContextClip-1.0.0-macos.zip`.
4. Copy [`Casks/contextclip.rb`](Casks/contextclip.rb) into
   `homebrew-tap/Casks/contextclip.rb`. Set `version` and replace
   `sha256 :no_check` with the checksum from step 2.
5. Users install with:

   ```bash
   brew tap shivanuj13/tap
   brew install --cask contextclip
   ```

On later versions, repeat 1–4 and bump the cask `version` + `sha256`.
