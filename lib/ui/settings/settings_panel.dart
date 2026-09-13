import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/clipboard_controller.dart';
import '../../data/settings/app_settings.dart';
import '../theme/signal_desk.dart';
import '../widgets/brand_mark.dart';
import '../widgets/hud_panel.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final _patternController = TextEditingController();
  final _labelController = TextEditingController(text: 'secret');
  final _scrollController = ScrollController();
  String? _patternError;

  static const _keyChoices = <MapEntry<int, String>>[
    MapEntry(9, 'V'),
    MapEntry(8, 'C'),
    MapEntry(11, 'B'),
    MapEntry(7, 'X'),
    MapEntry(45, 'N'),
    MapEntry(46, 'M'),
    MapEntry(3, 'F'),
    MapEntry(49, 'Space'),
  ];

  @override
  void dispose() {
    _patternController.dispose();
    _labelController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _save(AppSettings next) async {
    await context.read<ClipboardController>().updateSettings(next);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClipboardController>();
    final settings = controller.settings;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          controller.hidePalette();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: HudPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                HudPanel.titleBarHeight,
                12,
                12,
              ),
              child: Row(
                children: [
                  const BrandMark(size: 28),
                  const SizedBox(width: 10),
                  Text('Settings', style: SignalDesk.display(size: 22)),
                  const Spacer(),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    onPressed: () async {
                      await controller.resetSettings();
                    },
                    child: Text(
                      'Reset',
                      style: SignalDesk.ui(
                        size: 13,
                        weight: FontWeight.w500,
                        color: SignalDesk.muted,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: controller.hidePalette,
                    child: const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: SignalDesk.dim,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const HudDivider(),
            Expanded(
              child: CupertinoScrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [
                    Text(
                      'GLOBAL HOTKEYS',
                      style: SignalDesk.caption(
                        color: SignalDesk.signal,
                        weight: FontWeight.w700,
                      ).copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Disable or rebind. Plain ⌘V is never intercepted.',
                      style: SignalDesk.ui(size: 13, color: SignalDesk.muted),
                    ),
                    const SizedBox(height: 14),
                    for (final action in HotkeyAction.values)
                      _HotkeyCard(
                        action: action,
                        binding: settings.hotkeys[action]!,
                        keyChoices: _keyChoices,
                        onChanged: (next) async {
                          final hotkeys =
                              Map<HotkeyAction, HotkeyBinding>.from(
                            settings.hotkeys,
                          );
                          hotkeys[action] = next;
                          await _save(settings.copyWith(hotkeys: hotkeys));
                        },
                      ),
                    const SizedBox(height: 22),
                    Text(
                      'CUSTOM DENY-LIST',
                      style: SignalDesk.caption(
                        color: SignalDesk.signal,
                        weight: FontWeight.w700,
                      ).copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Regex patterns redacted to [label] after built-in detectors.',
                      style: SignalDesk.ui(size: 13, color: SignalDesk.muted),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _Field(
                            controller: _patternController,
                            placeholder: r'mycorp_[A-Za-z0-9]{20,}',
                            mono: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 110,
                          child: _Field(
                            controller: _labelController,
                            placeholder: 'label',
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          sizeStyle: CupertinoButtonSize.medium,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2
                            
                          ),
                          color: SignalDesk.signal,
                          borderRadius: BorderRadius.circular(6),
                          onPressed: () async {
                            final pattern = _patternController.text.trim();
                            final label =
                                _labelController.text.trim().isEmpty
                                    ? 'secret'
                                    : _labelController.text.trim();
                            if (pattern.isEmpty) {
                              setState(() => _patternError = 'Required');
                              return;
                            }
                            try {
                              RegExp(pattern);
                            } catch (_) {
                              setState(() => _patternError = 'Invalid regex');
                              return;
                            }
                            setState(() => _patternError = null);
                            final rule = DenyRule(
                              id: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              pattern: pattern,
                              label: label,
                            );
                            await _save(
                              settings.copyWith(
                                denyRules: [...settings.denyRules, rule],
                              ),
                            );
                            _patternController.clear();
                          },
                          child: Text(
                            'Add',
                            style: SignalDesk.ui(
                              size: 13,
                              weight: FontWeight.w600,
                              color: SignalDesk.voidBg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_patternError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _patternError!,
                        style: SignalDesk.ui(
                          size: 12,
                          color: SignalDesk.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    if (settings.denyRules.isEmpty)
                      Text(
                        'No custom rules yet.',
                        style: SignalDesk.ui(
                          size: 13,
                          color: SignalDesk.dim,
                        ),
                      )
                    else
                      ...settings.denyRules.map((rule) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: SignalDesk.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: SignalDesk.hairline,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rule.pattern,
                                          style: SignalDesk.mono(
                                            size: 12,
                                            color: SignalDesk.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '→ [${rule.label}]',
                                          style: SignalDesk.mono(
                                            size: 11,
                                            color: SignalDesk.signal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: rule.enabled,
                                    activeTrackColor: SignalDesk.signal,
                                    onChanged: (v) async {
                                      final next = settings.denyRules
                                          .map(
                                            (r) => r.id == rule.id
                                                ? r.copyWith(enabled: v)
                                                : r,
                                          )
                                          .toList();
                                      await _save(
                                        settings.copyWith(denyRules: next),
                                      );
                                    },
                                  ),
                                  CupertinoButton(
                                    padding: const EdgeInsets.all(6),
                                    onPressed: () async {
                                      await _save(
                                        settings.copyWith(
                                          denyRules: settings.denyRules
                                              .where((r) => r.id != rule.id)
                                              .toList(),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      CupertinoIcons.trash,
                                      size: 16,
                                      color: SignalDesk.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Esc to close · Menu bar → Settings…',
                textAlign: TextAlign.center,
                style: SignalDesk.mono(size: 10.5, color: SignalDesk.dim),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.placeholder,
    this.mono = false,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SignalDesk.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SignalDesk.hairlineStrong, width: 0.5),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        placeholderStyle: (mono
                ? SignalDesk.mono(size: 12, color: SignalDesk.dim)
                : SignalDesk.ui(size: 13, color: SignalDesk.dim)),
        style: mono
            ? SignalDesk.mono(size: 12, color: SignalDesk.ink)
            : SignalDesk.ui(size: 13, color: SignalDesk.ink),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: const BoxDecoration(),
        cursorColor: SignalDesk.signal,
      ),
    );
  }
}

class _HotkeyCard extends StatelessWidget {
  const _HotkeyCard({
    required this.action,
    required this.binding,
    required this.keyChoices,
    required this.onChanged,
  });

  final HotkeyAction action;
  final HotkeyBinding binding;
  final List<MapEntry<int, String>> keyChoices;
  final ValueChanged<HotkeyBinding> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SignalDesk.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: SignalDesk.hairline, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      action.title,
                      style: SignalDesk.ui(
                        size: 14,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                  HudChip(
                    label: binding.displayLabel,
                    tone: binding.enabled
                        ? HudChipTone.accent
                        : HudChipTone.neutral,
                  ),
                  const SizedBox(width: 8),
                  CupertinoSwitch(
                    value: binding.enabled,
                    activeTrackColor: SignalDesk.signal,
                    onChanged: (v) => onChanged(binding.copyWith(enabled: v)),
                  ),
                ],
              ),
              if (binding.enabled) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ModChip(
                      label: '⌘',
                      selected: binding.command,
                      onTap: () => onChanged(
                        binding.copyWith(command: !binding.command),
                      ),
                    ),
                    _ModChip(
                      label: '⇧',
                      selected: binding.shift,
                      onTap: () =>
                          onChanged(binding.copyWith(shift: !binding.shift)),
                    ),
                    _ModChip(
                      label: '⌥',
                      selected: binding.option,
                      onTap: () =>
                          onChanged(binding.copyWith(option: !binding.option)),
                    ),
                    _ModChip(
                      label: '⌃',
                      selected: binding.control,
                      onTap: () => onChanged(
                        binding.copyWith(control: !binding.control),
                      ),
                    ),
                    for (final e in keyChoices)
                      _ModChip(
                        label: e.value,
                        selected: binding.keyCode == e.key,
                        onTap: () =>
                            onChanged(binding.copyWith(keyCode: e.key)),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModChip extends StatelessWidget {
  const _ModChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? SignalDesk.signalWash : SignalDesk.panel,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? SignalDesk.signal : SignalDesk.hairlineStrong,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: SignalDesk.mono(
            size: 12,
            weight: FontWeight.w600,
            color: selected ? SignalDesk.signal : SignalDesk.muted,
          ),
        ),
      ),
    );
  }
}
