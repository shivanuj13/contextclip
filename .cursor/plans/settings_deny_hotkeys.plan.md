# Settings: Deny-lists & Configurable Hotkeys

Status: **complete** (UI via `cupertino_ui: ^1.0.2`)

## Goals

1. Custom user deny-lists
2. Configurable / disableable global hotkeys
3. Native Apple HIG UI with **cupertino_ui** (macos_ui removed)

## UI stack

- `cupertino_ui: ^1.0.2` — `CupertinoApp`, `CupertinoSearchTextField`, `CupertinoTextField`, `CupertinoSwitch`, `CupertinoButton`, `CupertinoScrollbar`
- Shared `HudPanel` floating chrome
- No `macos_ui` / `macos_window_utils`

## Checklist

- [x] SettingsStore + deny rules + hotkeys
- [x] Native hotkey reload
- [x] Settings / palette / onboarding
- [x] Migrated off macos_ui → cupertino_ui

## Out of scope

- Cloud sync of settings
- Per-app hotkey profiles
