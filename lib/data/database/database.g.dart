// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClipItemsTable extends ClipItems
    with TableInfo<$ClipItemsTable, ClipItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClipItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rawContentMeta = const VerificationMeta(
    'rawContent',
  );
  @override
  late final GeneratedColumn<String> rawContent = GeneratedColumn<String>(
    'raw_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sanitizedContentMeta = const VerificationMeta(
    'sanitizedContent',
  );
  @override
  late final GeneratedColumn<String> sanitizedContent = GeneratedColumn<String>(
    'sanitized_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clipTypeMeta = const VerificationMeta(
    'clipType',
  );
  @override
  late final GeneratedColumn<int> clipType = GeneratedColumn<int>(
    'clip_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalTokensMeta = const VerificationMeta(
    'originalTokens',
  );
  @override
  late final GeneratedColumn<int> originalTokens = GeneratedColumn<int>(
    'original_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sanitizedTokensMeta = const VerificationMeta(
    'sanitizedTokens',
  );
  @override
  late final GeneratedColumn<int> sanitizedTokens = GeneratedColumn<int>(
    'sanitized_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hadSecretsMeta = const VerificationMeta(
    'hadSecrets',
  );
  @override
  late final GeneratedColumn<bool> hadSecrets = GeneratedColumn<bool>(
    'had_secrets',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("had_secrets" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _redactionCountMeta = const VerificationMeta(
    'redactionCount',
  );
  @override
  late final GeneratedColumn<int> redactionCount = GeneratedColumn<int>(
    'redaction_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rawContent,
    sanitizedContent,
    clipType,
    originalTokens,
    sanitizedTokens,
    isPinned,
    hadSecrets,
    redactionCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clip_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClipItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_content')) {
      context.handle(
        _rawContentMeta,
        rawContent.isAcceptableOrUnknown(data['raw_content']!, _rawContentMeta),
      );
    } else if (isInserting) {
      context.missing(_rawContentMeta);
    }
    if (data.containsKey('sanitized_content')) {
      context.handle(
        _sanitizedContentMeta,
        sanitizedContent.isAcceptableOrUnknown(
          data['sanitized_content']!,
          _sanitizedContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sanitizedContentMeta);
    }
    if (data.containsKey('clip_type')) {
      context.handle(
        _clipTypeMeta,
        clipType.isAcceptableOrUnknown(data['clip_type']!, _clipTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_clipTypeMeta);
    }
    if (data.containsKey('original_tokens')) {
      context.handle(
        _originalTokensMeta,
        originalTokens.isAcceptableOrUnknown(
          data['original_tokens']!,
          _originalTokensMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTokensMeta);
    }
    if (data.containsKey('sanitized_tokens')) {
      context.handle(
        _sanitizedTokensMeta,
        sanitizedTokens.isAcceptableOrUnknown(
          data['sanitized_tokens']!,
          _sanitizedTokensMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sanitizedTokensMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('had_secrets')) {
      context.handle(
        _hadSecretsMeta,
        hadSecrets.isAcceptableOrUnknown(data['had_secrets']!, _hadSecretsMeta),
      );
    }
    if (data.containsKey('redaction_count')) {
      context.handle(
        _redactionCountMeta,
        redactionCount.isAcceptableOrUnknown(
          data['redaction_count']!,
          _redactionCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClipItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClipItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_content'],
      )!,
      sanitizedContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sanitized_content'],
      )!,
      clipType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clip_type'],
      )!,
      originalTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_tokens'],
      )!,
      sanitizedTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sanitized_tokens'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      hadSecrets: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}had_secrets'],
      )!,
      redactionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}redaction_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClipItemsTable createAlias(String alias) {
    return $ClipItemsTable(attachedDatabase, alias);
  }
}

class ClipItem extends DataClass implements Insertable<ClipItem> {
  final int id;
  final String rawContent;
  final String sanitizedContent;
  final int clipType;
  final int originalTokens;
  final int sanitizedTokens;
  final bool isPinned;
  final bool hadSecrets;
  final int redactionCount;
  final DateTime createdAt;
  const ClipItem({
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_content'] = Variable<String>(rawContent);
    map['sanitized_content'] = Variable<String>(sanitizedContent);
    map['clip_type'] = Variable<int>(clipType);
    map['original_tokens'] = Variable<int>(originalTokens);
    map['sanitized_tokens'] = Variable<int>(sanitizedTokens);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['had_secrets'] = Variable<bool>(hadSecrets);
    map['redaction_count'] = Variable<int>(redactionCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClipItemsCompanion toCompanion(bool nullToAbsent) {
    return ClipItemsCompanion(
      id: Value(id),
      rawContent: Value(rawContent),
      sanitizedContent: Value(sanitizedContent),
      clipType: Value(clipType),
      originalTokens: Value(originalTokens),
      sanitizedTokens: Value(sanitizedTokens),
      isPinned: Value(isPinned),
      hadSecrets: Value(hadSecrets),
      redactionCount: Value(redactionCount),
      createdAt: Value(createdAt),
    );
  }

  factory ClipItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClipItem(
      id: serializer.fromJson<int>(json['id']),
      rawContent: serializer.fromJson<String>(json['rawContent']),
      sanitizedContent: serializer.fromJson<String>(json['sanitizedContent']),
      clipType: serializer.fromJson<int>(json['clipType']),
      originalTokens: serializer.fromJson<int>(json['originalTokens']),
      sanitizedTokens: serializer.fromJson<int>(json['sanitizedTokens']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      hadSecrets: serializer.fromJson<bool>(json['hadSecrets']),
      redactionCount: serializer.fromJson<int>(json['redactionCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawContent': serializer.toJson<String>(rawContent),
      'sanitizedContent': serializer.toJson<String>(sanitizedContent),
      'clipType': serializer.toJson<int>(clipType),
      'originalTokens': serializer.toJson<int>(originalTokens),
      'sanitizedTokens': serializer.toJson<int>(sanitizedTokens),
      'isPinned': serializer.toJson<bool>(isPinned),
      'hadSecrets': serializer.toJson<bool>(hadSecrets),
      'redactionCount': serializer.toJson<int>(redactionCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClipItem copyWith({
    int? id,
    String? rawContent,
    String? sanitizedContent,
    int? clipType,
    int? originalTokens,
    int? sanitizedTokens,
    bool? isPinned,
    bool? hadSecrets,
    int? redactionCount,
    DateTime? createdAt,
  }) => ClipItem(
    id: id ?? this.id,
    rawContent: rawContent ?? this.rawContent,
    sanitizedContent: sanitizedContent ?? this.sanitizedContent,
    clipType: clipType ?? this.clipType,
    originalTokens: originalTokens ?? this.originalTokens,
    sanitizedTokens: sanitizedTokens ?? this.sanitizedTokens,
    isPinned: isPinned ?? this.isPinned,
    hadSecrets: hadSecrets ?? this.hadSecrets,
    redactionCount: redactionCount ?? this.redactionCount,
    createdAt: createdAt ?? this.createdAt,
  );
  ClipItem copyWithCompanion(ClipItemsCompanion data) {
    return ClipItem(
      id: data.id.present ? data.id.value : this.id,
      rawContent: data.rawContent.present
          ? data.rawContent.value
          : this.rawContent,
      sanitizedContent: data.sanitizedContent.present
          ? data.sanitizedContent.value
          : this.sanitizedContent,
      clipType: data.clipType.present ? data.clipType.value : this.clipType,
      originalTokens: data.originalTokens.present
          ? data.originalTokens.value
          : this.originalTokens,
      sanitizedTokens: data.sanitizedTokens.present
          ? data.sanitizedTokens.value
          : this.sanitizedTokens,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      hadSecrets: data.hadSecrets.present
          ? data.hadSecrets.value
          : this.hadSecrets,
      redactionCount: data.redactionCount.present
          ? data.redactionCount.value
          : this.redactionCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClipItem(')
          ..write('id: $id, ')
          ..write('rawContent: $rawContent, ')
          ..write('sanitizedContent: $sanitizedContent, ')
          ..write('clipType: $clipType, ')
          ..write('originalTokens: $originalTokens, ')
          ..write('sanitizedTokens: $sanitizedTokens, ')
          ..write('isPinned: $isPinned, ')
          ..write('hadSecrets: $hadSecrets, ')
          ..write('redactionCount: $redactionCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rawContent,
    sanitizedContent,
    clipType,
    originalTokens,
    sanitizedTokens,
    isPinned,
    hadSecrets,
    redactionCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClipItem &&
          other.id == this.id &&
          other.rawContent == this.rawContent &&
          other.sanitizedContent == this.sanitizedContent &&
          other.clipType == this.clipType &&
          other.originalTokens == this.originalTokens &&
          other.sanitizedTokens == this.sanitizedTokens &&
          other.isPinned == this.isPinned &&
          other.hadSecrets == this.hadSecrets &&
          other.redactionCount == this.redactionCount &&
          other.createdAt == this.createdAt);
}

class ClipItemsCompanion extends UpdateCompanion<ClipItem> {
  final Value<int> id;
  final Value<String> rawContent;
  final Value<String> sanitizedContent;
  final Value<int> clipType;
  final Value<int> originalTokens;
  final Value<int> sanitizedTokens;
  final Value<bool> isPinned;
  final Value<bool> hadSecrets;
  final Value<int> redactionCount;
  final Value<DateTime> createdAt;
  const ClipItemsCompanion({
    this.id = const Value.absent(),
    this.rawContent = const Value.absent(),
    this.sanitizedContent = const Value.absent(),
    this.clipType = const Value.absent(),
    this.originalTokens = const Value.absent(),
    this.sanitizedTokens = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.hadSecrets = const Value.absent(),
    this.redactionCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClipItemsCompanion.insert({
    this.id = const Value.absent(),
    required String rawContent,
    required String sanitizedContent,
    required int clipType,
    required int originalTokens,
    required int sanitizedTokens,
    this.isPinned = const Value.absent(),
    this.hadSecrets = const Value.absent(),
    this.redactionCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : rawContent = Value(rawContent),
       sanitizedContent = Value(sanitizedContent),
       clipType = Value(clipType),
       originalTokens = Value(originalTokens),
       sanitizedTokens = Value(sanitizedTokens);
  static Insertable<ClipItem> custom({
    Expression<int>? id,
    Expression<String>? rawContent,
    Expression<String>? sanitizedContent,
    Expression<int>? clipType,
    Expression<int>? originalTokens,
    Expression<int>? sanitizedTokens,
    Expression<bool>? isPinned,
    Expression<bool>? hadSecrets,
    Expression<int>? redactionCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawContent != null) 'raw_content': rawContent,
      if (sanitizedContent != null) 'sanitized_content': sanitizedContent,
      if (clipType != null) 'clip_type': clipType,
      if (originalTokens != null) 'original_tokens': originalTokens,
      if (sanitizedTokens != null) 'sanitized_tokens': sanitizedTokens,
      if (isPinned != null) 'is_pinned': isPinned,
      if (hadSecrets != null) 'had_secrets': hadSecrets,
      if (redactionCount != null) 'redaction_count': redactionCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClipItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? rawContent,
    Value<String>? sanitizedContent,
    Value<int>? clipType,
    Value<int>? originalTokens,
    Value<int>? sanitizedTokens,
    Value<bool>? isPinned,
    Value<bool>? hadSecrets,
    Value<int>? redactionCount,
    Value<DateTime>? createdAt,
  }) {
    return ClipItemsCompanion(
      id: id ?? this.id,
      rawContent: rawContent ?? this.rawContent,
      sanitizedContent: sanitizedContent ?? this.sanitizedContent,
      clipType: clipType ?? this.clipType,
      originalTokens: originalTokens ?? this.originalTokens,
      sanitizedTokens: sanitizedTokens ?? this.sanitizedTokens,
      isPinned: isPinned ?? this.isPinned,
      hadSecrets: hadSecrets ?? this.hadSecrets,
      redactionCount: redactionCount ?? this.redactionCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawContent.present) {
      map['raw_content'] = Variable<String>(rawContent.value);
    }
    if (sanitizedContent.present) {
      map['sanitized_content'] = Variable<String>(sanitizedContent.value);
    }
    if (clipType.present) {
      map['clip_type'] = Variable<int>(clipType.value);
    }
    if (originalTokens.present) {
      map['original_tokens'] = Variable<int>(originalTokens.value);
    }
    if (sanitizedTokens.present) {
      map['sanitized_tokens'] = Variable<int>(sanitizedTokens.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (hadSecrets.present) {
      map['had_secrets'] = Variable<bool>(hadSecrets.value);
    }
    if (redactionCount.present) {
      map['redaction_count'] = Variable<int>(redactionCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClipItemsCompanion(')
          ..write('id: $id, ')
          ..write('rawContent: $rawContent, ')
          ..write('sanitizedContent: $sanitizedContent, ')
          ..write('clipType: $clipType, ')
          ..write('originalTokens: $originalTokens, ')
          ..write('sanitizedTokens: $sanitizedTokens, ')
          ..write('isPinned: $isPinned, ')
          ..write('hadSecrets: $hadSecrets, ')
          ..write('redactionCount: $redactionCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClipItemsTable clipItems = $ClipItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [clipItems];
}

typedef $$ClipItemsTableCreateCompanionBuilder =
    ClipItemsCompanion Function({
      Value<int> id,
      required String rawContent,
      required String sanitizedContent,
      required int clipType,
      required int originalTokens,
      required int sanitizedTokens,
      Value<bool> isPinned,
      Value<bool> hadSecrets,
      Value<int> redactionCount,
      Value<DateTime> createdAt,
    });
typedef $$ClipItemsTableUpdateCompanionBuilder =
    ClipItemsCompanion Function({
      Value<int> id,
      Value<String> rawContent,
      Value<String> sanitizedContent,
      Value<int> clipType,
      Value<int> originalTokens,
      Value<int> sanitizedTokens,
      Value<bool> isPinned,
      Value<bool> hadSecrets,
      Value<int> redactionCount,
      Value<DateTime> createdAt,
    });

class $$ClipItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ClipItemsTable> {
  $$ClipItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sanitizedContent => $composableBuilder(
    column: $table.sanitizedContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clipType => $composableBuilder(
    column: $table.clipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalTokens => $composableBuilder(
    column: $table.originalTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sanitizedTokens => $composableBuilder(
    column: $table.sanitizedTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hadSecrets => $composableBuilder(
    column: $table.hadSecrets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redactionCount => $composableBuilder(
    column: $table.redactionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClipItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClipItemsTable> {
  $$ClipItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanitizedContent => $composableBuilder(
    column: $table.sanitizedContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clipType => $composableBuilder(
    column: $table.clipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalTokens => $composableBuilder(
    column: $table.originalTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sanitizedTokens => $composableBuilder(
    column: $table.sanitizedTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hadSecrets => $composableBuilder(
    column: $table.hadSecrets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redactionCount => $composableBuilder(
    column: $table.redactionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClipItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClipItemsTable> {
  $$ClipItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawContent => $composableBuilder(
    column: $table.rawContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sanitizedContent => $composableBuilder(
    column: $table.sanitizedContent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clipType =>
      $composableBuilder(column: $table.clipType, builder: (column) => column);

  GeneratedColumn<int> get originalTokens => $composableBuilder(
    column: $table.originalTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sanitizedTokens => $composableBuilder(
    column: $table.sanitizedTokens,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get hadSecrets => $composableBuilder(
    column: $table.hadSecrets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get redactionCount => $composableBuilder(
    column: $table.redactionCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ClipItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClipItemsTable,
          ClipItem,
          $$ClipItemsTableFilterComposer,
          $$ClipItemsTableOrderingComposer,
          $$ClipItemsTableAnnotationComposer,
          $$ClipItemsTableCreateCompanionBuilder,
          $$ClipItemsTableUpdateCompanionBuilder,
          (ClipItem, BaseReferences<_$AppDatabase, $ClipItemsTable, ClipItem>),
          ClipItem,
          PrefetchHooks Function()
        > {
  $$ClipItemsTableTableManager(_$AppDatabase db, $ClipItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClipItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClipItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClipItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rawContent = const Value.absent(),
                Value<String> sanitizedContent = const Value.absent(),
                Value<int> clipType = const Value.absent(),
                Value<int> originalTokens = const Value.absent(),
                Value<int> sanitizedTokens = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> hadSecrets = const Value.absent(),
                Value<int> redactionCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClipItemsCompanion(
                id: id,
                rawContent: rawContent,
                sanitizedContent: sanitizedContent,
                clipType: clipType,
                originalTokens: originalTokens,
                sanitizedTokens: sanitizedTokens,
                isPinned: isPinned,
                hadSecrets: hadSecrets,
                redactionCount: redactionCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawContent,
                required String sanitizedContent,
                required int clipType,
                required int originalTokens,
                required int sanitizedTokens,
                Value<bool> isPinned = const Value.absent(),
                Value<bool> hadSecrets = const Value.absent(),
                Value<int> redactionCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClipItemsCompanion.insert(
                id: id,
                rawContent: rawContent,
                sanitizedContent: sanitizedContent,
                clipType: clipType,
                originalTokens: originalTokens,
                sanitizedTokens: sanitizedTokens,
                isPinned: isPinned,
                hadSecrets: hadSecrets,
                redactionCount: redactionCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClipItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClipItemsTable,
      ClipItem,
      $$ClipItemsTableFilterComposer,
      $$ClipItemsTableOrderingComposer,
      $$ClipItemsTableAnnotationComposer,
      $$ClipItemsTableCreateCompanionBuilder,
      $$ClipItemsTableUpdateCompanionBuilder,
      (ClipItem, BaseReferences<_$AppDatabase, $ClipItemsTable, ClipItem>),
      ClipItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClipItemsTableTableManager get clipItems =>
      $$ClipItemsTableTableManager(_db, _db.clipItems);
}
