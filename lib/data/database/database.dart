import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class ClipItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawContent => text()();
  TextColumn get sanitizedContent => text()();
  IntColumn get clipType => integer()();
  IntColumn get originalTokens => integer()();
  IntColumn get sanitizedTokens => integer()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get hadSecrets => boolean().withDefault(const Constant(false))();
  IntColumn get redactionCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [ClipItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.memory() : super(NativeDatabase.memory());

  static Future<AppDatabase> open() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'context_clip.sqlite'));
    return AppDatabase(NativeDatabase.createInBackground(file));
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );

  Future<List<ClipItem>> getRecentClips({int limit = 100}) =>
      (select(clipItems)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<ClipItem?> getLatestClip() =>
      (select(clipItems)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> insertClip(ClipItemsCompanion entry) =>
      into(clipItems).insert(entry);

  Future<void> setPinned(int id, bool pinned) =>
      (update(clipItems)..where((t) => t.id.equals(id))).write(
        ClipItemsCompanion(isPinned: Value(pinned)),
      );

  Future<void> deleteClip(int id) =>
      (delete(clipItems)..where((t) => t.id.equals(id))).go();

  Future<void> pruneOldClips(int keepCount) async {
    final clips = await (select(clipItems)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    if (clips.length <= keepCount) return;
    final deleteIds = clips
        .sublist(keepCount)
        .where((c) => !c.isPinned)
        .map((c) => c.id)
        .toList();
    if (deleteIds.isEmpty) return;
    await (delete(clipItems)..where((t) => t.id.isIn(deleteIds))).go();
  }
}
