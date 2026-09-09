import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:context_clip/data/clip_crypto.dart';
import 'package:context_clip/data/database/database.dart';
import 'package:context_clip/data/history_store.dart';

void main() {
  late AppDatabase db;
  late HistoryStore store;

  setUp(() {
    db = AppDatabase.memory();
    final keyBytes = Uint8List.fromList(List<int>.generate(32, (i) => i));
    final crypto = ClipCrypto(keyBytes);
    store = HistoryStore(db: db, crypto: crypto);
  });

  tearDown(() async {
    await db.close();
  });

  test('secret clips store sanitized text in rawContent', () async {
    const secret = 'sk-abcdefghijklmnopqrstuvwxyz0123456789abcd';
    final clip = await store.ingest('export KEY=$secret\nhello');
    expect(clip, isNotNull);
    expect(clip!.hadSecrets, isTrue);
    expect(clip.rawContent, isNot(contains(secret)));
    expect(clip.rawContent, contains('[api_key]'));
    expect(clip.rawContent, clip.sanitizedContent);
    expect(clip.redactionCount, greaterThan(0));
  });

  test('non-secret clips keep original raw content', () async {
    const plain = 'hello from the terminal';
    final clip = await store.ingest(plain);
    expect(clip, isNotNull);
    expect(clip!.hadSecrets, isFalse);
    expect(clip.rawContent, plain);
  });

  test('ClipCrypto round-trips', () async {
    final key = base64Encode(List<int>.generate(32, (i) => i + 1));
    final crypto = ClipCrypto.fromBase64Key(key);
    const msg = 'secret sauce';
    final enc = await crypto.encrypt(msg);
    expect(enc, isNot(msg));
    expect(await crypto.decrypt(enc), msg);
  });
}
