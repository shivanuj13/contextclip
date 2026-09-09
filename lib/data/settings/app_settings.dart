import 'dart:convert';

/// A user-defined regex deny rule. Matches are replaced with `[label]`.
class DenyRule {
  const DenyRule({
    required this.id,
    required this.pattern,
    this.label = 'secret',
    this.enabled = true,
  });

  final String id;
  final String pattern;
  final String label;
  final bool enabled;

  DenyRule copyWith({
    String? pattern,
    String? label,
    bool? enabled,
  }) {
    return DenyRule(
      id: id,
      pattern: pattern ?? this.pattern,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pattern': pattern,
        'label': label,
        'enabled': enabled,
      };

  factory DenyRule.fromJson(Map<String, dynamic> json) => DenyRule(
        id: json['id'] as String,
        pattern: json['pattern'] as String? ?? '',
        label: json['label'] as String? ?? 'secret',
        enabled: json['enabled'] as bool? ?? true,
      );

  RegExp? tryCompile() {
    if (pattern.trim().isEmpty) return null;
    try {
      return RegExp(pattern);
    } catch (_) {
      return null;
    }
  }
}

enum HotkeyAction {
  contextPaste,
  markdownPaste,
  showPalette,
}

extension HotkeyActionLabel on HotkeyAction {
  String get id {
    switch (this) {
      case HotkeyAction.contextPaste:
        return 'contextPaste';
      case HotkeyAction.markdownPaste:
        return 'markdownPaste';
      case HotkeyAction.showPalette:
        return 'showPalette';
    }
  }

  String get title {
    switch (this) {
      case HotkeyAction.contextPaste:
        return 'Context Paste (sanitize)';
      case HotkeyAction.markdownPaste:
        return 'Markdown Fenced Paste';
      case HotkeyAction.showPalette:
        return 'Open Palette';
    }
  }

  static HotkeyAction? fromId(String id) {
    for (final a in HotkeyAction.values) {
      if (a.id == id) return a;
    }
    return null;
  }
}

class HotkeyBinding {
  const HotkeyBinding({
    required this.enabled,
    required this.keyCode,
    this.command = false,
    this.shift = false,
    this.option = false,
    this.control = false,
  });

  final bool enabled;
  final int keyCode;
  final bool command;
  final bool shift;
  final bool option;
  final bool control;

  HotkeyBinding copyWith({
    bool? enabled,
    int? keyCode,
    bool? command,
    bool? shift,
    bool? option,
    bool? control,
  }) {
    return HotkeyBinding(
      enabled: enabled ?? this.enabled,
      keyCode: keyCode ?? this.keyCode,
      command: command ?? this.command,
      shift: shift ?? this.shift,
      option: option ?? this.option,
      control: control ?? this.control,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'keyCode': keyCode,
        'command': command,
        'shift': shift,
        'option': option,
        'control': control,
      };

  factory HotkeyBinding.fromJson(Map<String, dynamic> json) => HotkeyBinding(
        enabled: json['enabled'] as bool? ?? true,
        keyCode: json['keyCode'] as int? ?? 9,
        command: json['command'] as bool? ?? false,
        shift: json['shift'] as bool? ?? false,
        option: json['option'] as bool? ?? false,
        control: json['control'] as bool? ?? false,
      );

  /// Human-readable shortcut, e.g. ⌘⇧V.
  String get displayLabel {
    if (!enabled) return 'Disabled';
    final buf = StringBuffer();
    if (control) buf.write('⌃');
    if (option) buf.write('⌥');
    if (shift) buf.write('⇧');
    if (command) buf.write('⌘');
    buf.write(_keyCodeLabel(keyCode));
    return buf.toString();
  }

  static String _keyCodeLabel(int code) {
    const map = {
      0: 'A',
      1: 'S',
      2: 'D',
      3: 'F',
      5: 'G',
      4: 'H',
      38: 'J',
      40: 'K',
      37: 'L',
      12: 'Q',
      13: 'W',
      14: 'E',
      15: 'R',
      17: 'T',
      16: 'Y',
      32: 'U',
      34: 'I',
      31: 'O',
      35: 'P',
      6: 'Z',
      7: 'X',
      8: 'C',
      9: 'V',
      11: 'B',
      45: 'N',
      46: 'M',
      49: 'Space',
    };
    return map[code] ?? 'Key($code)';
  }
}

class AppSettings {
  AppSettings({
    List<DenyRule>? denyRules,
    Map<HotkeyAction, HotkeyBinding>? hotkeys,
  })  : denyRules = denyRules ?? [],
        hotkeys = hotkeys ?? Map.from(defaults.hotkeys);

  final List<DenyRule> denyRules;
  final Map<HotkeyAction, HotkeyBinding> hotkeys;

  static final AppSettings defaults = AppSettings(
    denyRules: const [],
    hotkeys: {
      HotkeyAction.contextPaste: const HotkeyBinding(
        enabled: true,
        keyCode: 9,
        command: true,
        shift: true,
      ),
      HotkeyAction.markdownPaste: const HotkeyBinding(
        enabled: true,
        keyCode: 9,
        command: true,
        option: true,
      ),
      HotkeyAction.showPalette: const HotkeyBinding(
        enabled: true,
        keyCode: 9,
        option: true,
      ),
    },
  );

  AppSettings copyWith({
    List<DenyRule>? denyRules,
    Map<HotkeyAction, HotkeyBinding>? hotkeys,
  }) {
    return AppSettings(
      denyRules: denyRules ?? this.denyRules,
      hotkeys: hotkeys ?? Map.from(this.hotkeys),
    );
  }

  Map<String, dynamic> toJson() => {
        'denyRules': denyRules.map((r) => r.toJson()).toList(),
        'hotkeys': {
          for (final e in hotkeys.entries) e.key.id: e.value.toJson(),
        },
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rules = (json['denyRules'] as List<dynamic>? ?? [])
        .map((e) => DenyRule.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final rawHotkeys = Map<String, dynamic>.from(
      json['hotkeys'] as Map? ?? {},
    );
    final hotkeys = Map<HotkeyAction, HotkeyBinding>.from(defaults.hotkeys);
    for (final entry in rawHotkeys.entries) {
      final action = HotkeyActionLabel.fromId(entry.key);
      if (action == null) continue;
      hotkeys[action] = HotkeyBinding.fromJson(
        Map<String, dynamic>.from(entry.value as Map),
      );
    }
    return AppSettings(denyRules: rules, hotkeys: hotkeys);
  }

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  static AppSettings decode(String raw) {
    try {
      return AppSettings.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return AppSettings.defaults;
    }
  }

  /// Payload for native `setHotkeys`.
  List<Map<String, dynamic>> hotkeysNativePayload() {
    return hotkeys.entries
        .map(
          (e) => {
            'action': e.key.id,
            ...e.value.toJson(),
          },
        )
        .toList();
  }
}
