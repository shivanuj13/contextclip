import 'package:flutter_test/flutter_test.dart';
import 'package:context_clip/core/sanitizer/context_sanitizer.dart';
import 'package:context_clip/data/settings/app_settings.dart';

void main() {
  group('custom deny-list', () {
    test('applies user regex with generic label', () {
      const rule = DenyRule(
        id: '1',
        pattern: r'mycorp_[A-Za-z0-9]{8,}',
        label: 'api_key',
      );
      final out = ContextSanitizer.process(
        'prefix mycorp_abcdefghij leftover',
        customRules: [rule],
      );
      expect(out.content, contains('[api_key]'));
      expect(out.content, isNot(contains('mycorp_abcdefghij')));
      expect(out.redactionsFound, contains('api_key'));
    });

    test('disabled rules are ignored', () {
      const rule = DenyRule(
        id: '1',
        pattern: r'ZZZSECRET',
        label: 'secret',
        enabled: false,
      );
      final out = ContextSanitizer.process(
        'see ZZZSECRET here',
        customRules: [rule],
      );
      expect(out.content, contains('ZZZSECRET'));
    });
  });

  group('AppSettings', () {
    test('round-trips JSON with defaults filled', () {
      final encoded = AppSettings.defaults.encode();
      final decoded = AppSettings.decode(encoded);
      expect(decoded.hotkeys[HotkeyAction.contextPaste]!.enabled, isTrue);
      expect(decoded.hotkeys[HotkeyAction.contextPaste]!.keyCode, 9);
      expect(decoded.denyRules, isEmpty);
    });

    test('disabled hotkey serializes', () {
      final s = AppSettings.defaults.copyWith(
        hotkeys: {
          ...AppSettings.defaults.hotkeys,
          HotkeyAction.showPalette: const HotkeyBinding(
            enabled: false,
            keyCode: 9,
            option: true,
          ),
        },
      );
      final again = AppSettings.decode(s.encode());
      expect(again.hotkeys[HotkeyAction.showPalette]!.enabled, isFalse);
    });
  });
}
