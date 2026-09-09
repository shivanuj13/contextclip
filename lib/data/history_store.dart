import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../core/classifier/clip_classifier.dart';
import '../core/models/clip_type.dart';
import '../core/sanitizer/context_sanitizer.dart';
import 'clip_crypto.dart';
import 'database/database.dart';
import 'settings/app_settings.dart';

class DecryptedClip {
  DecryptedClip({
    required this.id,
    required this.rawContent,
    required this.sanitizedContent,
    required this.clipType,
    required this.originalTokens,
    required this.sanitizedTokens,
    required this.isPinned,
    required this.hadSecrets,
    required this.redactionCount,
    required this.createdAt,
  });

  final int id;
  final String rawContent;
  final String sanitizedContent;
  final ClipType clipType;
  final int originalTokens;
  final int sanitizedTokens;
  final bool isPinned;
  final bool hadSecrets;
  final int redactionCount;
  final DateTime createdAt;

  int get tokensSaved => originalTokens - sanitizedTokens;
}

class HistoryStore {
  HistoryStore({
    required AppDatabase db,
    required ClipCrypto crypto,
  })  : _db = db,
        _crypto = crypto;

  final AppDatabase _db;
  final ClipCrypto _crypto;

  Future<DecryptedClip?> ingest(
    String raw, {
    List<DenyRule> customRules = const [],
  }) async {
    if (raw.isEmpty) return null;

    final latest = await _db.getLatestClip();
    if (latest != null) {
      final latestRaw = await _tryDecrypt(latest.rawContent);
      if (latestRaw == null) {
        await _db.deleteClip(latest.id);
      } else if (latestRaw == raw) {
        return null;
      }
    }

    final type = ClipClassifier.classify(raw);
    final sanitized = ContextSanitizer.process(
      raw,
      type: type,
      customRules: customRules,
    );
    final hadSecrets = sanitized.hadSecrets;

    // Never persist plaintext secrets — store sanitized in both columns.
    final storeRaw = hadSecrets ? sanitized.content : raw;
    final encRaw = await _crypto.encrypt(storeRaw);
    final encSanitized = await _crypto.encrypt(sanitized.content);

    final id = await _db.insertClip(
      ClipItemsCompanion.insert(
        rawContent: encRaw,
        sanitizedContent: encSanitized,
        clipType: type.index,
        originalTokens: sanitized.originalTokens,
        sanitizedTokens: sanitized.sanitizedTokens,
        hadSecrets: Value(hadSecrets),
        redactionCount: Value(sanitized.redactionsFound.length),
      ),
    );
    await _db.pruneOldClips(500);

    return DecryptedClip(
      id: id,
      rawContent: storeRaw,
      sanitizedContent: sanitized.content,
      clipType: type,
      originalTokens: sanitized.originalTokens,
      sanitizedTokens: sanitized.sanitizedTokens,
      isPinned: false,
      hadSecrets: hadSecrets,
      redactionCount: sanitized.redactionsFound.length,
      createdAt: DateTime.now(),
    );
  }

  Future<List<DecryptedClip>> getRecent({
    int limit = 100,
    String query = '',
  }) async {
    final rows = await _db.getRecentClips(limit: limit);
    final out = <DecryptedClip>[];
    final q = query.trim().toLowerCase();
    final corruptIds = <int>[];

    for (final row in rows) {
      final raw = await _tryDecrypt(row.rawContent);
      final sanitized = await _tryDecrypt(row.sanitizedContent);
      if (raw == null || sanitized == null) {
        corruptIds.add(row.id);
        continue;
      }
      if (q.isNotEmpty &&
          !raw.toLowerCase().contains(q) &&
          !sanitized.toLowerCase().contains(q)) {
        continue;
      }
      out.add(
        DecryptedClip(
          id: row.id,
          rawContent: raw,
          sanitizedContent: sanitized,
          clipType: ClipType
              .values[row.clipType.clamp(0, ClipType.values.length - 1)],
          originalTokens: row.originalTokens,
          sanitizedTokens: row.sanitizedTokens,
          isPinned: row.isPinned,
          hadSecrets: row.hadSecrets,
          redactionCount: row.redactionCount,
          createdAt: row.createdAt,
        ),
      );
    }

    for (final id in corruptIds) {
      await _db.deleteClip(id);
    }
    return out;
  }

  Future<String?> _tryDecrypt(String ciphertext) async {
    try {
      return await _crypto.decrypt(ciphertext);
    } on SecretBoxAuthenticationError {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> togglePin(int id, bool pinned) => _db.setPinned(id, pinned);

  Future<void> remove(int id) => _db.deleteClip(id);
}
