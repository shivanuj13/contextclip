import 'package:flutter_test/flutter_test.dart';
import 'package:context_clip/core/models/clip_type.dart';

void main() {
  test('ClipType labels and fence languages are defined', () {
    expect(ClipType.jsonPayload.label, 'JSON');
    expect(ClipType.terminalLog.fenceLanguage, 'bash');
    expect(ClipType.values.length, 6);
  });
}
