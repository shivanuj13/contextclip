import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// AES-GCM encrypt/decrypt for clip text columns.
///
/// The 32-byte key lives in Application Support (`db-aes.key`, mode 0600) so
/// history stays encrypted at rest without a macOS Keychain login prompt.
class ClipCrypto {
  ClipCrypto(this._keyBytes);

  final Uint8List _keyBytes;
  final AesGcm _algorithm = AesGcm.with256bits();

  static ClipCrypto fromBase64Key(String base64Key) {
    final bytes = base64Decode(base64Key);
    if (bytes.length != 32) {
      throw ArgumentError('Expected 32-byte AES key, got ${bytes.length}');
    }
    return ClipCrypto(Uint8List.fromList(bytes));
  }

  Future<String> encrypt(String plaintext) async {
    final secretKey = SecretKey(_keyBytes);
    final nonce = _algorithm.newNonce();
    final box = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );
    final combined = Uint8List.fromList([
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
    return base64Encode(combined);
  }

  Future<String> decrypt(String ciphertext) async {
    final combined = base64Decode(ciphertext);
    if (combined.length < 28) {
      throw ArgumentError('Ciphertext too short');
    }
    final nonce = combined.sublist(0, 12);
    final mac = combined.sublist(combined.length - 16);
    final cipherText = combined.sublist(12, combined.length - 16);
    final secretKey = SecretKey(_keyBytes);
    final clear = await _algorithm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: secretKey,
    );
    return utf8.decode(clear);
  }
}
