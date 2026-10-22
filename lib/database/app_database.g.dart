// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VillagesTable extends Villages
    with TableInfo<$VillagesTable, VillageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VillagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _townHallLevelMeta = const VerificationMeta(
    'townHallLevel',
  );
  @override
  late final GeneratedColumn<int> townHallLevel = GeneratedColumn<int>(
    'town_hall_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _builderCapacityMeta = const VerificationMeta(
    'builderCapacity',
  );
  @override
  late final GeneratedColumn<int> builderCapacity = GeneratedColumn<int>(
    'builder_capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    townHallLevel,
    builderCapacity,
    sortOrder,
    isArchived,
    notes,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'villages';
  @override
  VerificationContext validateIntegrity(
    Insertable<VillageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('town_hall_level')) {
      context.handle(
        _townHallLevelMeta,
        townHallLevel.isAcceptableOrUnknown(
          data['town_hall_level']!,
          _townHallLevelMeta,
        ),
      );
    }
    if (data.containsKey('builder_capacity')) {
      context.handle(
        _builderCapacityMeta,
        builderCapacity.isAcceptableOrUnknown(
          data['builder_capacity']!,
          _builderCapacityMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VillageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VillageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      townHallLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}town_hall_level'],
      ),
      builderCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}builder_capacity'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $VillagesTable createAlias(String alias) {
    return $VillagesTable(attachedDatabase, alias);
  }
}

class VillageRow extends DataClass implements Insertable<VillageRow> {
  final String id;
  final String name;
  final int? townHallLevel;
  final int builderCapacity;
  final int? sortOrder;
  final bool isArchived;
  final String? notes;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const VillageRow({
    required this.id,
    required this.name,
    this.townHallLevel,
    required this.builderCapacity,
    this.sortOrder,
    required this.isArchived,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || townHallLevel != null) {
      map['town_hall_level'] = Variable<int>(townHallLevel);
    }
    map['builder_capacity'] = Variable<int>(builderCapacity);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  VillagesCompanion toCompanion(bool nullToAbsent) {
    return VillagesCompanion(
      id: Value(id),
      name: Value(name),
      townHallLevel: townHallLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(townHallLevel),
      builderCapacity: Value(builderCapacity),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
      isArchived: Value(isArchived),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory VillageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VillageRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      townHallLevel: serializer.fromJson<int?>(json['townHallLevel']),
      builderCapacity: serializer.fromJson<int>(json['builderCapacity']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'townHallLevel': serializer.toJson<int?>(townHallLevel),
      'builderCapacity': serializer.toJson<int>(builderCapacity),
      'sortOrder': serializer.toJson<int?>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'notes': serializer.toJson<String?>(notes),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  VillageRow copyWith({
    String? id,
    String? name,
    Value<int?> townHallLevel = const Value.absent(),
    int? builderCapacity,
    Value<int?> sortOrder = const Value.absent(),
    bool? isArchived,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => VillageRow(
    id: id ?? this.id,
    name: name ?? this.name,
    townHallLevel: townHallLevel.present
        ? townHallLevel.value
        : this.townHallLevel,
    builderCapacity: builderCapacity ?? this.builderCapacity,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
    notes: notes.present ? notes.value : this.notes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  VillageRow copyWithCompanion(VillagesCompanion data) {
    return VillageRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      townHallLevel: data.townHallLevel.present
          ? data.townHallLevel.value
          : this.townHallLevel,
      builderCapacity: data.builderCapacity.present
          ? data.builderCapacity.value
          : this.builderCapacity,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VillageRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('townHallLevel: $townHallLevel, ')
          ..write('builderCapacity: $builderCapacity, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    townHallLevel,
    builderCapacity,
    sortOrder,
    isArchived,
    notes,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VillageRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.townHallLevel == this.townHallLevel &&
          other.builderCapacity == this.builderCapacity &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.notes == this.notes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class VillagesCompanion extends UpdateCompanion<VillageRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> townHallLevel;
  final Value<int> builderCapacity;
  final Value<int?> sortOrder;
  final Value<bool> isArchived;
  final Value<String?> notes;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const VillagesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.townHallLevel = const Value.absent(),
    this.builderCapacity = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VillagesCompanion.insert({
    required String id,
    required String name,
    this.townHallLevel = const Value.absent(),
    this.builderCapacity = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<VillageRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? townHallLevel,
    Expression<int>? builderCapacity,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<String>? notes,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (townHallLevel != null) 'town_hall_level': townHallLevel,
      if (builderCapacity != null) 'builder_capacity': builderCapacity,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (notes != null) 'notes': notes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VillagesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int?>? townHallLevel,
    Value<int>? builderCapacity,
    Value<int?>? sortOrder,
    Value<bool>? isArchived,
    Value<String?>? notes,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return VillagesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      townHallLevel: townHallLevel ?? this.townHallLevel,
      builderCapacity: builderCapacity ?? this.builderCapacity,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      notes: notes ?? this.notes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (townHallLevel.present) {
      map['town_hall_level'] = Variable<int>(townHallLevel.value);
    }
    if (builderCapacity.present) {
      map['builder_capacity'] = Variable<int>(builderCapacity.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VillagesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('townHallLevel: $townHallLevel, ')
          ..write('builderCapacity: $builderCapacity, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UpgradesTable extends Upgrades
    with TableInfo<$UpgradesTable, UpgradeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UpgradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES villages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotKeyMeta = const VerificationMeta(
    'slotKey',
  );
  @override
  late final GeneratedColumn<String> slotKey = GeneratedColumn<String>(
    'slot_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogItemIdMeta = const VerificationMeta(
    'catalogItemId',
  );
  @override
  late final GeneratedColumn<String> catalogItemId = GeneratedColumn<String>(
    'catalog_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedCompletionAtUtcMeta =
      const VerificationMeta('expectedCompletionAtUtc');
  @override
  late final GeneratedColumn<DateTime> expectedCompletionAtUtc =
      GeneratedColumn<DateTime>(
        'expected_completion_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtUtcMeta = const VerificationMeta(
    'completedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> completedAtUtc =
      GeneratedColumn<DateTime>(
        'completed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notificationRevisionMeta =
      const VerificationMeta('notificationRevision');
  @override
  late final GeneratedColumn<int> notificationRevision = GeneratedColumn<int>(
    'notification_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    villageId,
    name,
    category,
    slotKey,
    catalogItemId,
    durationSeconds,
    startedAtUtc,
    expectedCompletionAtUtc,
    status,
    completedAtUtc,
    notificationRevision,
    notes,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'upgrades';
  @override
  VerificationContext validateIntegrity(
    Insertable<UpgradeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_villageIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('slot_key')) {
      context.handle(
        _slotKeyMeta,
        slotKey.isAcceptableOrUnknown(data['slot_key']!, _slotKeyMeta),
      );
    }
    if (data.containsKey('catalog_item_id')) {
      context.handle(
        _catalogItemIdMeta,
        catalogItemId.isAcceptableOrUnknown(
          data['catalog_item_id']!,
          _catalogItemIdMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('expected_completion_at_utc')) {
      context.handle(
        _expectedCompletionAtUtcMeta,
        expectedCompletionAtUtc.isAcceptableOrUnknown(
          data['expected_completion_at_utc']!,
          _expectedCompletionAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedCompletionAtUtcMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at_utc')) {
      context.handle(
        _completedAtUtcMeta,
        completedAtUtc.isAcceptableOrUnknown(
          data['completed_at_utc']!,
          _completedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('notification_revision')) {
      context.handle(
        _notificationRevisionMeta,
        notificationRevision.isAcceptableOrUnknown(
          data['notification_revision']!,
          _notificationRevisionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UpgradeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UpgradeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      villageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      slotKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot_key'],
      ),
      catalogItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_item_id'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      )!,
      expectedCompletionAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_completion_at_utc'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at_utc'],
      ),
      notificationRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_revision'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $UpgradesTable createAlias(String alias) {
    return $UpgradesTable(attachedDatabase, alias);
  }
}

class UpgradeRow extends DataClass implements Insertable<UpgradeRow> {
  final String id;
  final String villageId;
  final String name;

  /// Stores the [UpgradeCategory] enum name as a string.
  final String category;
  final String? slotKey;
  final String? catalogItemId;
  final int? durationSeconds;
  final DateTime startedAtUtc;
  final DateTime expectedCompletionAtUtc;

  /// Stores the [UpgradeStatus] enum name as a string.
  final String status;
  final DateTime? completedAtUtc;
  final int notificationRevision;
  final String? notes;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const UpgradeRow({
    required this.id,
    required this.villageId,
    required this.name,
    required this.category,
    this.slotKey,
    this.catalogItemId,
    this.durationSeconds,
    required this.startedAtUtc,
    required this.expectedCompletionAtUtc,
    required this.status,
    this.completedAtUtc,
    required this.notificationRevision,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['village_id'] = Variable<String>(villageId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || slotKey != null) {
      map['slot_key'] = Variable<String>(slotKey);
    }
    if (!nullToAbsent || catalogItemId != null) {
      map['catalog_item_id'] = Variable<String>(catalogItemId);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    map['expected_completion_at_utc'] = Variable<DateTime>(
      expectedCompletionAtUtc,
    );
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc);
    }
    map['notification_revision'] = Variable<int>(notificationRevision);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  UpgradesCompanion toCompanion(bool nullToAbsent) {
    return UpgradesCompanion(
      id: Value(id),
      villageId: Value(villageId),
      name: Value(name),
      category: Value(category),
      slotKey: slotKey == null && nullToAbsent
          ? const Value.absent()
          : Value(slotKey),
      catalogItemId: catalogItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogItemId),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      startedAtUtc: Value(startedAtUtc),
      expectedCompletionAtUtc: Value(expectedCompletionAtUtc),
      status: Value(status),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      notificationRevision: Value(notificationRevision),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory UpgradeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UpgradeRow(
      id: serializer.fromJson<String>(json['id']),
      villageId: serializer.fromJson<String>(json['villageId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      slotKey: serializer.fromJson<String?>(json['slotKey']),
      catalogItemId: serializer.fromJson<String?>(json['catalogItemId']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      startedAtUtc: serializer.fromJson<DateTime>(json['startedAtUtc']),
      expectedCompletionAtUtc: serializer.fromJson<DateTime>(
        json['expectedCompletionAtUtc'],
      ),
      status: serializer.fromJson<String>(json['status']),
      completedAtUtc: serializer.fromJson<DateTime?>(json['completedAtUtc']),
      notificationRevision: serializer.fromJson<int>(
        json['notificationRevision'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'villageId': serializer.toJson<String>(villageId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'slotKey': serializer.toJson<String?>(slotKey),
      'catalogItemId': serializer.toJson<String?>(catalogItemId),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'startedAtUtc': serializer.toJson<DateTime>(startedAtUtc),
      'expectedCompletionAtUtc': serializer.toJson<DateTime>(
        expectedCompletionAtUtc,
      ),
      'status': serializer.toJson<String>(status),
      'completedAtUtc': serializer.toJson<DateTime?>(completedAtUtc),
      'notificationRevision': serializer.toJson<int>(notificationRevision),
      'notes': serializer.toJson<String?>(notes),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  UpgradeRow copyWith({
    String? id,
    String? villageId,
    String? name,
    String? category,
    Value<String?> slotKey = const Value.absent(),
    Value<String?> catalogItemId = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    DateTime? startedAtUtc,
    DateTime? expectedCompletionAtUtc,
    String? status,
    Value<DateTime?> completedAtUtc = const Value.absent(),
    int? notificationRevision,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => UpgradeRow(
    id: id ?? this.id,
    villageId: villageId ?? this.villageId,
    name: name ?? this.name,
    category: category ?? this.category,
    slotKey: slotKey.present ? slotKey.value : this.slotKey,
    catalogItemId: catalogItemId.present
        ? catalogItemId.value
        : this.catalogItemId,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    expectedCompletionAtUtc:
        expectedCompletionAtUtc ?? this.expectedCompletionAtUtc,
    status: status ?? this.status,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    notificationRevision: notificationRevision ?? this.notificationRevision,
    notes: notes.present ? notes.value : this.notes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  UpgradeRow copyWithCompanion(UpgradesCompanion data) {
    return UpgradeRow(
      id: data.id.present ? data.id.value : this.id,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      slotKey: data.slotKey.present ? data.slotKey.value : this.slotKey,
      catalogItemId: data.catalogItemId.present
          ? data.catalogItemId.value
          : this.catalogItemId,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      expectedCompletionAtUtc: data.expectedCompletionAtUtc.present
          ? data.expectedCompletionAtUtc.value
          : this.expectedCompletionAtUtc,
      status: data.status.present ? data.status.value : this.status,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      notificationRevision: data.notificationRevision.present
          ? data.notificationRevision.value
          : this.notificationRevision,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UpgradeRow(')
          ..write('id: $id, ')
          ..write('villageId: $villageId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('slotKey: $slotKey, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('expectedCompletionAtUtc: $expectedCompletionAtUtc, ')
          ..write('status: $status, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('notificationRevision: $notificationRevision, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    villageId,
    name,
    category,
    slotKey,
    catalogItemId,
    durationSeconds,
    startedAtUtc,
    expectedCompletionAtUtc,
    status,
    completedAtUtc,
    notificationRevision,
    notes,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpgradeRow &&
          other.id == this.id &&
          other.villageId == this.villageId &&
          other.name == this.name &&
          other.category == this.category &&
          other.slotKey == this.slotKey &&
          other.catalogItemId == this.catalogItemId &&
          other.durationSeconds == this.durationSeconds &&
          other.startedAtUtc == this.startedAtUtc &&
          other.expectedCompletionAtUtc == this.expectedCompletionAtUtc &&
          other.status == this.status &&
          other.completedAtUtc == this.completedAtUtc &&
          other.notificationRevision == this.notificationRevision &&
          other.notes == this.notes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class UpgradesCompanion extends UpdateCompanion<UpgradeRow> {
  final Value<String> id;
  final Value<String> villageId;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> slotKey;
  final Value<String?> catalogItemId;
  final Value<int?> durationSeconds;
  final Value<DateTime> startedAtUtc;
  final Value<DateTime> expectedCompletionAtUtc;
  final Value<String> status;
  final Value<DateTime?> completedAtUtc;
  final Value<int> notificationRevision;
  final Value<String?> notes;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const UpgradesCompanion({
    this.id = const Value.absent(),
    this.villageId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.slotKey = const Value.absent(),
    this.catalogItemId = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.expectedCompletionAtUtc = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.notificationRevision = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UpgradesCompanion.insert({
    required String id,
    required String villageId,
    required String name,
    required String category,
    this.slotKey = const Value.absent(),
    this.catalogItemId = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    required DateTime startedAtUtc,
    required DateTime expectedCompletionAtUtc,
    required String status,
    this.completedAtUtc = const Value.absent(),
    this.notificationRevision = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       villageId = Value(villageId),
       name = Value(name),
       category = Value(category),
       startedAtUtc = Value(startedAtUtc),
       expectedCompletionAtUtc = Value(expectedCompletionAtUtc),
       status = Value(status),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<UpgradeRow> custom({
    Expression<String>? id,
    Expression<String>? villageId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? slotKey,
    Expression<String>? catalogItemId,
    Expression<int>? durationSeconds,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? expectedCompletionAtUtc,
    Expression<String>? status,
    Expression<DateTime>? completedAtUtc,
    Expression<int>? notificationRevision,
    Expression<String>? notes,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (villageId != null) 'village_id': villageId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (slotKey != null) 'slot_key': slotKey,
      if (catalogItemId != null) 'catalog_item_id': catalogItemId,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (expectedCompletionAtUtc != null)
        'expected_completion_at_utc': expectedCompletionAtUtc,
      if (status != null) 'status': status,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (notificationRevision != null)
        'notification_revision': notificationRevision,
      if (notes != null) 'notes': notes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UpgradesCompanion copyWith({
    Value<String>? id,
    Value<String>? villageId,
    Value<String>? name,
    Value<String>? category,
    Value<String?>? slotKey,
    Value<String?>? catalogItemId,
    Value<int?>? durationSeconds,
    Value<DateTime>? startedAtUtc,
    Value<DateTime>? expectedCompletionAtUtc,
    Value<String>? status,
    Value<DateTime?>? completedAtUtc,
    Value<int>? notificationRevision,
    Value<String?>? notes,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return UpgradesCompanion(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      name: name ?? this.name,
      category: category ?? this.category,
      slotKey: slotKey ?? this.slotKey,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      expectedCompletionAtUtc:
          expectedCompletionAtUtc ?? this.expectedCompletionAtUtc,
      status: status ?? this.status,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      notificationRevision: notificationRevision ?? this.notificationRevision,
      notes: notes ?? this.notes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (slotKey.present) {
      map['slot_key'] = Variable<String>(slotKey.value);
    }
    if (catalogItemId.present) {
      map['catalog_item_id'] = Variable<String>(catalogItemId.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    if (expectedCompletionAtUtc.present) {
      map['expected_completion_at_utc'] = Variable<DateTime>(
        expectedCompletionAtUtc.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc.value);
    }
    if (notificationRevision.present) {
      map['notification_revision'] = Variable<int>(notificationRevision.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UpgradesCompanion(')
          ..write('id: $id, ')
          ..write('villageId: $villageId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('slotKey: $slotKey, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('expectedCompletionAtUtc: $expectedCompletionAtUtc, ')
          ..write('status: $status, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('notificationRevision: $notificationRevision, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationPreferencesTable extends NotificationPreferences
    with TableInfo<$NotificationPreferencesTable, NotificationPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionEnabledMeta = const VerificationMeta(
    'completionEnabled',
  );
  @override
  late final GeneratedColumn<bool> completionEnabled = GeneratedColumn<bool>(
    'completion_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completion_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _preAlertsEnabledMeta = const VerificationMeta(
    'preAlertsEnabled',
  );
  @override
  late final GeneratedColumn<bool> preAlertsEnabled = GeneratedColumn<bool>(
    'pre_alerts_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pre_alerts_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderOffsetMinutesJsonMeta =
      const VerificationMeta('reminderOffsetMinutesJson');
  @override
  late final GeneratedColumn<String> reminderOffsetMinutesJson =
      GeneratedColumn<String>(
        'reminder_offset_minutes_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[30,5]'),
      );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    completionEnabled,
    preAlertsEnabled,
    reminderOffsetMinutesJson,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('completion_enabled')) {
      context.handle(
        _completionEnabledMeta,
        completionEnabled.isAcceptableOrUnknown(
          data['completion_enabled']!,
          _completionEnabledMeta,
        ),
      );
    }
    if (data.containsKey('pre_alerts_enabled')) {
      context.handle(
        _preAlertsEnabledMeta,
        preAlertsEnabled.isAcceptableOrUnknown(
          data['pre_alerts_enabled']!,
          _preAlertsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_offset_minutes_json')) {
      context.handle(
        _reminderOffsetMinutesJsonMeta,
        reminderOffsetMinutesJson.isAcceptableOrUnknown(
          data['reminder_offset_minutes_json']!,
          _reminderOffsetMinutesJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      completionEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completion_enabled'],
      )!,
      preAlertsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pre_alerts_enabled'],
      )!,
      reminderOffsetMinutesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_offset_minutes_json'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $NotificationPreferencesTable createAlias(String alias) {
    return $NotificationPreferencesTable(attachedDatabase, alias);
  }
}

class NotificationPreference extends DataClass
    implements Insertable<NotificationPreference> {
  final int id;
  final bool completionEnabled;
  final bool preAlertsEnabled;

  /// JSON-encoded list of integer minute offsets, e.g. "[30,5]".
  final String reminderOffsetMinutesJson;
  final DateTime updatedAtUtc;
  const NotificationPreference({
    required this.id,
    required this.completionEnabled,
    required this.preAlertsEnabled,
    required this.reminderOffsetMinutesJson,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['completion_enabled'] = Variable<bool>(completionEnabled);
    map['pre_alerts_enabled'] = Variable<bool>(preAlertsEnabled);
    map['reminder_offset_minutes_json'] = Variable<String>(
      reminderOffsetMinutesJson,
    );
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  NotificationPreferencesCompanion toCompanion(bool nullToAbsent) {
    return NotificationPreferencesCompanion(
      id: Value(id),
      completionEnabled: Value(completionEnabled),
      preAlertsEnabled: Value(preAlertsEnabled),
      reminderOffsetMinutesJson: Value(reminderOffsetMinutesJson),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory NotificationPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationPreference(
      id: serializer.fromJson<int>(json['id']),
      completionEnabled: serializer.fromJson<bool>(json['completionEnabled']),
      preAlertsEnabled: serializer.fromJson<bool>(json['preAlertsEnabled']),
      reminderOffsetMinutesJson: serializer.fromJson<String>(
        json['reminderOffsetMinutesJson'],
      ),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'completionEnabled': serializer.toJson<bool>(completionEnabled),
      'preAlertsEnabled': serializer.toJson<bool>(preAlertsEnabled),
      'reminderOffsetMinutesJson': serializer.toJson<String>(
        reminderOffsetMinutesJson,
      ),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  NotificationPreference copyWith({
    int? id,
    bool? completionEnabled,
    bool? preAlertsEnabled,
    String? reminderOffsetMinutesJson,
    DateTime? updatedAtUtc,
  }) => NotificationPreference(
    id: id ?? this.id,
    completionEnabled: completionEnabled ?? this.completionEnabled,
    preAlertsEnabled: preAlertsEnabled ?? this.preAlertsEnabled,
    reminderOffsetMinutesJson:
        reminderOffsetMinutesJson ?? this.reminderOffsetMinutesJson,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  NotificationPreference copyWithCompanion(
    NotificationPreferencesCompanion data,
  ) {
    return NotificationPreference(
      id: data.id.present ? data.id.value : this.id,
      completionEnabled: data.completionEnabled.present
          ? data.completionEnabled.value
          : this.completionEnabled,
      preAlertsEnabled: data.preAlertsEnabled.present
          ? data.preAlertsEnabled.value
          : this.preAlertsEnabled,
      reminderOffsetMinutesJson: data.reminderOffsetMinutesJson.present
          ? data.reminderOffsetMinutesJson.value
          : this.reminderOffsetMinutesJson,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationPreference(')
          ..write('id: $id, ')
          ..write('completionEnabled: $completionEnabled, ')
          ..write('preAlertsEnabled: $preAlertsEnabled, ')
          ..write('reminderOffsetMinutesJson: $reminderOffsetMinutesJson, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    completionEnabled,
    preAlertsEnabled,
    reminderOffsetMinutesJson,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationPreference &&
          other.id == this.id &&
          other.completionEnabled == this.completionEnabled &&
          other.preAlertsEnabled == this.preAlertsEnabled &&
          other.reminderOffsetMinutesJson == this.reminderOffsetMinutesJson &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class NotificationPreferencesCompanion
    extends UpdateCompanion<NotificationPreference> {
  final Value<int> id;
  final Value<bool> completionEnabled;
  final Value<bool> preAlertsEnabled;
  final Value<String> reminderOffsetMinutesJson;
  final Value<DateTime> updatedAtUtc;
  const NotificationPreferencesCompanion({
    this.id = const Value.absent(),
    this.completionEnabled = const Value.absent(),
    this.preAlertsEnabled = const Value.absent(),
    this.reminderOffsetMinutesJson = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  NotificationPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.completionEnabled = const Value.absent(),
    this.preAlertsEnabled = const Value.absent(),
    this.reminderOffsetMinutesJson = const Value.absent(),
    required DateTime updatedAtUtc,
  }) : updatedAtUtc = Value(updatedAtUtc);
  static Insertable<NotificationPreference> custom({
    Expression<int>? id,
    Expression<bool>? completionEnabled,
    Expression<bool>? preAlertsEnabled,
    Expression<String>? reminderOffsetMinutesJson,
    Expression<DateTime>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (completionEnabled != null) 'completion_enabled': completionEnabled,
      if (preAlertsEnabled != null) 'pre_alerts_enabled': preAlertsEnabled,
      if (reminderOffsetMinutesJson != null)
        'reminder_offset_minutes_json': reminderOffsetMinutesJson,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  NotificationPreferencesCompanion copyWith({
    Value<int>? id,
    Value<bool>? completionEnabled,
    Value<bool>? preAlertsEnabled,
    Value<String>? reminderOffsetMinutesJson,
    Value<DateTime>? updatedAtUtc,
  }) {
    return NotificationPreferencesCompanion(
      id: id ?? this.id,
      completionEnabled: completionEnabled ?? this.completionEnabled,
      preAlertsEnabled: preAlertsEnabled ?? this.preAlertsEnabled,
      reminderOffsetMinutesJson:
          reminderOffsetMinutesJson ?? this.reminderOffsetMinutesJson,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (completionEnabled.present) {
      map['completion_enabled'] = Variable<bool>(completionEnabled.value);
    }
    if (preAlertsEnabled.present) {
      map['pre_alerts_enabled'] = Variable<bool>(preAlertsEnabled.value);
    }
    if (reminderOffsetMinutesJson.present) {
      map['reminder_offset_minutes_json'] = Variable<String>(
        reminderOffsetMinutesJson.value,
      );
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('completionEnabled: $completionEnabled, ')
          ..write('preAlertsEnabled: $preAlertsEnabled, ')
          ..write('reminderOffsetMinutesJson: $reminderOffsetMinutesJson, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $HistoryEventsTable extends HistoryEvents
    with TableInfo<$HistoryEventsTable, HistoryEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upgradeIdMeta = const VerificationMeta(
    'upgradeId',
  );
  @override
  late final GeneratedColumn<String> upgradeId = GeneratedColumn<String>(
    'upgrade_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upgradeNameMeta = const VerificationMeta(
    'upgradeName',
  );
  @override
  late final GeneratedColumn<String> upgradeName = GeneratedColumn<String>(
    'upgrade_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageNameMeta = const VerificationMeta(
    'villageName',
  );
  @override
  late final GeneratedColumn<String> villageName = GeneratedColumn<String>(
    'village_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    upgradeId,
    villageId,
    eventType,
    description,
    upgradeName,
    villageName,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('upgrade_id')) {
      context.handle(
        _upgradeIdMeta,
        upgradeId.isAcceptableOrUnknown(data['upgrade_id']!, _upgradeIdMeta),
      );
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('upgrade_name')) {
      context.handle(
        _upgradeNameMeta,
        upgradeName.isAcceptableOrUnknown(
          data['upgrade_name']!,
          _upgradeNameMeta,
        ),
      );
    }
    if (data.containsKey('village_name')) {
      context.handle(
        _villageNameMeta,
        villageName.isAcceptableOrUnknown(
          data['village_name']!,
          _villageNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      upgradeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upgrade_id'],
      ),
      villageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      upgradeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upgrade_name'],
      ),
      villageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village_name'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $HistoryEventsTable createAlias(String alias) {
    return $HistoryEventsTable(attachedDatabase, alias);
  }
}

class HistoryEventRow extends DataClass implements Insertable<HistoryEventRow> {
  final String id;
  final String? upgradeId;
  final String? villageId;
  final String eventType;
  final String description;
  final String? upgradeName;
  final String? villageName;
  final DateTime createdAtUtc;
  const HistoryEventRow({
    required this.id,
    this.upgradeId,
    this.villageId,
    required this.eventType,
    required this.description,
    this.upgradeName,
    this.villageName,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || upgradeId != null) {
      map['upgrade_id'] = Variable<String>(upgradeId);
    }
    if (!nullToAbsent || villageId != null) {
      map['village_id'] = Variable<String>(villageId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || upgradeName != null) {
      map['upgrade_name'] = Variable<String>(upgradeName);
    }
    if (!nullToAbsent || villageName != null) {
      map['village_name'] = Variable<String>(villageName);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    return map;
  }

  HistoryEventsCompanion toCompanion(bool nullToAbsent) {
    return HistoryEventsCompanion(
      id: Value(id),
      upgradeId: upgradeId == null && nullToAbsent
          ? const Value.absent()
          : Value(upgradeId),
      villageId: villageId == null && nullToAbsent
          ? const Value.absent()
          : Value(villageId),
      eventType: Value(eventType),
      description: Value(description),
      upgradeName: upgradeName == null && nullToAbsent
          ? const Value.absent()
          : Value(upgradeName),
      villageName: villageName == null && nullToAbsent
          ? const Value.absent()
          : Value(villageName),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory HistoryEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEventRow(
      id: serializer.fromJson<String>(json['id']),
      upgradeId: serializer.fromJson<String?>(json['upgradeId']),
      villageId: serializer.fromJson<String?>(json['villageId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      description: serializer.fromJson<String>(json['description']),
      upgradeName: serializer.fromJson<String?>(json['upgradeName']),
      villageName: serializer.fromJson<String?>(json['villageName']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'upgradeId': serializer.toJson<String?>(upgradeId),
      'villageId': serializer.toJson<String?>(villageId),
      'eventType': serializer.toJson<String>(eventType),
      'description': serializer.toJson<String>(description),
      'upgradeName': serializer.toJson<String?>(upgradeName),
      'villageName': serializer.toJson<String?>(villageName),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
    };
  }

  HistoryEventRow copyWith({
    String? id,
    Value<String?> upgradeId = const Value.absent(),
    Value<String?> villageId = const Value.absent(),
    String? eventType,
    String? description,
    Value<String?> upgradeName = const Value.absent(),
    Value<String?> villageName = const Value.absent(),
    DateTime? createdAtUtc,
  }) => HistoryEventRow(
    id: id ?? this.id,
    upgradeId: upgradeId.present ? upgradeId.value : this.upgradeId,
    villageId: villageId.present ? villageId.value : this.villageId,
    eventType: eventType ?? this.eventType,
    description: description ?? this.description,
    upgradeName: upgradeName.present ? upgradeName.value : this.upgradeName,
    villageName: villageName.present ? villageName.value : this.villageName,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  HistoryEventRow copyWithCompanion(HistoryEventsCompanion data) {
    return HistoryEventRow(
      id: data.id.present ? data.id.value : this.id,
      upgradeId: data.upgradeId.present ? data.upgradeId.value : this.upgradeId,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      description: data.description.present
          ? data.description.value
          : this.description,
      upgradeName: data.upgradeName.present
          ? data.upgradeName.value
          : this.upgradeName,
      villageName: data.villageName.present
          ? data.villageName.value
          : this.villageName,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEventRow(')
          ..write('id: $id, ')
          ..write('upgradeId: $upgradeId, ')
          ..write('villageId: $villageId, ')
          ..write('eventType: $eventType, ')
          ..write('description: $description, ')
          ..write('upgradeName: $upgradeName, ')
          ..write('villageName: $villageName, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    upgradeId,
    villageId,
    eventType,
    description,
    upgradeName,
    villageName,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEventRow &&
          other.id == this.id &&
          other.upgradeId == this.upgradeId &&
          other.villageId == this.villageId &&
          other.eventType == this.eventType &&
          other.description == this.description &&
          other.upgradeName == this.upgradeName &&
          other.villageName == this.villageName &&
          other.createdAtUtc == this.createdAtUtc);
}

class HistoryEventsCompanion extends UpdateCompanion<HistoryEventRow> {
  final Value<String> id;
  final Value<String?> upgradeId;
  final Value<String?> villageId;
  final Value<String> eventType;
  final Value<String> description;
  final Value<String?> upgradeName;
  final Value<String?> villageName;
  final Value<DateTime> createdAtUtc;
  final Value<int> rowid;
  const HistoryEventsCompanion({
    this.id = const Value.absent(),
    this.upgradeId = const Value.absent(),
    this.villageId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.description = const Value.absent(),
    this.upgradeName = const Value.absent(),
    this.villageName = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryEventsCompanion.insert({
    required String id,
    this.upgradeId = const Value.absent(),
    this.villageId = const Value.absent(),
    required String eventType,
    required String description,
    this.upgradeName = const Value.absent(),
    this.villageName = const Value.absent(),
    required DateTime createdAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventType = Value(eventType),
       description = Value(description),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<HistoryEventRow> custom({
    Expression<String>? id,
    Expression<String>? upgradeId,
    Expression<String>? villageId,
    Expression<String>? eventType,
    Expression<String>? description,
    Expression<String>? upgradeName,
    Expression<String>? villageName,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (upgradeId != null) 'upgrade_id': upgradeId,
      if (villageId != null) 'village_id': villageId,
      if (eventType != null) 'event_type': eventType,
      if (description != null) 'description': description,
      if (upgradeName != null) 'upgrade_name': upgradeName,
      if (villageName != null) 'village_name': villageName,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryEventsCompanion copyWith({
    Value<String>? id,
    Value<String?>? upgradeId,
    Value<String?>? villageId,
    Value<String>? eventType,
    Value<String>? description,
    Value<String?>? upgradeName,
    Value<String?>? villageName,
    Value<DateTime>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return HistoryEventsCompanion(
      id: id ?? this.id,
      upgradeId: upgradeId ?? this.upgradeId,
      villageId: villageId ?? this.villageId,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      upgradeName: upgradeName ?? this.upgradeName,
      villageName: villageName ?? this.villageName,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (upgradeId.present) {
      map['upgrade_id'] = Variable<String>(upgradeId.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (upgradeName.present) {
      map['upgrade_name'] = Variable<String>(upgradeName.value);
    }
    if (villageName.present) {
      map['village_name'] = Variable<String>(villageName.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEventsCompanion(')
          ..write('id: $id, ')
          ..write('upgradeId: $upgradeId, ')
          ..write('villageId: $villageId, ')
          ..write('eventType: $eventType, ')
          ..write('description: $description, ')
          ..write('upgradeName: $upgradeName, ')
          ..write('villageName: $villageName, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VillagesTable villages = $VillagesTable(this);
  late final $UpgradesTable upgrades = $UpgradesTable(this);
  late final $NotificationPreferencesTable notificationPreferences =
      $NotificationPreferencesTable(this);
  late final $HistoryEventsTable historyEvents = $HistoryEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    villages,
    upgrades,
    notificationPreferences,
    historyEvents,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'villages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('upgrades', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VillagesTableCreateCompanionBuilder = VillagesCompanion Function({
  required String id,
  required String name,
  Value<int?> townHallLevel,
  Value<int> builderCapacity,
  Value<int?> sortOrder,
  Value<bool> isArchived,
  Value<String?> notes,
  required DateTime createdAtUtc,
  required DateTime updatedAtUtc,
  Value<int> rowid,
});
typedef $$VillagesTableUpdateCompanionBuilder = VillagesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> townHallLevel,
  Value<int> builderCapacity,
  Value<int?> sortOrder,
  Value<bool> isArchived,
  Value<String?> notes,
  Value<DateTime> createdAtUtc,
  Value<DateTime> updatedAtUtc,
  Value<int> rowid,
});

final class $$VillagesTableReferences
    extends BaseReferences<_$AppDatabase, $VillagesTable, VillageRow> {
  $$VillagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UpgradesTable, List<UpgradeRow>>
  _upgradesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.upgrades,
    aliasName: 'villages__id__upgrades__village_id',
  );

  $$UpgradesTableProcessedTableManager get upgradesRefs {
    final manager = $$UpgradesTableTableManager(
      $_db,
      $_db.upgrades,
    ).filter((f) => f.villageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_upgradesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VillagesTableFilterComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get townHallLevel => $composableBuilder(
    column: $table.townHallLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get builderCapacity => $composableBuilder(
    column: $table.builderCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> upgradesRefs(
    Expression<bool> Function($$UpgradesTableFilterComposer f) f,
  ) {
    final $$UpgradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.upgrades,
      getReferencedColumn: (t) => t.villageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpgradesTableFilterComposer(
            $db: $db,
            $table: $db.upgrades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VillagesTableOrderingComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get townHallLevel => $composableBuilder(
    column: $table.townHallLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get builderCapacity => $composableBuilder(
    column: $table.builderCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VillagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get townHallLevel => $composableBuilder(
    column: $table.townHallLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get builderCapacity => $composableBuilder(
    column: $table.builderCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  Expression<T> upgradesRefs<T extends Object>(
    Expression<T> Function($$UpgradesTableAnnotationComposer a) f,
  ) {
    final $$UpgradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.upgrades,
      getReferencedColumn: (t) => t.villageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpgradesTableAnnotationComposer(
            $db: $db,
            $table: $db.upgrades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VillagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VillagesTable,
          VillageRow,
          $$VillagesTableFilterComposer,
          $$VillagesTableOrderingComposer,
          $$VillagesTableAnnotationComposer,
          $$VillagesTableCreateCompanionBuilder,
          $$VillagesTableUpdateCompanionBuilder,
          (VillageRow, $$VillagesTableReferences),
          VillageRow,
          PrefetchHooks Function({bool upgradesRefs})
        > {
  $$VillagesTableTableManager(_$AppDatabase db, $VillagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VillagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VillagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VillagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> townHallLevel = const Value.absent(),
                Value<int> builderCapacity = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VillagesCompanion(
                id: id,
                name: name,
                townHallLevel: townHallLevel,
                builderCapacity: builderCapacity,
                sortOrder: sortOrder,
                isArchived: isArchived,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int?> townHallLevel = const Value.absent(),
                Value<int> builderCapacity = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => VillagesCompanion.insert(
                id: id,
                name: name,
                townHallLevel: townHallLevel,
                builderCapacity: builderCapacity,
                sortOrder: sortOrder,
                isArchived: isArchived,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VillagesTable, VillageRow>(table),
                  $$VillagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({upgradesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (upgradesRefs) db.upgrades],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (upgradesRefs)
                    await $_getPrefetchedData<
                      VillageRow,
                      $VillagesTable,
                      UpgradeRow
                    >(
                      currentTable: table,
                      referencedTable: $$VillagesTableReferences
                          ._upgradesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VillagesTableReferences(db, table, p0).upgradesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.villageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VillagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VillagesTable,
      VillageRow,
      $$VillagesTableFilterComposer,
      $$VillagesTableOrderingComposer,
      $$VillagesTableAnnotationComposer,
      $$VillagesTableCreateCompanionBuilder,
      $$VillagesTableUpdateCompanionBuilder,
      (VillageRow, $$VillagesTableReferences),
      VillageRow,
      PrefetchHooks Function({bool upgradesRefs})
    >;
typedef $$UpgradesTableCreateCompanionBuilder = UpgradesCompanion Function({
  required String id,
  required String villageId,
  required String name,
  required String category,
  Value<String?> slotKey,
  Value<String?> catalogItemId,
  Value<int?> durationSeconds,
  required DateTime startedAtUtc,
  required DateTime expectedCompletionAtUtc,
  required String status,
  Value<DateTime?> completedAtUtc,
  Value<int> notificationRevision,
  Value<String?> notes,
  required DateTime createdAtUtc,
  required DateTime updatedAtUtc,
  Value<int> rowid,
});
typedef $$UpgradesTableUpdateCompanionBuilder = UpgradesCompanion Function({
  Value<String> id,
  Value<String> villageId,
  Value<String> name,
  Value<String> category,
  Value<String?> slotKey,
  Value<String?> catalogItemId,
  Value<int?> durationSeconds,
  Value<DateTime> startedAtUtc,
  Value<DateTime> expectedCompletionAtUtc,
  Value<String> status,
  Value<DateTime?> completedAtUtc,
  Value<int> notificationRevision,
  Value<String?> notes,
  Value<DateTime> createdAtUtc,
  Value<DateTime> updatedAtUtc,
  Value<int> rowid,
});

final class $$UpgradesTableReferences
    extends BaseReferences<_$AppDatabase, $UpgradesTable, UpgradeRow> {
  $$UpgradesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VillagesTable _villageIdTable(_$AppDatabase db) =>
      db.villages.createAlias('upgrades__village_id__villages__id');

  $$VillagesTableProcessedTableManager get villageId {
    final $_column = $_itemColumn<String>('village_id')!;

    final manager = $$VillagesTableTableManager(
      $_db,
      $_db.villages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_villageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UpgradesTableFilterComposer
    extends Composer<_$AppDatabase, $UpgradesTable> {
  $$UpgradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slotKey => $composableBuilder(
    column: $table.slotKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogItemId => $composableBuilder(
    column: $table.catalogItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expectedCompletionAtUtc => $composableBuilder(
    column: $table.expectedCompletionAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationRevision => $composableBuilder(
    column: $table.notificationRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$VillagesTableFilterComposer get villageId {
    final $$VillagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.villageId,
      referencedTable: $db.villages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VillagesTableFilterComposer(
            $db: $db,
            $table: $db.villages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpgradesTableOrderingComposer
    extends Composer<_$AppDatabase, $UpgradesTable> {
  $$UpgradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slotKey => $composableBuilder(
    column: $table.slotKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogItemId => $composableBuilder(
    column: $table.catalogItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expectedCompletionAtUtc => $composableBuilder(
    column: $table.expectedCompletionAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationRevision => $composableBuilder(
    column: $table.notificationRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$VillagesTableOrderingComposer get villageId {
    final $$VillagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.villageId,
      referencedTable: $db.villages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VillagesTableOrderingComposer(
            $db: $db,
            $table: $db.villages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpgradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UpgradesTable> {
  $$UpgradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get slotKey =>
      $composableBuilder(column: $table.slotKey, builder: (column) => column);

  GeneratedColumn<String> get catalogItemId => $composableBuilder(
    column: $table.catalogItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expectedCompletionAtUtc => $composableBuilder(
    column: $table.expectedCompletionAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationRevision => $composableBuilder(
    column: $table.notificationRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$VillagesTableAnnotationComposer get villageId {
    final $$VillagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.villageId,
      referencedTable: $db.villages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VillagesTableAnnotationComposer(
            $db: $db,
            $table: $db.villages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpgradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UpgradesTable,
          UpgradeRow,
          $$UpgradesTableFilterComposer,
          $$UpgradesTableOrderingComposer,
          $$UpgradesTableAnnotationComposer,
          $$UpgradesTableCreateCompanionBuilder,
          $$UpgradesTableUpdateCompanionBuilder,
          (UpgradeRow, $$UpgradesTableReferences),
          UpgradeRow,
          PrefetchHooks Function({bool villageId})
        > {
  $$UpgradesTableTableManager(_$AppDatabase db, $UpgradesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UpgradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UpgradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UpgradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> villageId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> slotKey = const Value.absent(),
                Value<String?> catalogItemId = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime> startedAtUtc = const Value.absent(),
                Value<DateTime> expectedCompletionAtUtc = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<int> notificationRevision = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UpgradesCompanion(
                id: id,
                villageId: villageId,
                name: name,
                category: category,
                slotKey: slotKey,
                catalogItemId: catalogItemId,
                durationSeconds: durationSeconds,
                startedAtUtc: startedAtUtc,
                expectedCompletionAtUtc: expectedCompletionAtUtc,
                status: status,
                completedAtUtc: completedAtUtc,
                notificationRevision: notificationRevision,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String villageId,
                required String name,
                required String category,
                Value<String?> slotKey = const Value.absent(),
                Value<String?> catalogItemId = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                required DateTime startedAtUtc,
                required DateTime expectedCompletionAtUtc,
                required String status,
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<int> notificationRevision = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => UpgradesCompanion.insert(
                id: id,
                villageId: villageId,
                name: name,
                category: category,
                slotKey: slotKey,
                catalogItemId: catalogItemId,
                durationSeconds: durationSeconds,
                startedAtUtc: startedAtUtc,
                expectedCompletionAtUtc: expectedCompletionAtUtc,
                status: status,
                completedAtUtc: completedAtUtc,
                notificationRevision: notificationRevision,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UpgradesTable, UpgradeRow>(table),
                  $$UpgradesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({villageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (villageId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.villageId,
                        referencedTable: $$UpgradesTableReferences
                            ._villageIdTable(db),
                        referencedColumn: $$UpgradesTableReferences
                            ._villageIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UpgradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UpgradesTable,
      UpgradeRow,
      $$UpgradesTableFilterComposer,
      $$UpgradesTableOrderingComposer,
      $$UpgradesTableAnnotationComposer,
      $$UpgradesTableCreateCompanionBuilder,
      $$UpgradesTableUpdateCompanionBuilder,
      (UpgradeRow, $$UpgradesTableReferences),
      UpgradeRow,
      PrefetchHooks Function({bool villageId})
    >;
typedef $$NotificationPreferencesTableCreateCompanionBuilder =
    NotificationPreferencesCompanion Function({
      Value<int> id,
      Value<bool> completionEnabled,
      Value<bool> preAlertsEnabled,
      Value<String> reminderOffsetMinutesJson,
      required DateTime updatedAtUtc,
    });
typedef $$NotificationPreferencesTableUpdateCompanionBuilder =
    NotificationPreferencesCompanion Function({
      Value<int> id,
      Value<bool> completionEnabled,
      Value<bool> preAlertsEnabled,
      Value<String> reminderOffsetMinutesJson,
      Value<DateTime> updatedAtUtc,
    });

class $$NotificationPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationPreferencesTable> {
  $$NotificationPreferencesTableFilterComposer({
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

  ColumnFilters<bool> get completionEnabled => $composableBuilder(
    column: $table.completionEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get preAlertsEnabled => $composableBuilder(
    column: $table.preAlertsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderOffsetMinutesJson => $composableBuilder(
    column: $table.reminderOffsetMinutesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationPreferencesTable> {
  $$NotificationPreferencesTableOrderingComposer({
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

  ColumnOrderings<bool> get completionEnabled => $composableBuilder(
    column: $table.completionEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get preAlertsEnabled => $composableBuilder(
    column: $table.preAlertsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderOffsetMinutesJson => $composableBuilder(
    column: $table.reminderOffsetMinutesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationPreferencesTable> {
  $$NotificationPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get completionEnabled => $composableBuilder(
    column: $table.completionEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get preAlertsEnabled => $composableBuilder(
    column: $table.preAlertsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderOffsetMinutesJson => $composableBuilder(
    column: $table.reminderOffsetMinutesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$NotificationPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationPreferencesTable,
          NotificationPreference,
          $$NotificationPreferencesTableFilterComposer,
          $$NotificationPreferencesTableOrderingComposer,
          $$NotificationPreferencesTableAnnotationComposer,
          $$NotificationPreferencesTableCreateCompanionBuilder,
          $$NotificationPreferencesTableUpdateCompanionBuilder,
          (
            NotificationPreference,
            BaseReferences<
              _$AppDatabase,
              $NotificationPreferencesTable,
              NotificationPreference
            >,
          ),
          NotificationPreference,
          PrefetchHooks Function()
        > {
  $$NotificationPreferencesTableTableManager(
    _$AppDatabase db,
    $NotificationPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationPreferencesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> completionEnabled = const Value.absent(),
                Value<bool> preAlertsEnabled = const Value.absent(),
                Value<String> reminderOffsetMinutesJson = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
              }) => NotificationPreferencesCompanion(
                id: id,
                completionEnabled: completionEnabled,
                preAlertsEnabled: preAlertsEnabled,
                reminderOffsetMinutesJson: reminderOffsetMinutesJson,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> completionEnabled = const Value.absent(),
                Value<bool> preAlertsEnabled = const Value.absent(),
                Value<String> reminderOffsetMinutesJson = const Value.absent(),
                required DateTime updatedAtUtc,
              }) => NotificationPreferencesCompanion.insert(
                id: id,
                completionEnabled: completionEnabled,
                preAlertsEnabled: preAlertsEnabled,
                reminderOffsetMinutesJson: reminderOffsetMinutesJson,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $NotificationPreferencesTable,
                    NotificationPreference
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NotificationPreferencesTable,
                    NotificationPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationPreferencesTable,
      NotificationPreference,
      $$NotificationPreferencesTableFilterComposer,
      $$NotificationPreferencesTableOrderingComposer,
      $$NotificationPreferencesTableAnnotationComposer,
      $$NotificationPreferencesTableCreateCompanionBuilder,
      $$NotificationPreferencesTableUpdateCompanionBuilder,
      (
        NotificationPreference,
        BaseReferences<
          _$AppDatabase,
          $NotificationPreferencesTable,
          NotificationPreference
        >,
      ),
      NotificationPreference,
      PrefetchHooks Function()
    >;
typedef $$HistoryEventsTableCreateCompanionBuilder =
    HistoryEventsCompanion Function({
      required String id,
      Value<String?> upgradeId,
      Value<String?> villageId,
      required String eventType,
      required String description,
      Value<String?> upgradeName,
      Value<String?> villageName,
      required DateTime createdAtUtc,
      Value<int> rowid,
    });
typedef $$HistoryEventsTableUpdateCompanionBuilder =
    HistoryEventsCompanion Function({
      Value<String> id,
      Value<String?> upgradeId,
      Value<String?> villageId,
      Value<String> eventType,
      Value<String> description,
      Value<String?> upgradeName,
      Value<String?> villageName,
      Value<DateTime> createdAtUtc,
      Value<int> rowid,
    });

class $$HistoryEventsTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upgradeId => $composableBuilder(
    column: $table.upgradeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upgradeName => $composableBuilder(
    column: $table.upgradeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageName => $composableBuilder(
    column: $table.villageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upgradeId => $composableBuilder(
    column: $table.upgradeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upgradeName => $composableBuilder(
    column: $table.upgradeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageName => $composableBuilder(
    column: $table.villageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get upgradeId =>
      $composableBuilder(column: $table.upgradeId, builder: (column) => column);

  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get upgradeName => $composableBuilder(
    column: $table.upgradeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get villageName => $composableBuilder(
    column: $table.villageName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$HistoryEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEventsTable,
          HistoryEventRow,
          $$HistoryEventsTableFilterComposer,
          $$HistoryEventsTableOrderingComposer,
          $$HistoryEventsTableAnnotationComposer,
          $$HistoryEventsTableCreateCompanionBuilder,
          $$HistoryEventsTableUpdateCompanionBuilder,
          (
            HistoryEventRow,
            BaseReferences<_$AppDatabase, $HistoryEventsTable, HistoryEventRow>,
          ),
          HistoryEventRow,
          PrefetchHooks Function()
        > {
  $$HistoryEventsTableTableManager(_$AppDatabase db, $HistoryEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> upgradeId = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> upgradeName = const Value.absent(),
                Value<String?> villageName = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryEventsCompanion(
                id: id,
                upgradeId: upgradeId,
                villageId: villageId,
                eventType: eventType,
                description: description,
                upgradeName: upgradeName,
                villageName: villageName,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> upgradeId = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                required String eventType,
                required String description,
                Value<String?> upgradeName = const Value.absent(),
                Value<String?> villageName = const Value.absent(),
                required DateTime createdAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => HistoryEventsCompanion.insert(
                id: id,
                upgradeId: upgradeId,
                villageId: villageId,
                eventType: eventType,
                description: description,
                upgradeName: upgradeName,
                villageName: villageName,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HistoryEventsTable, HistoryEventRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HistoryEventsTable,
                    HistoryEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEventsTable,
      HistoryEventRow,
      $$HistoryEventsTableFilterComposer,
      $$HistoryEventsTableOrderingComposer,
      $$HistoryEventsTableAnnotationComposer,
      $$HistoryEventsTableCreateCompanionBuilder,
      $$HistoryEventsTableUpdateCompanionBuilder,
      (
        HistoryEventRow,
        BaseReferences<_$AppDatabase, $HistoryEventsTable, HistoryEventRow>,
      ),
      HistoryEventRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db, _db.villages);
  $$UpgradesTableTableManager get upgrades =>
      $$UpgradesTableTableManager(_db, _db.upgrades);
  $$NotificationPreferencesTableTableManager get notificationPreferences =>
      $$NotificationPreferencesTableTableManager(
        _db,
        _db.notificationPreferences,
      );
  $$HistoryEventsTableTableManager get historyEvents =>
      $$HistoryEventsTableTableManager(_db, _db.historyEvents);
}
