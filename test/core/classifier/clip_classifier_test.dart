import 'package:flutter_test/flutter_test.dart';
import 'package:context_clip/core/classifier/clip_classifier.dart';
import 'package:context_clip/core/models/clip_type.dart';

void main() {
  group('ClipClassifier', () {
    test('detects JSON', () {
      expect(ClipClassifier.classify('{"ok": true}'), ClipType.jsonPayload);
    });

    test('detects stack traces', () {
      expect(
        ClipClassifier.classify('Exception: boom\n  at main.dart:12:3'),
        ClipType.stackTrace,
      );
    });

    test('detects env config', () {
      expect(
        ClipClassifier.classify('API_KEY=abc\nDEBUG=true\nPORT=8080'),
        ClipType.envConfig,
      );
    });

    test('detects terminal logs via ANSI', () {
      expect(
        ClipClassifier.classify('\x1B[32mok\x1B[0m deployed'),
        ClipType.terminalLog,
      );
    });

    test('falls back to plain text', () {
      expect(ClipClassifier.classify('hello world'), ClipType.plainText);
    });
  });
}
