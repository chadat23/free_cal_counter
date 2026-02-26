// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_database.dart';

// ignore_for_file: type=lint
class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesPerGramMeta = const VerificationMeta(
    'caloriesPerGram',
  );
  @override
  late final GeneratedColumn<double> caloriesPerGram = GeneratedColumn<double>(
    'caloriesPerGram',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPerGramMeta = const VerificationMeta(
    'proteinPerGram',
  );
  @override
  late final GeneratedColumn<double> proteinPerGram = GeneratedColumn<double>(
    'proteinPerGram',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPerGramMeta = const VerificationMeta(
    'fatPerGram',
  );
  @override
  late final GeneratedColumn<double> fatPerGram = GeneratedColumn<double>(
    'fatPerGram',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsPerGramMeta = const VerificationMeta(
    'carbsPerGram',
  );
  @override
  late final GeneratedColumn<double> carbsPerGram = GeneratedColumn<double>(
    'carbsPerGram',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberPerGramMeta = const VerificationMeta(
    'fiberPerGram',
  );
  @override
  late final GeneratedColumn<double> fiberPerGram = GeneratedColumn<double>(
    'fiberPerGram',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFdcIdMeta = const VerificationMeta(
    'sourceFdcId',
  );
  @override
  late final GeneratedColumn<int> sourceFdcId = GeneratedColumn<int>(
    'sourceFdcId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceBarcodeMeta = const VerificationMeta(
    'sourceBarcode',
  );
  @override
  late final GeneratedColumn<String> sourceBarcode = GeneratedColumn<String>(
    'sourceBarcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageNoteMeta = const VerificationMeta(
    'usageNote',
  );
  @override
  late final GeneratedColumn<String> usageNote = GeneratedColumn<String>(
    'usageNote',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parentId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    source,
    emoji,
    thumbnail,
    caloriesPerGram,
    proteinPerGram,
    fatPerGram,
    carbsPerGram,
    fiberPerGram,
    sourceFdcId,
    sourceBarcode,
    usageNote,
    hidden,
    parentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Food> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('caloriesPerGram')) {
      context.handle(
        _caloriesPerGramMeta,
        caloriesPerGram.isAcceptableOrUnknown(
          data['caloriesPerGram']!,
          _caloriesPerGramMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesPerGramMeta);
    }
    if (data.containsKey('proteinPerGram')) {
      context.handle(
        _proteinPerGramMeta,
        proteinPerGram.isAcceptableOrUnknown(
          data['proteinPerGram']!,
          _proteinPerGramMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPerGramMeta);
    }
    if (data.containsKey('fatPerGram')) {
      context.handle(
        _fatPerGramMeta,
        fatPerGram.isAcceptableOrUnknown(data['fatPerGram']!, _fatPerGramMeta),
      );
    } else if (isInserting) {
      context.missing(_fatPerGramMeta);
    }
    if (data.containsKey('carbsPerGram')) {
      context.handle(
        _carbsPerGramMeta,
        carbsPerGram.isAcceptableOrUnknown(
          data['carbsPerGram']!,
          _carbsPerGramMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPerGramMeta);
    }
    if (data.containsKey('fiberPerGram')) {
      context.handle(
        _fiberPerGramMeta,
        fiberPerGram.isAcceptableOrUnknown(
          data['fiberPerGram']!,
          _fiberPerGramMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fiberPerGramMeta);
    }
    if (data.containsKey('sourceFdcId')) {
      context.handle(
        _sourceFdcIdMeta,
        sourceFdcId.isAcceptableOrUnknown(
          data['sourceFdcId']!,
          _sourceFdcIdMeta,
        ),
      );
    }
    if (data.containsKey('sourceBarcode')) {
      context.handle(
        _sourceBarcodeMeta,
        sourceBarcode.isAcceptableOrUnknown(
          data['sourceBarcode']!,
          _sourceBarcodeMeta,
        ),
      );
    }
    if (data.containsKey('usageNote')) {
      context.handle(
        _usageNoteMeta,
        usageNote.isAcceptableOrUnknown(data['usageNote']!, _usageNoteMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('parentId')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parentId']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      ),
      caloriesPerGram: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}caloriesPerGram'],
      )!,
      proteinPerGram: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proteinPerGram'],
      )!,
      fatPerGram: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fatPerGram'],
      )!,
      carbsPerGram: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbsPerGram'],
      )!,
      fiberPerGram: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiberPerGram'],
      )!,
      sourceFdcId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sourceFdcId'],
      ),
      sourceBarcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sourceBarcode'],
      ),
      usageNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usageNote'],
      ),
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parentId'],
      ),
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class Food extends DataClass implements Insertable<Food> {
  final int id;
  final String name;
  final String source;
  final String? emoji;
  final String? thumbnail;
  final double caloriesPerGram;
  final double proteinPerGram;
  final double fatPerGram;
  final double carbsPerGram;
  final double fiberPerGram;
  final int? sourceFdcId;
  final String? sourceBarcode;
  final String? usageNote;
  final bool hidden;
  final int? parentId;
  const Food({
    required this.id,
    required this.name,
    required this.source,
    this.emoji,
    this.thumbnail,
    required this.caloriesPerGram,
    required this.proteinPerGram,
    required this.fatPerGram,
    required this.carbsPerGram,
    required this.fiberPerGram,
    this.sourceFdcId,
    this.sourceBarcode,
    this.usageNote,
    required this.hidden,
    this.parentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<String>(thumbnail);
    }
    map['caloriesPerGram'] = Variable<double>(caloriesPerGram);
    map['proteinPerGram'] = Variable<double>(proteinPerGram);
    map['fatPerGram'] = Variable<double>(fatPerGram);
    map['carbsPerGram'] = Variable<double>(carbsPerGram);
    map['fiberPerGram'] = Variable<double>(fiberPerGram);
    if (!nullToAbsent || sourceFdcId != null) {
      map['sourceFdcId'] = Variable<int>(sourceFdcId);
    }
    if (!nullToAbsent || sourceBarcode != null) {
      map['sourceBarcode'] = Variable<String>(sourceBarcode);
    }
    if (!nullToAbsent || usageNote != null) {
      map['usageNote'] = Variable<String>(usageNote);
    }
    map['hidden'] = Variable<bool>(hidden);
    if (!nullToAbsent || parentId != null) {
      map['parentId'] = Variable<int>(parentId);
    }
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      name: Value(name),
      source: Value(source),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      caloriesPerGram: Value(caloriesPerGram),
      proteinPerGram: Value(proteinPerGram),
      fatPerGram: Value(fatPerGram),
      carbsPerGram: Value(carbsPerGram),
      fiberPerGram: Value(fiberPerGram),
      sourceFdcId: sourceFdcId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFdcId),
      sourceBarcode: sourceBarcode == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceBarcode),
      usageNote: usageNote == null && nullToAbsent
          ? const Value.absent()
          : Value(usageNote),
      hidden: Value(hidden),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory Food.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String>(json['source']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      thumbnail: serializer.fromJson<String?>(json['thumbnail']),
      caloriesPerGram: serializer.fromJson<double>(json['caloriesPerGram']),
      proteinPerGram: serializer.fromJson<double>(json['proteinPerGram']),
      fatPerGram: serializer.fromJson<double>(json['fatPerGram']),
      carbsPerGram: serializer.fromJson<double>(json['carbsPerGram']),
      fiberPerGram: serializer.fromJson<double>(json['fiberPerGram']),
      sourceFdcId: serializer.fromJson<int?>(json['sourceFdcId']),
      sourceBarcode: serializer.fromJson<String?>(json['sourceBarcode']),
      usageNote: serializer.fromJson<String?>(json['usageNote']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      parentId: serializer.fromJson<int?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String>(source),
      'emoji': serializer.toJson<String?>(emoji),
      'thumbnail': serializer.toJson<String?>(thumbnail),
      'caloriesPerGram': serializer.toJson<double>(caloriesPerGram),
      'proteinPerGram': serializer.toJson<double>(proteinPerGram),
      'fatPerGram': serializer.toJson<double>(fatPerGram),
      'carbsPerGram': serializer.toJson<double>(carbsPerGram),
      'fiberPerGram': serializer.toJson<double>(fiberPerGram),
      'sourceFdcId': serializer.toJson<int?>(sourceFdcId),
      'sourceBarcode': serializer.toJson<String?>(sourceBarcode),
      'usageNote': serializer.toJson<String?>(usageNote),
      'hidden': serializer.toJson<bool>(hidden),
      'parentId': serializer.toJson<int?>(parentId),
    };
  }

  Food copyWith({
    int? id,
    String? name,
    String? source,
    Value<String?> emoji = const Value.absent(),
    Value<String?> thumbnail = const Value.absent(),
    double? caloriesPerGram,
    double? proteinPerGram,
    double? fatPerGram,
    double? carbsPerGram,
    double? fiberPerGram,
    Value<int?> sourceFdcId = const Value.absent(),
    Value<String?> sourceBarcode = const Value.absent(),
    Value<String?> usageNote = const Value.absent(),
    bool? hidden,
    Value<int?> parentId = const Value.absent(),
  }) => Food(
    id: id ?? this.id,
    name: name ?? this.name,
    source: source ?? this.source,
    emoji: emoji.present ? emoji.value : this.emoji,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
    caloriesPerGram: caloriesPerGram ?? this.caloriesPerGram,
    proteinPerGram: proteinPerGram ?? this.proteinPerGram,
    fatPerGram: fatPerGram ?? this.fatPerGram,
    carbsPerGram: carbsPerGram ?? this.carbsPerGram,
    fiberPerGram: fiberPerGram ?? this.fiberPerGram,
    sourceFdcId: sourceFdcId.present ? sourceFdcId.value : this.sourceFdcId,
    sourceBarcode: sourceBarcode.present
        ? sourceBarcode.value
        : this.sourceBarcode,
    usageNote: usageNote.present ? usageNote.value : this.usageNote,
    hidden: hidden ?? this.hidden,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      caloriesPerGram: data.caloriesPerGram.present
          ? data.caloriesPerGram.value
          : this.caloriesPerGram,
      proteinPerGram: data.proteinPerGram.present
          ? data.proteinPerGram.value
          : this.proteinPerGram,
      fatPerGram: data.fatPerGram.present
          ? data.fatPerGram.value
          : this.fatPerGram,
      carbsPerGram: data.carbsPerGram.present
          ? data.carbsPerGram.value
          : this.carbsPerGram,
      fiberPerGram: data.fiberPerGram.present
          ? data.fiberPerGram.value
          : this.fiberPerGram,
      sourceFdcId: data.sourceFdcId.present
          ? data.sourceFdcId.value
          : this.sourceFdcId,
      sourceBarcode: data.sourceBarcode.present
          ? data.sourceBarcode.value
          : this.sourceBarcode,
      usageNote: data.usageNote.present ? data.usageNote.value : this.usageNote,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('emoji: $emoji, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('caloriesPerGram: $caloriesPerGram, ')
          ..write('proteinPerGram: $proteinPerGram, ')
          ..write('fatPerGram: $fatPerGram, ')
          ..write('carbsPerGram: $carbsPerGram, ')
          ..write('fiberPerGram: $fiberPerGram, ')
          ..write('sourceFdcId: $sourceFdcId, ')
          ..write('sourceBarcode: $sourceBarcode, ')
          ..write('usageNote: $usageNote, ')
          ..write('hidden: $hidden, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    source,
    emoji,
    thumbnail,
    caloriesPerGram,
    proteinPerGram,
    fatPerGram,
    carbsPerGram,
    fiberPerGram,
    sourceFdcId,
    sourceBarcode,
    usageNote,
    hidden,
    parentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.name == this.name &&
          other.source == this.source &&
          other.emoji == this.emoji &&
          other.thumbnail == this.thumbnail &&
          other.caloriesPerGram == this.caloriesPerGram &&
          other.proteinPerGram == this.proteinPerGram &&
          other.fatPerGram == this.fatPerGram &&
          other.carbsPerGram == this.carbsPerGram &&
          other.fiberPerGram == this.fiberPerGram &&
          other.sourceFdcId == this.sourceFdcId &&
          other.sourceBarcode == this.sourceBarcode &&
          other.usageNote == this.usageNote &&
          other.hidden == this.hidden &&
          other.parentId == this.parentId);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> source;
  final Value<String?> emoji;
  final Value<String?> thumbnail;
  final Value<double> caloriesPerGram;
  final Value<double> proteinPerGram;
  final Value<double> fatPerGram;
  final Value<double> carbsPerGram;
  final Value<double> fiberPerGram;
  final Value<int?> sourceFdcId;
  final Value<String?> sourceBarcode;
  final Value<String?> usageNote;
  final Value<bool> hidden;
  final Value<int?> parentId;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.emoji = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.caloriesPerGram = const Value.absent(),
    this.proteinPerGram = const Value.absent(),
    this.fatPerGram = const Value.absent(),
    this.carbsPerGram = const Value.absent(),
    this.fiberPerGram = const Value.absent(),
    this.sourceFdcId = const Value.absent(),
    this.sourceBarcode = const Value.absent(),
    this.usageNote = const Value.absent(),
    this.hidden = const Value.absent(),
    this.parentId = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String source,
    this.emoji = const Value.absent(),
    this.thumbnail = const Value.absent(),
    required double caloriesPerGram,
    required double proteinPerGram,
    required double fatPerGram,
    required double carbsPerGram,
    required double fiberPerGram,
    this.sourceFdcId = const Value.absent(),
    this.sourceBarcode = const Value.absent(),
    this.usageNote = const Value.absent(),
    this.hidden = const Value.absent(),
    this.parentId = const Value.absent(),
  }) : name = Value(name),
       source = Value(source),
       caloriesPerGram = Value(caloriesPerGram),
       proteinPerGram = Value(proteinPerGram),
       fatPerGram = Value(fatPerGram),
       carbsPerGram = Value(carbsPerGram),
       fiberPerGram = Value(fiberPerGram);
  static Insertable<Food> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? source,
    Expression<String>? emoji,
    Expression<String>? thumbnail,
    Expression<double>? caloriesPerGram,
    Expression<double>? proteinPerGram,
    Expression<double>? fatPerGram,
    Expression<double>? carbsPerGram,
    Expression<double>? fiberPerGram,
    Expression<int>? sourceFdcId,
    Expression<String>? sourceBarcode,
    Expression<String>? usageNote,
    Expression<bool>? hidden,
    Expression<int>? parentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (emoji != null) 'emoji': emoji,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (caloriesPerGram != null) 'caloriesPerGram': caloriesPerGram,
      if (proteinPerGram != null) 'proteinPerGram': proteinPerGram,
      if (fatPerGram != null) 'fatPerGram': fatPerGram,
      if (carbsPerGram != null) 'carbsPerGram': carbsPerGram,
      if (fiberPerGram != null) 'fiberPerGram': fiberPerGram,
      if (sourceFdcId != null) 'sourceFdcId': sourceFdcId,
      if (sourceBarcode != null) 'sourceBarcode': sourceBarcode,
      if (usageNote != null) 'usageNote': usageNote,
      if (hidden != null) 'hidden': hidden,
      if (parentId != null) 'parentId': parentId,
    });
  }

  FoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? source,
    Value<String?>? emoji,
    Value<String?>? thumbnail,
    Value<double>? caloriesPerGram,
    Value<double>? proteinPerGram,
    Value<double>? fatPerGram,
    Value<double>? carbsPerGram,
    Value<double>? fiberPerGram,
    Value<int?>? sourceFdcId,
    Value<String?>? sourceBarcode,
    Value<String?>? usageNote,
    Value<bool>? hidden,
    Value<int?>? parentId,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      emoji: emoji ?? this.emoji,
      thumbnail: thumbnail ?? this.thumbnail,
      caloriesPerGram: caloriesPerGram ?? this.caloriesPerGram,
      proteinPerGram: proteinPerGram ?? this.proteinPerGram,
      fatPerGram: fatPerGram ?? this.fatPerGram,
      carbsPerGram: carbsPerGram ?? this.carbsPerGram,
      fiberPerGram: fiberPerGram ?? this.fiberPerGram,
      sourceFdcId: sourceFdcId ?? this.sourceFdcId,
      sourceBarcode: sourceBarcode ?? this.sourceBarcode,
      usageNote: usageNote ?? this.usageNote,
      hidden: hidden ?? this.hidden,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (caloriesPerGram.present) {
      map['caloriesPerGram'] = Variable<double>(caloriesPerGram.value);
    }
    if (proteinPerGram.present) {
      map['proteinPerGram'] = Variable<double>(proteinPerGram.value);
    }
    if (fatPerGram.present) {
      map['fatPerGram'] = Variable<double>(fatPerGram.value);
    }
    if (carbsPerGram.present) {
      map['carbsPerGram'] = Variable<double>(carbsPerGram.value);
    }
    if (fiberPerGram.present) {
      map['fiberPerGram'] = Variable<double>(fiberPerGram.value);
    }
    if (sourceFdcId.present) {
      map['sourceFdcId'] = Variable<int>(sourceFdcId.value);
    }
    if (sourceBarcode.present) {
      map['sourceBarcode'] = Variable<String>(sourceBarcode.value);
    }
    if (usageNote.present) {
      map['usageNote'] = Variable<String>(usageNote.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (parentId.present) {
      map['parentId'] = Variable<int>(parentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('emoji: $emoji, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('caloriesPerGram: $caloriesPerGram, ')
          ..write('proteinPerGram: $proteinPerGram, ')
          ..write('fatPerGram: $fatPerGram, ')
          ..write('carbsPerGram: $carbsPerGram, ')
          ..write('fiberPerGram: $fiberPerGram, ')
          ..write('sourceFdcId: $sourceFdcId, ')
          ..write('sourceBarcode: $sourceBarcode, ')
          ..write('usageNote: $usageNote, ')
          ..write('hidden: $hidden, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }
}

class $FoodPortionsTable extends FoodPortions
    with TableInfo<$FoodPortionsTable, FoodPortion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodPortionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'foodId',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unitName',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'gramsPerPortion',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantityPerPortion',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, foodId, unit, grams, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_portions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodPortion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('foodId')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['foodId']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('unitName')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unitName']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('gramsPerPortion')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['gramsPerPortion']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('quantityPerPortion')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(
          data['quantityPerPortion']!,
          _quantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodPortion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodPortion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}foodId'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unitName'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gramsPerPortion'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantityPerPortion'],
      )!,
    );
  }

  @override
  $FoodPortionsTable createAlias(String alias) {
    return $FoodPortionsTable(attachedDatabase, alias);
  }
}

class FoodPortion extends DataClass implements Insertable<FoodPortion> {
  final int id;
  final int foodId;
  final String unit;
  final double grams;
  final double quantity;
  const FoodPortion({
    required this.id,
    required this.foodId,
    required this.unit,
    required this.grams,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['foodId'] = Variable<int>(foodId);
    map['unitName'] = Variable<String>(unit);
    map['gramsPerPortion'] = Variable<double>(grams);
    map['quantityPerPortion'] = Variable<double>(quantity);
    return map;
  }

  FoodPortionsCompanion toCompanion(bool nullToAbsent) {
    return FoodPortionsCompanion(
      id: Value(id),
      foodId: Value(foodId),
      unit: Value(unit),
      grams: Value(grams),
      quantity: Value(quantity),
    );
  }

  factory FoodPortion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodPortion(
      id: serializer.fromJson<int>(json['id']),
      foodId: serializer.fromJson<int>(json['foodId']),
      unit: serializer.fromJson<String>(json['unit']),
      grams: serializer.fromJson<double>(json['grams']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'foodId': serializer.toJson<int>(foodId),
      'unit': serializer.toJson<String>(unit),
      'grams': serializer.toJson<double>(grams),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  FoodPortion copyWith({
    int? id,
    int? foodId,
    String? unit,
    double? grams,
    double? quantity,
  }) => FoodPortion(
    id: id ?? this.id,
    foodId: foodId ?? this.foodId,
    unit: unit ?? this.unit,
    grams: grams ?? this.grams,
    quantity: quantity ?? this.quantity,
  );
  FoodPortion copyWithCompanion(FoodPortionsCompanion data) {
    return FoodPortion(
      id: data.id.present ? data.id.value : this.id,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      unit: data.unit.present ? data.unit.value : this.unit,
      grams: data.grams.present ? data.grams.value : this.grams,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodPortion(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('unit: $unit, ')
          ..write('grams: $grams, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, foodId, unit, grams, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodPortion &&
          other.id == this.id &&
          other.foodId == this.foodId &&
          other.unit == this.unit &&
          other.grams == this.grams &&
          other.quantity == this.quantity);
}

class FoodPortionsCompanion extends UpdateCompanion<FoodPortion> {
  final Value<int> id;
  final Value<int> foodId;
  final Value<String> unit;
  final Value<double> grams;
  final Value<double> quantity;
  const FoodPortionsCompanion({
    this.id = const Value.absent(),
    this.foodId = const Value.absent(),
    this.unit = const Value.absent(),
    this.grams = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  FoodPortionsCompanion.insert({
    this.id = const Value.absent(),
    required int foodId,
    required String unit,
    required double grams,
    required double quantity,
  }) : foodId = Value(foodId),
       unit = Value(unit),
       grams = Value(grams),
       quantity = Value(quantity);
  static Insertable<FoodPortion> custom({
    Expression<int>? id,
    Expression<int>? foodId,
    Expression<String>? unit,
    Expression<double>? grams,
    Expression<double>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodId != null) 'foodId': foodId,
      if (unit != null) 'unitName': unit,
      if (grams != null) 'gramsPerPortion': grams,
      if (quantity != null) 'quantityPerPortion': quantity,
    });
  }

  FoodPortionsCompanion copyWith({
    Value<int>? id,
    Value<int>? foodId,
    Value<String>? unit,
    Value<double>? grams,
    Value<double>? quantity,
  }) {
    return FoodPortionsCompanion(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      unit: unit ?? this.unit,
      grams: grams ?? this.grams,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (foodId.present) {
      map['foodId'] = Variable<int>(foodId.value);
    }
    if (unit.present) {
      map['unitName'] = Variable<String>(unit.value);
    }
    if (grams.present) {
      map['gramsPerPortion'] = Variable<double>(grams.value);
    }
    if (quantity.present) {
      map['quantityPerPortion'] = Variable<double>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodPortionsCompanion(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('unit: $unit, ')
          ..write('grams: $grams, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingsCreatedMeta = const VerificationMeta(
    'servingsCreated',
  );
  @override
  late final GeneratedColumn<double> servingsCreated = GeneratedColumn<double>(
    'servings_created',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _finalWeightGramsMeta = const VerificationMeta(
    'finalWeightGrams',
  );
  @override
  late final GeneratedColumn<double> finalWeightGrams = GeneratedColumn<double>(
    'final_weight_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portionNameMeta = const VerificationMeta(
    'portionName',
  );
  @override
  late final GeneratedColumn<String> portionName = GeneratedColumn<String>(
    'portion_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('portion'),
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
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTemplateMeta = const VerificationMeta(
    'isTemplate',
  );
  @override
  late final GeneratedColumn<bool> isTemplate = GeneratedColumn<bool>(
    'is_template',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_template" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _createdTimestampMeta = const VerificationMeta(
    'createdTimestamp',
  );
  @override
  late final GeneratedColumn<int> createdTimestamp = GeneratedColumn<int>(
    'created_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    thumbnail,
    servingsCreated,
    finalWeightGrams,
    portionName,
    notes,
    link,
    isTemplate,
    hidden,
    parentId,
    createdTimestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('servings_created')) {
      context.handle(
        _servingsCreatedMeta,
        servingsCreated.isAcceptableOrUnknown(
          data['servings_created']!,
          _servingsCreatedMeta,
        ),
      );
    }
    if (data.containsKey('final_weight_grams')) {
      context.handle(
        _finalWeightGramsMeta,
        finalWeightGrams.isAcceptableOrUnknown(
          data['final_weight_grams']!,
          _finalWeightGramsMeta,
        ),
      );
    }
    if (data.containsKey('portion_name')) {
      context.handle(
        _portionNameMeta,
        portionName.isAcceptableOrUnknown(
          data['portion_name']!,
          _portionNameMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('is_template')) {
      context.handle(
        _isTemplateMeta,
        isTemplate.isAcceptableOrUnknown(data['is_template']!, _isTemplateMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('created_timestamp')) {
      context.handle(
        _createdTimestampMeta,
        createdTimestamp.isAcceptableOrUnknown(
          data['created_timestamp']!,
          _createdTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdTimestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      ),
      servingsCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}servings_created'],
      )!,
      finalWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}final_weight_grams'],
      ),
      portionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portion_name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      isTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_template'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      createdTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_timestamp'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final int id;
  final String name;
  final String? emoji;
  final String? thumbnail;
  final double servingsCreated;
  final double? finalWeightGrams;
  final String portionName;
  final String? notes;
  final String? link;
  final bool isTemplate;
  final bool hidden;
  final int? parentId;
  final int createdTimestamp;
  const Recipe({
    required this.id,
    required this.name,
    this.emoji,
    this.thumbnail,
    required this.servingsCreated,
    this.finalWeightGrams,
    required this.portionName,
    this.notes,
    this.link,
    required this.isTemplate,
    required this.hidden,
    this.parentId,
    required this.createdTimestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<String>(thumbnail);
    }
    map['servings_created'] = Variable<double>(servingsCreated);
    if (!nullToAbsent || finalWeightGrams != null) {
      map['final_weight_grams'] = Variable<double>(finalWeightGrams);
    }
    map['portion_name'] = Variable<String>(portionName);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    map['is_template'] = Variable<bool>(isTemplate);
    map['hidden'] = Variable<bool>(hidden);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['created_timestamp'] = Variable<int>(createdTimestamp);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      name: Value(name),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      servingsCreated: Value(servingsCreated),
      finalWeightGrams: finalWeightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(finalWeightGrams),
      portionName: Value(portionName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      isTemplate: Value(isTemplate),
      hidden: Value(hidden),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdTimestamp: Value(createdTimestamp),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      thumbnail: serializer.fromJson<String?>(json['thumbnail']),
      servingsCreated: serializer.fromJson<double>(json['servingsCreated']),
      finalWeightGrams: serializer.fromJson<double?>(json['finalWeightGrams']),
      portionName: serializer.fromJson<String>(json['portionName']),
      notes: serializer.fromJson<String?>(json['notes']),
      link: serializer.fromJson<String?>(json['link']),
      isTemplate: serializer.fromJson<bool>(json['isTemplate']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      createdTimestamp: serializer.fromJson<int>(json['createdTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String?>(emoji),
      'thumbnail': serializer.toJson<String?>(thumbnail),
      'servingsCreated': serializer.toJson<double>(servingsCreated),
      'finalWeightGrams': serializer.toJson<double?>(finalWeightGrams),
      'portionName': serializer.toJson<String>(portionName),
      'notes': serializer.toJson<String?>(notes),
      'link': serializer.toJson<String?>(link),
      'isTemplate': serializer.toJson<bool>(isTemplate),
      'hidden': serializer.toJson<bool>(hidden),
      'parentId': serializer.toJson<int?>(parentId),
      'createdTimestamp': serializer.toJson<int>(createdTimestamp),
    };
  }

  Recipe copyWith({
    int? id,
    String? name,
    Value<String?> emoji = const Value.absent(),
    Value<String?> thumbnail = const Value.absent(),
    double? servingsCreated,
    Value<double?> finalWeightGrams = const Value.absent(),
    String? portionName,
    Value<String?> notes = const Value.absent(),
    Value<String?> link = const Value.absent(),
    bool? isTemplate,
    bool? hidden,
    Value<int?> parentId = const Value.absent(),
    int? createdTimestamp,
  }) => Recipe(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji.present ? emoji.value : this.emoji,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
    servingsCreated: servingsCreated ?? this.servingsCreated,
    finalWeightGrams: finalWeightGrams.present
        ? finalWeightGrams.value
        : this.finalWeightGrams,
    portionName: portionName ?? this.portionName,
    notes: notes.present ? notes.value : this.notes,
    link: link.present ? link.value : this.link,
    isTemplate: isTemplate ?? this.isTemplate,
    hidden: hidden ?? this.hidden,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdTimestamp: createdTimestamp ?? this.createdTimestamp,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      servingsCreated: data.servingsCreated.present
          ? data.servingsCreated.value
          : this.servingsCreated,
      finalWeightGrams: data.finalWeightGrams.present
          ? data.finalWeightGrams.value
          : this.finalWeightGrams,
      portionName: data.portionName.present
          ? data.portionName.value
          : this.portionName,
      notes: data.notes.present ? data.notes.value : this.notes,
      link: data.link.present ? data.link.value : this.link,
      isTemplate: data.isTemplate.present
          ? data.isTemplate.value
          : this.isTemplate,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdTimestamp: data.createdTimestamp.present
          ? data.createdTimestamp.value
          : this.createdTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('servingsCreated: $servingsCreated, ')
          ..write('finalWeightGrams: $finalWeightGrams, ')
          ..write('portionName: $portionName, ')
          ..write('notes: $notes, ')
          ..write('link: $link, ')
          ..write('isTemplate: $isTemplate, ')
          ..write('hidden: $hidden, ')
          ..write('parentId: $parentId, ')
          ..write('createdTimestamp: $createdTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    thumbnail,
    servingsCreated,
    finalWeightGrams,
    portionName,
    notes,
    link,
    isTemplate,
    hidden,
    parentId,
    createdTimestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.thumbnail == this.thumbnail &&
          other.servingsCreated == this.servingsCreated &&
          other.finalWeightGrams == this.finalWeightGrams &&
          other.portionName == this.portionName &&
          other.notes == this.notes &&
          other.link == this.link &&
          other.isTemplate == this.isTemplate &&
          other.hidden == this.hidden &&
          other.parentId == this.parentId &&
          other.createdTimestamp == this.createdTimestamp);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> emoji;
  final Value<String?> thumbnail;
  final Value<double> servingsCreated;
  final Value<double?> finalWeightGrams;
  final Value<String> portionName;
  final Value<String?> notes;
  final Value<String?> link;
  final Value<bool> isTemplate;
  final Value<bool> hidden;
  final Value<int?> parentId;
  final Value<int> createdTimestamp;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.servingsCreated = const Value.absent(),
    this.finalWeightGrams = const Value.absent(),
    this.portionName = const Value.absent(),
    this.notes = const Value.absent(),
    this.link = const Value.absent(),
    this.isTemplate = const Value.absent(),
    this.hidden = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdTimestamp = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.servingsCreated = const Value.absent(),
    this.finalWeightGrams = const Value.absent(),
    this.portionName = const Value.absent(),
    this.notes = const Value.absent(),
    this.link = const Value.absent(),
    this.isTemplate = const Value.absent(),
    this.hidden = const Value.absent(),
    this.parentId = const Value.absent(),
    required int createdTimestamp,
  }) : name = Value(name),
       createdTimestamp = Value(createdTimestamp);
  static Insertable<Recipe> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? thumbnail,
    Expression<double>? servingsCreated,
    Expression<double>? finalWeightGrams,
    Expression<String>? portionName,
    Expression<String>? notes,
    Expression<String>? link,
    Expression<bool>? isTemplate,
    Expression<bool>? hidden,
    Expression<int>? parentId,
    Expression<int>? createdTimestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (servingsCreated != null) 'servings_created': servingsCreated,
      if (finalWeightGrams != null) 'final_weight_grams': finalWeightGrams,
      if (portionName != null) 'portion_name': portionName,
      if (notes != null) 'notes': notes,
      if (link != null) 'link': link,
      if (isTemplate != null) 'is_template': isTemplate,
      if (hidden != null) 'hidden': hidden,
      if (parentId != null) 'parent_id': parentId,
      if (createdTimestamp != null) 'created_timestamp': createdTimestamp,
    });
  }

  RecipesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? emoji,
    Value<String?>? thumbnail,
    Value<double>? servingsCreated,
    Value<double?>? finalWeightGrams,
    Value<String>? portionName,
    Value<String?>? notes,
    Value<String?>? link,
    Value<bool>? isTemplate,
    Value<bool>? hidden,
    Value<int?>? parentId,
    Value<int>? createdTimestamp,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      thumbnail: thumbnail ?? this.thumbnail,
      servingsCreated: servingsCreated ?? this.servingsCreated,
      finalWeightGrams: finalWeightGrams ?? this.finalWeightGrams,
      portionName: portionName ?? this.portionName,
      notes: notes ?? this.notes,
      link: link ?? this.link,
      isTemplate: isTemplate ?? this.isTemplate,
      hidden: hidden ?? this.hidden,
      parentId: parentId ?? this.parentId,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (servingsCreated.present) {
      map['servings_created'] = Variable<double>(servingsCreated.value);
    }
    if (finalWeightGrams.present) {
      map['final_weight_grams'] = Variable<double>(finalWeightGrams.value);
    }
    if (portionName.present) {
      map['portion_name'] = Variable<String>(portionName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (isTemplate.present) {
      map['is_template'] = Variable<bool>(isTemplate.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (createdTimestamp.present) {
      map['created_timestamp'] = Variable<int>(createdTimestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('servingsCreated: $servingsCreated, ')
          ..write('finalWeightGrams: $finalWeightGrams, ')
          ..write('portionName: $portionName, ')
          ..write('notes: $notes, ')
          ..write('link: $link, ')
          ..write('isTemplate: $isTemplate, ')
          ..write('hidden: $hidden, ')
          ..write('parentId: $parentId, ')
          ..write('createdTimestamp: $createdTimestamp')
          ..write(')'))
        .toString();
  }
}

class $RecipeItemsTable extends RecipeItems
    with TableInfo<$RecipeItemsTable, RecipeItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _ingredientFoodIdMeta = const VerificationMeta(
    'ingredientFoodId',
  );
  @override
  late final GeneratedColumn<int> ingredientFoodId = GeneratedColumn<int>(
    'ingredient_food_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  static const VerificationMeta _ingredientRecipeIdMeta =
      const VerificationMeta('ingredientRecipeId');
  @override
  late final GeneratedColumn<int> ingredientRecipeId = GeneratedColumn<int>(
    'ingredient_recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    ingredientFoodId,
    ingredientRecipeId,
    grams,
    unit,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('ingredient_food_id')) {
      context.handle(
        _ingredientFoodIdMeta,
        ingredientFoodId.isAcceptableOrUnknown(
          data['ingredient_food_id']!,
          _ingredientFoodIdMeta,
        ),
      );
    }
    if (data.containsKey('ingredient_recipe_id')) {
      context.handle(
        _ingredientRecipeIdMeta,
        ingredientRecipeId.isAcceptableOrUnknown(
          data['ingredient_recipe_id']!,
          _ingredientRecipeIdMeta,
        ),
      );
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      )!,
      ingredientFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_food_id'],
      ),
      ingredientRecipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_recipe_id'],
      ),
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RecipeItemsTable createAlias(String alias) {
    return $RecipeItemsTable(attachedDatabase, alias);
  }
}

class RecipeItem extends DataClass implements Insertable<RecipeItem> {
  final int id;
  final int recipeId;
  final int? ingredientFoodId;
  final int? ingredientRecipeId;
  final double grams;
  final String unit;
  final int position;
  const RecipeItem({
    required this.id,
    required this.recipeId,
    this.ingredientFoodId,
    this.ingredientRecipeId,
    required this.grams,
    required this.unit,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    if (!nullToAbsent || ingredientFoodId != null) {
      map['ingredient_food_id'] = Variable<int>(ingredientFoodId);
    }
    if (!nullToAbsent || ingredientRecipeId != null) {
      map['ingredient_recipe_id'] = Variable<int>(ingredientRecipeId);
    }
    map['grams'] = Variable<double>(grams);
    map['unit'] = Variable<String>(unit);
    map['position'] = Variable<int>(position);
    return map;
  }

  RecipeItemsCompanion toCompanion(bool nullToAbsent) {
    return RecipeItemsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      ingredientFoodId: ingredientFoodId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientFoodId),
      ingredientRecipeId: ingredientRecipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientRecipeId),
      grams: Value(grams),
      unit: Value(unit),
      position: Value(position),
    );
  }

  factory RecipeItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeItem(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      ingredientFoodId: serializer.fromJson<int?>(json['ingredientFoodId']),
      ingredientRecipeId: serializer.fromJson<int?>(json['ingredientRecipeId']),
      grams: serializer.fromJson<double>(json['grams']),
      unit: serializer.fromJson<String>(json['unit']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'ingredientFoodId': serializer.toJson<int?>(ingredientFoodId),
      'ingredientRecipeId': serializer.toJson<int?>(ingredientRecipeId),
      'grams': serializer.toJson<double>(grams),
      'unit': serializer.toJson<String>(unit),
      'position': serializer.toJson<int>(position),
    };
  }

  RecipeItem copyWith({
    int? id,
    int? recipeId,
    Value<int?> ingredientFoodId = const Value.absent(),
    Value<int?> ingredientRecipeId = const Value.absent(),
    double? grams,
    String? unit,
    int? position,
  }) => RecipeItem(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    ingredientFoodId: ingredientFoodId.present
        ? ingredientFoodId.value
        : this.ingredientFoodId,
    ingredientRecipeId: ingredientRecipeId.present
        ? ingredientRecipeId.value
        : this.ingredientRecipeId,
    grams: grams ?? this.grams,
    unit: unit ?? this.unit,
    position: position ?? this.position,
  );
  RecipeItem copyWithCompanion(RecipeItemsCompanion data) {
    return RecipeItem(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      ingredientFoodId: data.ingredientFoodId.present
          ? data.ingredientFoodId.value
          : this.ingredientFoodId,
      ingredientRecipeId: data.ingredientRecipeId.present
          ? data.ingredientRecipeId.value
          : this.ingredientRecipeId,
      grams: data.grams.present ? data.grams.value : this.grams,
      unit: data.unit.present ? data.unit.value : this.unit,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeItem(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('ingredientFoodId: $ingredientFoodId, ')
          ..write('ingredientRecipeId: $ingredientRecipeId, ')
          ..write('grams: $grams, ')
          ..write('unit: $unit, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    ingredientFoodId,
    ingredientRecipeId,
    grams,
    unit,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeItem &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.ingredientFoodId == this.ingredientFoodId &&
          other.ingredientRecipeId == this.ingredientRecipeId &&
          other.grams == this.grams &&
          other.unit == this.unit &&
          other.position == this.position);
}

class RecipeItemsCompanion extends UpdateCompanion<RecipeItem> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<int?> ingredientFoodId;
  final Value<int?> ingredientRecipeId;
  final Value<double> grams;
  final Value<String> unit;
  final Value<int> position;
  const RecipeItemsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.ingredientFoodId = const Value.absent(),
    this.ingredientRecipeId = const Value.absent(),
    this.grams = const Value.absent(),
    this.unit = const Value.absent(),
    this.position = const Value.absent(),
  });
  RecipeItemsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    this.ingredientFoodId = const Value.absent(),
    this.ingredientRecipeId = const Value.absent(),
    required double grams,
    required String unit,
    this.position = const Value.absent(),
  }) : recipeId = Value(recipeId),
       grams = Value(grams),
       unit = Value(unit);
  static Insertable<RecipeItem> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<int>? ingredientFoodId,
    Expression<int>? ingredientRecipeId,
    Expression<double>? grams,
    Expression<String>? unit,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (ingredientFoodId != null) 'ingredient_food_id': ingredientFoodId,
      if (ingredientRecipeId != null)
        'ingredient_recipe_id': ingredientRecipeId,
      if (grams != null) 'grams': grams,
      if (unit != null) 'unit': unit,
      if (position != null) 'position': position,
    });
  }

  RecipeItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? recipeId,
    Value<int?>? ingredientFoodId,
    Value<int?>? ingredientRecipeId,
    Value<double>? grams,
    Value<String>? unit,
    Value<int>? position,
  }) {
    return RecipeItemsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      ingredientFoodId: ingredientFoodId ?? this.ingredientFoodId,
      ingredientRecipeId: ingredientRecipeId ?? this.ingredientRecipeId,
      grams: grams ?? this.grams,
      unit: unit ?? this.unit,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (ingredientFoodId.present) {
      map['ingredient_food_id'] = Variable<int>(ingredientFoodId.value);
    }
    if (ingredientRecipeId.present) {
      map['ingredient_recipe_id'] = Variable<int>(ingredientRecipeId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeItemsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('ingredientFoodId: $ingredientFoodId, ')
          ..write('ingredientRecipeId: $ingredientRecipeId, ')
          ..write('grams: $grams, ')
          ..write('unit: $unit, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE',
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  const Category({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(id: Value(id), name: Value(name));
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Category copyWith({int? id, String? name}) =>
      Category(id: id ?? this.id, name: name ?? this.name);
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category && other.id == this.id && other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CategoriesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CategoriesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $RecipeCategoryLinksTable extends RecipeCategoryLinks
    with TableInfo<$RecipeCategoryLinksTable, RecipeCategoryLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeCategoryLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [recipeId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_category_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeCategoryLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recipeId, categoryId},
  ];
  @override
  RecipeCategoryLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeCategoryLink(
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $RecipeCategoryLinksTable createAlias(String alias) {
    return $RecipeCategoryLinksTable(attachedDatabase, alias);
  }
}

class RecipeCategoryLink extends DataClass
    implements Insertable<RecipeCategoryLink> {
  final int recipeId;
  final int categoryId;
  const RecipeCategoryLink({required this.recipeId, required this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recipe_id'] = Variable<int>(recipeId);
    map['category_id'] = Variable<int>(categoryId);
    return map;
  }

  RecipeCategoryLinksCompanion toCompanion(bool nullToAbsent) {
    return RecipeCategoryLinksCompanion(
      recipeId: Value(recipeId),
      categoryId: Value(categoryId),
    );
  }

  factory RecipeCategoryLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeCategoryLink(
      recipeId: serializer.fromJson<int>(json['recipeId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipeId': serializer.toJson<int>(recipeId),
      'categoryId': serializer.toJson<int>(categoryId),
    };
  }

  RecipeCategoryLink copyWith({int? recipeId, int? categoryId}) =>
      RecipeCategoryLink(
        recipeId: recipeId ?? this.recipeId,
        categoryId: categoryId ?? this.categoryId,
      );
  RecipeCategoryLink copyWithCompanion(RecipeCategoryLinksCompanion data) {
    return RecipeCategoryLink(
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeCategoryLink(')
          ..write('recipeId: $recipeId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(recipeId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeCategoryLink &&
          other.recipeId == this.recipeId &&
          other.categoryId == this.categoryId);
}

class RecipeCategoryLinksCompanion extends UpdateCompanion<RecipeCategoryLink> {
  final Value<int> recipeId;
  final Value<int> categoryId;
  final Value<int> rowid;
  const RecipeCategoryLinksCompanion({
    this.recipeId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeCategoryLinksCompanion.insert({
    required int recipeId,
    required int categoryId,
    this.rowid = const Value.absent(),
  }) : recipeId = Value(recipeId),
       categoryId = Value(categoryId);
  static Insertable<RecipeCategoryLink> custom({
    Expression<int>? recipeId,
    Expression<int>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recipeId != null) 'recipe_id': recipeId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeCategoryLinksCompanion copyWith({
    Value<int>? recipeId,
    Value<int>? categoryId,
    Value<int>? rowid,
  }) {
    return RecipeCategoryLinksCompanion(
      recipeId: recipeId ?? this.recipeId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeCategoryLinksCompanion(')
          ..write('recipeId: $recipeId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoggedPortionsTable extends LoggedPortions
    with TableInfo<$LoggedPortionsTable, LoggedPortion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoggedPortionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'loggedFoodId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipeId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _logTimestampMeta = const VerificationMeta(
    'logTimestamp',
  );
  @override
  late final GeneratedColumn<int> logTimestamp = GeneratedColumn<int>(
    'log_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    foodId,
    recipeId,
    logTimestamp,
    grams,
    unit,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logged_portions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoggedPortion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('loggedFoodId')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['loggedFoodId']!, _foodIdMeta),
      );
    }
    if (data.containsKey('recipeId')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipeId']!, _recipeIdMeta),
      );
    }
    if (data.containsKey('log_timestamp')) {
      context.handle(
        _logTimestampMeta,
        logTimestamp.isAcceptableOrUnknown(
          data['log_timestamp']!,
          _logTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_logTimestampMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoggedPortion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoggedPortion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loggedFoodId'],
      ),
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipeId'],
      ),
      logTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}log_timestamp'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $LoggedPortionsTable createAlias(String alias) {
    return $LoggedPortionsTable(attachedDatabase, alias);
  }
}

class LoggedPortion extends DataClass implements Insertable<LoggedPortion> {
  final int id;
  final int? foodId;
  final int? recipeId;
  final int logTimestamp;
  final double grams;
  final String unit;
  final double quantity;
  const LoggedPortion({
    required this.id,
    this.foodId,
    this.recipeId,
    required this.logTimestamp,
    required this.grams,
    required this.unit,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || foodId != null) {
      map['loggedFoodId'] = Variable<int>(foodId);
    }
    if (!nullToAbsent || recipeId != null) {
      map['recipeId'] = Variable<int>(recipeId);
    }
    map['log_timestamp'] = Variable<int>(logTimestamp);
    map['grams'] = Variable<double>(grams);
    map['unit'] = Variable<String>(unit);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  LoggedPortionsCompanion toCompanion(bool nullToAbsent) {
    return LoggedPortionsCompanion(
      id: Value(id),
      foodId: foodId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodId),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      logTimestamp: Value(logTimestamp),
      grams: Value(grams),
      unit: Value(unit),
      quantity: Value(quantity),
    );
  }

  factory LoggedPortion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoggedPortion(
      id: serializer.fromJson<int>(json['id']),
      foodId: serializer.fromJson<int?>(json['foodId']),
      recipeId: serializer.fromJson<int?>(json['recipeId']),
      logTimestamp: serializer.fromJson<int>(json['logTimestamp']),
      grams: serializer.fromJson<double>(json['grams']),
      unit: serializer.fromJson<String>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'foodId': serializer.toJson<int?>(foodId),
      'recipeId': serializer.toJson<int?>(recipeId),
      'logTimestamp': serializer.toJson<int>(logTimestamp),
      'grams': serializer.toJson<double>(grams),
      'unit': serializer.toJson<String>(unit),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  LoggedPortion copyWith({
    int? id,
    Value<int?> foodId = const Value.absent(),
    Value<int?> recipeId = const Value.absent(),
    int? logTimestamp,
    double? grams,
    String? unit,
    double? quantity,
  }) => LoggedPortion(
    id: id ?? this.id,
    foodId: foodId.present ? foodId.value : this.foodId,
    recipeId: recipeId.present ? recipeId.value : this.recipeId,
    logTimestamp: logTimestamp ?? this.logTimestamp,
    grams: grams ?? this.grams,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
  );
  LoggedPortion copyWithCompanion(LoggedPortionsCompanion data) {
    return LoggedPortion(
      id: data.id.present ? data.id.value : this.id,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      logTimestamp: data.logTimestamp.present
          ? data.logTimestamp.value
          : this.logTimestamp,
      grams: data.grams.present ? data.grams.value : this.grams,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoggedPortion(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('recipeId: $recipeId, ')
          ..write('logTimestamp: $logTimestamp, ')
          ..write('grams: $grams, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, foodId, recipeId, logTimestamp, grams, unit, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoggedPortion &&
          other.id == this.id &&
          other.foodId == this.foodId &&
          other.recipeId == this.recipeId &&
          other.logTimestamp == this.logTimestamp &&
          other.grams == this.grams &&
          other.unit == this.unit &&
          other.quantity == this.quantity);
}

class LoggedPortionsCompanion extends UpdateCompanion<LoggedPortion> {
  final Value<int> id;
  final Value<int?> foodId;
  final Value<int?> recipeId;
  final Value<int> logTimestamp;
  final Value<double> grams;
  final Value<String> unit;
  final Value<double> quantity;
  const LoggedPortionsCompanion({
    this.id = const Value.absent(),
    this.foodId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.logTimestamp = const Value.absent(),
    this.grams = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  LoggedPortionsCompanion.insert({
    this.id = const Value.absent(),
    this.foodId = const Value.absent(),
    this.recipeId = const Value.absent(),
    required int logTimestamp,
    required double grams,
    required String unit,
    required double quantity,
  }) : logTimestamp = Value(logTimestamp),
       grams = Value(grams),
       unit = Value(unit),
       quantity = Value(quantity);
  static Insertable<LoggedPortion> custom({
    Expression<int>? id,
    Expression<int>? foodId,
    Expression<int>? recipeId,
    Expression<int>? logTimestamp,
    Expression<double>? grams,
    Expression<String>? unit,
    Expression<double>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodId != null) 'loggedFoodId': foodId,
      if (recipeId != null) 'recipeId': recipeId,
      if (logTimestamp != null) 'log_timestamp': logTimestamp,
      if (grams != null) 'grams': grams,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
    });
  }

  LoggedPortionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? foodId,
    Value<int?>? recipeId,
    Value<int>? logTimestamp,
    Value<double>? grams,
    Value<String>? unit,
    Value<double>? quantity,
  }) {
    return LoggedPortionsCompanion(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      recipeId: recipeId ?? this.recipeId,
      logTimestamp: logTimestamp ?? this.logTimestamp,
      grams: grams ?? this.grams,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (foodId.present) {
      map['loggedFoodId'] = Variable<int>(foodId.value);
    }
    if (recipeId.present) {
      map['recipeId'] = Variable<int>(recipeId.value);
    }
    if (logTimestamp.present) {
      map['log_timestamp'] = Variable<int>(logTimestamp.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoggedPortionsCompanion(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('recipeId: $recipeId, ')
          ..write('logTimestamp: $logTimestamp, ')
          ..write('grams: $grams, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

class $WeightsTable extends Weights with TableInfo<$WeightsTable, Weight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, weight, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weights';
  @override
  VerificationContext validateIntegrity(
    Insertable<Weight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Weight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Weight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $WeightsTable createAlias(String alias) {
    return $WeightsTable(attachedDatabase, alias);
  }
}

class Weight extends DataClass implements Insertable<Weight> {
  final int id;
  final double weight;
  final int date;
  const Weight({required this.id, required this.weight, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weight'] = Variable<double>(weight);
    map['date'] = Variable<int>(date);
    return map;
  }

  WeightsCompanion toCompanion(bool nullToAbsent) {
    return WeightsCompanion(
      id: Value(id),
      weight: Value(weight),
      date: Value(date),
    );
  }

  factory Weight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Weight(
      id: serializer.fromJson<int>(json['id']),
      weight: serializer.fromJson<double>(json['weight']),
      date: serializer.fromJson<int>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weight': serializer.toJson<double>(weight),
      'date': serializer.toJson<int>(date),
    };
  }

  Weight copyWith({int? id, double? weight, int? date}) => Weight(
    id: id ?? this.id,
    weight: weight ?? this.weight,
    date: date ?? this.date,
  );
  Weight copyWithCompanion(WeightsCompanion data) {
    return Weight(
      id: data.id.present ? data.id.value : this.id,
      weight: data.weight.present ? data.weight.value : this.weight,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Weight(')
          ..write('id: $id, ')
          ..write('weight: $weight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weight, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Weight &&
          other.id == this.id &&
          other.weight == this.weight &&
          other.date == this.date);
}

class WeightsCompanion extends UpdateCompanion<Weight> {
  final Value<int> id;
  final Value<double> weight;
  final Value<int> date;
  const WeightsCompanion({
    this.id = const Value.absent(),
    this.weight = const Value.absent(),
    this.date = const Value.absent(),
  });
  WeightsCompanion.insert({
    this.id = const Value.absent(),
    required double weight,
    required int date,
  }) : weight = Value(weight),
       date = Value(date);
  static Insertable<Weight> custom({
    Expression<int>? id,
    Expression<double>? weight,
    Expression<int>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weight != null) 'weight': weight,
      if (date != null) 'date': date,
    });
  }

  WeightsCompanion copyWith({
    Value<int>? id,
    Value<double>? weight,
    Value<int>? date,
  }) {
    return WeightsCompanion(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightsCompanion(')
          ..write('id: $id, ')
          ..write('weight: $weight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $ContainersTable extends Containers
    with TableInfo<$ContainersTable, ContainerEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContainersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE',
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('g'),
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    weight,
    unit,
    thumbnail,
    hidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'containers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContainerEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContainerEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContainerEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      ),
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
    );
  }

  @override
  $ContainersTable createAlias(String alias) {
    return $ContainersTable(attachedDatabase, alias);
  }
}

class ContainerEntity extends DataClass implements Insertable<ContainerEntity> {
  final int id;
  final String name;
  final double weight;
  final String unit;
  final String? thumbnail;
  final bool hidden;
  const ContainerEntity({
    required this.id,
    required this.name,
    required this.weight,
    required this.unit,
    this.thumbnail,
    required this.hidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['weight'] = Variable<double>(weight);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<String>(thumbnail);
    }
    map['hidden'] = Variable<bool>(hidden);
    return map;
  }

  ContainersCompanion toCompanion(bool nullToAbsent) {
    return ContainersCompanion(
      id: Value(id),
      name: Value(name),
      weight: Value(weight),
      unit: Value(unit),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      hidden: Value(hidden),
    );
  }

  factory ContainerEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContainerEntity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      weight: serializer.fromJson<double>(json['weight']),
      unit: serializer.fromJson<String>(json['unit']),
      thumbnail: serializer.fromJson<String?>(json['thumbnail']),
      hidden: serializer.fromJson<bool>(json['hidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'weight': serializer.toJson<double>(weight),
      'unit': serializer.toJson<String>(unit),
      'thumbnail': serializer.toJson<String?>(thumbnail),
      'hidden': serializer.toJson<bool>(hidden),
    };
  }

  ContainerEntity copyWith({
    int? id,
    String? name,
    double? weight,
    String? unit,
    Value<String?> thumbnail = const Value.absent(),
    bool? hidden,
  }) => ContainerEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    weight: weight ?? this.weight,
    unit: unit ?? this.unit,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
    hidden: hidden ?? this.hidden,
  );
  ContainerEntity copyWithCompanion(ContainersCompanion data) {
    return ContainerEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      weight: data.weight.present ? data.weight.value : this.weight,
      unit: data.unit.present ? data.unit.value : this.unit,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContainerEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weight: $weight, ')
          ..write('unit: $unit, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('hidden: $hidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, weight, unit, thumbnail, hidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContainerEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.weight == this.weight &&
          other.unit == this.unit &&
          other.thumbnail == this.thumbnail &&
          other.hidden == this.hidden);
}

class ContainersCompanion extends UpdateCompanion<ContainerEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> weight;
  final Value<String> unit;
  final Value<String?> thumbnail;
  final Value<bool> hidden;
  const ContainersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.weight = const Value.absent(),
    this.unit = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.hidden = const Value.absent(),
  });
  ContainersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double weight,
    this.unit = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.hidden = const Value.absent(),
  }) : name = Value(name),
       weight = Value(weight);
  static Insertable<ContainerEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? weight,
    Expression<String>? unit,
    Expression<String>? thumbnail,
    Expression<bool>? hidden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (weight != null) 'weight': weight,
      if (unit != null) 'unit': unit,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (hidden != null) 'hidden': hidden,
    });
  }

  ContainersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? weight,
    Value<String>? unit,
    Value<String?>? thumbnail,
    Value<bool>? hidden,
  }) {
    return ContainersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      thumbnail: thumbnail ?? this.thumbnail,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContainersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weight: $weight, ')
          ..write('unit: $unit, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('hidden: $hidden')
          ..write(')'))
        .toString();
  }
}

class $FoodBarcodesTable extends FoodBarcodes
    with TableInfo<$FoodBarcodesTable, FoodBarcode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodBarcodesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, foodId, barcode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_barcodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodBarcode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {foodId, barcode},
  ];
  @override
  FoodBarcode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodBarcode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
    );
  }

  @override
  $FoodBarcodesTable createAlias(String alias) {
    return $FoodBarcodesTable(attachedDatabase, alias);
  }
}

class FoodBarcode extends DataClass implements Insertable<FoodBarcode> {
  final int id;
  final int foodId;
  final String barcode;
  const FoodBarcode({
    required this.id,
    required this.foodId,
    required this.barcode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['food_id'] = Variable<int>(foodId);
    map['barcode'] = Variable<String>(barcode);
    return map;
  }

  FoodBarcodesCompanion toCompanion(bool nullToAbsent) {
    return FoodBarcodesCompanion(
      id: Value(id),
      foodId: Value(foodId),
      barcode: Value(barcode),
    );
  }

  factory FoodBarcode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodBarcode(
      id: serializer.fromJson<int>(json['id']),
      foodId: serializer.fromJson<int>(json['foodId']),
      barcode: serializer.fromJson<String>(json['barcode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'foodId': serializer.toJson<int>(foodId),
      'barcode': serializer.toJson<String>(barcode),
    };
  }

  FoodBarcode copyWith({int? id, int? foodId, String? barcode}) => FoodBarcode(
    id: id ?? this.id,
    foodId: foodId ?? this.foodId,
    barcode: barcode ?? this.barcode,
  );
  FoodBarcode copyWithCompanion(FoodBarcodesCompanion data) {
    return FoodBarcode(
      id: data.id.present ? data.id.value : this.id,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodBarcode(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('barcode: $barcode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, foodId, barcode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodBarcode &&
          other.id == this.id &&
          other.foodId == this.foodId &&
          other.barcode == this.barcode);
}

class FoodBarcodesCompanion extends UpdateCompanion<FoodBarcode> {
  final Value<int> id;
  final Value<int> foodId;
  final Value<String> barcode;
  const FoodBarcodesCompanion({
    this.id = const Value.absent(),
    this.foodId = const Value.absent(),
    this.barcode = const Value.absent(),
  });
  FoodBarcodesCompanion.insert({
    this.id = const Value.absent(),
    required int foodId,
    required String barcode,
  }) : foodId = Value(foodId),
       barcode = Value(barcode);
  static Insertable<FoodBarcode> custom({
    Expression<int>? id,
    Expression<int>? foodId,
    Expression<String>? barcode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodId != null) 'food_id': foodId,
      if (barcode != null) 'barcode': barcode,
    });
  }

  FoodBarcodesCompanion copyWith({
    Value<int>? id,
    Value<int>? foodId,
    Value<String>? barcode,
  }) {
    return FoodBarcodesCompanion(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodBarcodesCompanion(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('barcode: $barcode')
          ..write(')'))
        .toString();
  }
}

abstract class _$LiveDatabase extends GeneratedDatabase {
  _$LiveDatabase(QueryExecutor e) : super(e);
  $LiveDatabaseManager get managers => $LiveDatabaseManager(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $FoodPortionsTable foodPortions = $FoodPortionsTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeItemsTable recipeItems = $RecipeItemsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecipeCategoryLinksTable recipeCategoryLinks =
      $RecipeCategoryLinksTable(this);
  late final $LoggedPortionsTable loggedPortions = $LoggedPortionsTable(this);
  late final $WeightsTable weights = $WeightsTable(this);
  late final $ContainersTable containers = $ContainersTable(this);
  late final $FoodBarcodesTable foodBarcodes = $FoodBarcodesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foods,
    foodPortions,
    recipes,
    recipeItems,
    categories,
    recipeCategoryLinks,
    loggedPortions,
    weights,
    containers,
    foodBarcodes,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'foods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('food_barcodes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FoodsTableCreateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      required String name,
      required String source,
      Value<String?> emoji,
      Value<String?> thumbnail,
      required double caloriesPerGram,
      required double proteinPerGram,
      required double fatPerGram,
      required double carbsPerGram,
      required double fiberPerGram,
      Value<int?> sourceFdcId,
      Value<String?> sourceBarcode,
      Value<String?> usageNote,
      Value<bool> hidden,
      Value<int?> parentId,
    });
typedef $$FoodsTableUpdateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> source,
      Value<String?> emoji,
      Value<String?> thumbnail,
      Value<double> caloriesPerGram,
      Value<double> proteinPerGram,
      Value<double> fatPerGram,
      Value<double> carbsPerGram,
      Value<double> fiberPerGram,
      Value<int?> sourceFdcId,
      Value<String?> sourceBarcode,
      Value<String?> usageNote,
      Value<bool> hidden,
      Value<int?> parentId,
    });

final class $$FoodsTableReferences
    extends BaseReferences<_$LiveDatabase, $FoodsTable, Food> {
  $$FoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _parentIdTable(_$LiveDatabase db) => db.foods.createAlias(
    $_aliasNameGenerator(db.foods.parentId, db.foods.id),
  );

  $$FoodsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parentId');
    if ($_column == null) return null;
    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FoodPortionsTable, List<FoodPortion>>
  _foodPortionsRefsTable(_$LiveDatabase db) => MultiTypedResultKey.fromTable(
    db.foodPortions,
    aliasName: $_aliasNameGenerator(db.foods.id, db.foodPortions.foodId),
  );

  $$FoodPortionsTableProcessedTableManager get foodPortionsRefs {
    final manager = $$FoodPortionsTableTableManager(
      $_db,
      $_db.foodPortions,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_foodPortionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeItemsTable, List<RecipeItem>>
  _recipeItemsRefsTable(_$LiveDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeItems,
    aliasName: $_aliasNameGenerator(
      db.foods.id,
      db.recipeItems.ingredientFoodId,
    ),
  );

  $$RecipeItemsTableProcessedTableManager get recipeItemsRefs {
    final manager = $$RecipeItemsTableTableManager(
      $_db,
      $_db.recipeItems,
    ).filter((f) => f.ingredientFoodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipeItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoggedPortionsTable, List<LoggedPortion>>
  _loggedPortionsRefsTable(_$LiveDatabase db) => MultiTypedResultKey.fromTable(
    db.loggedPortions,
    aliasName: $_aliasNameGenerator(db.foods.id, db.loggedPortions.foodId),
  );

  $$LoggedPortionsTableProcessedTableManager get loggedPortionsRefs {
    final manager = $$LoggedPortionsTableTableManager(
      $_db,
      $_db.loggedPortions,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loggedPortionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FoodBarcodesTable, List<FoodBarcode>>
  _foodBarcodesRefsTable(_$LiveDatabase db) => MultiTypedResultKey.fromTable(
    db.foodBarcodes,
    aliasName: $_aliasNameGenerator(db.foods.id, db.foodBarcodes.foodId),
  );

  $$FoodBarcodesTableProcessedTableManager get foodBarcodesRefs {
    final manager = $$FoodBarcodesTableTableManager(
      $_db,
      $_db.foodBarcodes,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_foodBarcodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodsTableFilterComposer extends Composer<_$LiveDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesPerGram => $composableBuilder(
    column: $table.caloriesPerGram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPerGram => $composableBuilder(
    column: $table.proteinPerGram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPerGram => $composableBuilder(
    column: $table.fatPerGram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPerGram => $composableBuilder(
    column: $table.carbsPerGram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberPerGram => $composableBuilder(
    column: $table.fiberPerGram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceFdcId => $composableBuilder(
    column: $table.sourceFdcId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceBarcode => $composableBuilder(
    column: $table.sourceBarcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageNote => $composableBuilder(
    column: $table.usageNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get parentId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> foodPortionsRefs(
    Expression<bool> Function($$FoodPortionsTableFilterComposer f) f,
  ) {
    final $$FoodPortionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foodPortions,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodPortionsTableFilterComposer(
            $db: $db,
            $table: $db.foodPortions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeItemsRefs(
    Expression<bool> Function($$RecipeItemsTableFilterComposer f) f,
  ) {
    final $$RecipeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.ingredientFoodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableFilterComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loggedPortionsRefs(
    Expression<bool> Function($$LoggedPortionsTableFilterComposer f) f,
  ) {
    final $$LoggedPortionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loggedPortions,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoggedPortionsTableFilterComposer(
            $db: $db,
            $table: $db.loggedPortions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> foodBarcodesRefs(
    Expression<bool> Function($$FoodBarcodesTableFilterComposer f) f,
  ) {
    final $$FoodBarcodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foodBarcodes,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodBarcodesTableFilterComposer(
            $db: $db,
            $table: $db.foodBarcodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableOrderingComposer
    extends Composer<_$LiveDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesPerGram => $composableBuilder(
    column: $table.caloriesPerGram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPerGram => $composableBuilder(
    column: $table.proteinPerGram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPerGram => $composableBuilder(
    column: $table.fatPerGram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPerGram => $composableBuilder(
    column: $table.carbsPerGram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberPerGram => $composableBuilder(
    column: $table.fiberPerGram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceFdcId => $composableBuilder(
    column: $table.sourceFdcId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceBarcode => $composableBuilder(
    column: $table.sourceBarcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageNote => $composableBuilder(
    column: $table.usageNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get parentId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$LiveDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<double> get caloriesPerGram => $composableBuilder(
    column: $table.caloriesPerGram,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPerGram => $composableBuilder(
    column: $table.proteinPerGram,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPerGram => $composableBuilder(
    column: $table.fatPerGram,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPerGram => $composableBuilder(
    column: $table.carbsPerGram,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberPerGram => $composableBuilder(
    column: $table.fiberPerGram,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceFdcId => $composableBuilder(
    column: $table.sourceFdcId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceBarcode => $composableBuilder(
    column: $table.sourceBarcode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usageNote =>
      $composableBuilder(column: $table.usageNote, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  $$FoodsTableAnnotationComposer get parentId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> foodPortionsRefs<T extends Object>(
    Expression<T> Function($$FoodPortionsTableAnnotationComposer a) f,
  ) {
    final $$FoodPortionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foodPortions,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodPortionsTableAnnotationComposer(
            $db: $db,
            $table: $db.foodPortions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recipeItemsRefs<T extends Object>(
    Expression<T> Function($$RecipeItemsTableAnnotationComposer a) f,
  ) {
    final $$RecipeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.ingredientFoodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loggedPortionsRefs<T extends Object>(
    Expression<T> Function($$LoggedPortionsTableAnnotationComposer a) f,
  ) {
    final $$LoggedPortionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loggedPortions,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoggedPortionsTableAnnotationComposer(
            $db: $db,
            $table: $db.loggedPortions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> foodBarcodesRefs<T extends Object>(
    Expression<T> Function($$FoodBarcodesTableAnnotationComposer a) f,
  ) {
    final $$FoodBarcodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foodBarcodes,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodBarcodesTableAnnotationComposer(
            $db: $db,
            $table: $db.foodBarcodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $FoodsTable,
          Food,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (Food, $$FoodsTableReferences),
          Food,
          PrefetchHooks Function({
            bool parentId,
            bool foodPortionsRefs,
            bool recipeItemsRefs,
            bool loggedPortionsRefs,
            bool foodBarcodesRefs,
          })
        > {
  $$FoodsTableTableManager(_$LiveDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<double> caloriesPerGram = const Value.absent(),
                Value<double> proteinPerGram = const Value.absent(),
                Value<double> fatPerGram = const Value.absent(),
                Value<double> carbsPerGram = const Value.absent(),
                Value<double> fiberPerGram = const Value.absent(),
                Value<int?> sourceFdcId = const Value.absent(),
                Value<String?> sourceBarcode = const Value.absent(),
                Value<String?> usageNote = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                name: name,
                source: source,
                emoji: emoji,
                thumbnail: thumbnail,
                caloriesPerGram: caloriesPerGram,
                proteinPerGram: proteinPerGram,
                fatPerGram: fatPerGram,
                carbsPerGram: carbsPerGram,
                fiberPerGram: fiberPerGram,
                sourceFdcId: sourceFdcId,
                sourceBarcode: sourceBarcode,
                usageNote: usageNote,
                hidden: hidden,
                parentId: parentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String source,
                Value<String?> emoji = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                required double caloriesPerGram,
                required double proteinPerGram,
                required double fatPerGram,
                required double carbsPerGram,
                required double fiberPerGram,
                Value<int?> sourceFdcId = const Value.absent(),
                Value<String?> sourceBarcode = const Value.absent(),
                Value<String?> usageNote = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                name: name,
                source: source,
                emoji: emoji,
                thumbnail: thumbnail,
                caloriesPerGram: caloriesPerGram,
                proteinPerGram: proteinPerGram,
                fatPerGram: fatPerGram,
                carbsPerGram: carbsPerGram,
                fiberPerGram: fiberPerGram,
                sourceFdcId: sourceFdcId,
                sourceBarcode: sourceBarcode,
                usageNote: usageNote,
                hidden: hidden,
                parentId: parentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FoodsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                foodPortionsRefs = false,
                recipeItemsRefs = false,
                loggedPortionsRefs = false,
                foodBarcodesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (foodPortionsRefs) db.foodPortions,
                    if (recipeItemsRefs) db.recipeItems,
                    if (loggedPortionsRefs) db.loggedPortions,
                    if (foodBarcodesRefs) db.foodBarcodes,
                  ],
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
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable: $$FoodsTableReferences
                                        ._parentIdTable(db),
                                    referencedColumn: $$FoodsTableReferences
                                        ._parentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (foodPortionsRefs)
                        await $_getPrefetchedData<
                          Food,
                          $FoodsTable,
                          FoodPortion
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._foodPortionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).foodPortionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeItemsRefs)
                        await $_getPrefetchedData<
                          Food,
                          $FoodsTable,
                          RecipeItem
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._recipeItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientFoodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (loggedPortionsRefs)
                        await $_getPrefetchedData<
                          Food,
                          $FoodsTable,
                          LoggedPortion
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._loggedPortionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).loggedPortionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (foodBarcodesRefs)
                        await $_getPrefetchedData<
                          Food,
                          $FoodsTable,
                          FoodBarcode
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._foodBarcodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).foodBarcodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $FoodsTable,
      Food,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (Food, $$FoodsTableReferences),
      Food,
      PrefetchHooks Function({
        bool parentId,
        bool foodPortionsRefs,
        bool recipeItemsRefs,
        bool loggedPortionsRefs,
        bool foodBarcodesRefs,
      })
    >;
typedef $$FoodPortionsTableCreateCompanionBuilder =
    FoodPortionsCompanion Function({
      Value<int> id,
      required int foodId,
      required String unit,
      required double grams,
      required double quantity,
    });
typedef $$FoodPortionsTableUpdateCompanionBuilder =
    FoodPortionsCompanion Function({
      Value<int> id,
      Value<int> foodId,
      Value<String> unit,
      Value<double> grams,
      Value<double> quantity,
    });

final class $$FoodPortionsTableReferences
    extends BaseReferences<_$LiveDatabase, $FoodPortionsTable, FoodPortion> {
  $$FoodPortionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _foodIdTable(_$LiveDatabase db) => db.foods.createAlias(
    $_aliasNameGenerator(db.foodPortions.foodId, db.foods.id),
  );

  $$FoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<int>('foodId')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FoodPortionsTableFilterComposer
    extends Composer<_$LiveDatabase, $FoodPortionsTable> {
  $$FoodPortionsTableFilterComposer({
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

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodPortionsTableOrderingComposer
    extends Composer<_$LiveDatabase, $FoodPortionsTable> {
  $$FoodPortionsTableOrderingComposer({
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

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodPortionsTableAnnotationComposer
    extends Composer<_$LiveDatabase, $FoodPortionsTable> {
  $$FoodPortionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodPortionsTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $FoodPortionsTable,
          FoodPortion,
          $$FoodPortionsTableFilterComposer,
          $$FoodPortionsTableOrderingComposer,
          $$FoodPortionsTableAnnotationComposer,
          $$FoodPortionsTableCreateCompanionBuilder,
          $$FoodPortionsTableUpdateCompanionBuilder,
          (FoodPortion, $$FoodPortionsTableReferences),
          FoodPortion,
          PrefetchHooks Function({bool foodId})
        > {
  $$FoodPortionsTableTableManager(_$LiveDatabase db, $FoodPortionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodPortionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodPortionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodPortionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> foodId = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> quantity = const Value.absent(),
              }) => FoodPortionsCompanion(
                id: id,
                foodId: foodId,
                unit: unit,
                grams: grams,
                quantity: quantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int foodId,
                required String unit,
                required double grams,
                required double quantity,
              }) => FoodPortionsCompanion.insert(
                id: id,
                foodId: foodId,
                unit: unit,
                grams: grams,
                quantity: quantity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoodPortionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false}) {
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
                    if (foodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.foodId,
                                referencedTable: $$FoodPortionsTableReferences
                                    ._foodIdTable(db),
                                referencedColumn: $$FoodPortionsTableReferences
                                    ._foodIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$FoodPortionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $FoodPortionsTable,
      FoodPortion,
      $$FoodPortionsTableFilterComposer,
      $$FoodPortionsTableOrderingComposer,
      $$FoodPortionsTableAnnotationComposer,
      $$FoodPortionsTableCreateCompanionBuilder,
      $$FoodPortionsTableUpdateCompanionBuilder,
      (FoodPortion, $$FoodPortionsTableReferences),
      FoodPortion,
      PrefetchHooks Function({bool foodId})
    >;
typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> emoji,
      Value<String?> thumbnail,
      Value<double> servingsCreated,
      Value<double?> finalWeightGrams,
      Value<String> portionName,
      Value<String?> notes,
      Value<String?> link,
      Value<bool> isTemplate,
      Value<bool> hidden,
      Value<int?> parentId,
      required int createdTimestamp,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> emoji,
      Value<String?> thumbnail,
      Value<double> servingsCreated,
      Value<double?> finalWeightGrams,
      Value<String> portionName,
      Value<String?> notes,
      Value<String?> link,
      Value<bool> isTemplate,
      Value<bool> hidden,
      Value<int?> parentId,
      Value<int> createdTimestamp,
    });

final class $$RecipesTableReferences
    extends BaseReferences<_$LiveDatabase, $RecipesTable, Recipe> {
  $$RecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _parentIdTable(_$LiveDatabase db) => db.recipes
      .createAlias($_aliasNameGenerator(db.recipes.parentId, db.recipes.id));

  $$RecipesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RecipeItemsTable, List<RecipeItem>>
  _RecipeEntriesTable(_$LiveDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeItems,
    aliasName: $_aliasNameGenerator(db.recipes.id, db.recipeItems.recipeId),
  );

  $$RecipeItemsTableProcessedTableManager get RecipeEntries {
    final manager = $$RecipeItemsTableTableManager(
      $_db,
      $_db.recipeItems,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_RecipeEntriesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeItemsTable, List<RecipeItem>>
  _IngredientRecipesTable(_$LiveDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeItems,
    aliasName: $_aliasNameGenerator(
      db.recipes.id,
      db.recipeItems.ingredientRecipeId,
    ),
  );

  $$RecipeItemsTableProcessedTableManager get IngredientRecipes {
    final manager = $$RecipeItemsTableTableManager($_db, $_db.recipeItems)
        .filter(
          (f) => f.ingredientRecipeId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_IngredientRecipesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecipeCategoryLinksTable,
    List<RecipeCategoryLink>
  >
  _recipeCategoryLinksRefsTable(_$LiveDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeCategoryLinks,
        aliasName: $_aliasNameGenerator(
          db.recipes.id,
          db.recipeCategoryLinks.recipeId,
        ),
      );

  $$RecipeCategoryLinksTableProcessedTableManager get recipeCategoryLinksRefs {
    final manager = $$RecipeCategoryLinksTableTableManager(
      $_db,
      $_db.recipeCategoryLinks,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeCategoryLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoggedPortionsTable, List<LoggedPortion>>
  _loggedPortionsRefsTable(_$LiveDatabase db) => MultiTypedResultKey.fromTable(
    db.loggedPortions,
    aliasName: $_aliasNameGenerator(db.recipes.id, db.loggedPortions.recipeId),
  );

  $$LoggedPortionsTableProcessedTableManager get loggedPortionsRefs {
    final manager = $$LoggedPortionsTableTableManager(
      $_db,
      $_db.loggedPortions,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loggedPortionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecipesTableFilterComposer
    extends Composer<_$LiveDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingsCreated => $composableBuilder(
    column: $table.servingsCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get finalWeightGrams => $composableBuilder(
    column: $table.finalWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portionName => $composableBuilder(
    column: $table.portionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get parentId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> RecipeEntries(
    Expression<bool> Function($$RecipeItemsTableFilterComposer f) f,
  ) {
    final $$RecipeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableFilterComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> IngredientRecipes(
    Expression<bool> Function($$RecipeItemsTableFilterComposer f) f,
  ) {
    final $$RecipeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.ingredientRecipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableFilterComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeCategoryLinksRefs(
    Expression<bool> Function($$RecipeCategoryLinksTableFilterComposer f) f,
  ) {
    final $$RecipeCategoryLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeCategoryLinks,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeCategoryLinksTableFilterComposer(
            $db: $db,
            $table: $db.recipeCategoryLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loggedPortionsRefs(
    Expression<bool> Function($$LoggedPortionsTableFilterComposer f) f,
  ) {
    final $$LoggedPortionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loggedPortions,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoggedPortionsTableFilterComposer(
            $db: $db,
            $table: $db.loggedPortions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableOrderingComposer
    extends Composer<_$LiveDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingsCreated => $composableBuilder(
    column: $table.servingsCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get finalWeightGrams => $composableBuilder(
    column: $table.finalWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portionName => $composableBuilder(
    column: $table.portionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get parentId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$LiveDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<double> get servingsCreated => $composableBuilder(
    column: $table.servingsCreated,
    builder: (column) => column,
  );

  GeneratedColumn<double> get finalWeightGrams => $composableBuilder(
    column: $table.finalWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get portionName => $composableBuilder(
    column: $table.portionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<bool> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => column,
  );

  $$RecipesTableAnnotationComposer get parentId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> RecipeEntries<T extends Object>(
    Expression<T> Function($$RecipeItemsTableAnnotationComposer a) f,
  ) {
    final $$RecipeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> IngredientRecipes<T extends Object>(
    Expression<T> Function($$RecipeItemsTableAnnotationComposer a) f,
  ) {
    final $$RecipeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeItems,
      getReferencedColumn: (t) => t.ingredientRecipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recipeCategoryLinksRefs<T extends Object>(
    Expression<T> Function($$RecipeCategoryLinksTableAnnotationComposer a) f,
  ) {
    final $$RecipeCategoryLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recipeCategoryLinks,
          getReferencedColumn: (t) => t.recipeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeCategoryLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeCategoryLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> loggedPortionsRefs<T extends Object>(
    Expression<T> Function($$LoggedPortionsTableAnnotationComposer a) f,
  ) {
    final $$LoggedPortionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loggedPortions,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoggedPortionsTableAnnotationComposer(
            $db: $db,
            $table: $db.loggedPortions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, $$RecipesTableReferences),
          Recipe,
          PrefetchHooks Function({
            bool parentId,
            bool RecipeEntries,
            bool IngredientRecipes,
            bool recipeCategoryLinksRefs,
            bool loggedPortionsRefs,
          })
        > {
  $$RecipesTableTableManager(_$LiveDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<double> servingsCreated = const Value.absent(),
                Value<double?> finalWeightGrams = const Value.absent(),
                Value<String> portionName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<bool> isTemplate = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> createdTimestamp = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                name: name,
                emoji: emoji,
                thumbnail: thumbnail,
                servingsCreated: servingsCreated,
                finalWeightGrams: finalWeightGrams,
                portionName: portionName,
                notes: notes,
                link: link,
                isTemplate: isTemplate,
                hidden: hidden,
                parentId: parentId,
                createdTimestamp: createdTimestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> emoji = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<double> servingsCreated = const Value.absent(),
                Value<double?> finalWeightGrams = const Value.absent(),
                Value<String> portionName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<bool> isTemplate = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                required int createdTimestamp,
              }) => RecipesCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                thumbnail: thumbnail,
                servingsCreated: servingsCreated,
                finalWeightGrams: finalWeightGrams,
                portionName: portionName,
                notes: notes,
                link: link,
                isTemplate: isTemplate,
                hidden: hidden,
                parentId: parentId,
                createdTimestamp: createdTimestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                RecipeEntries = false,
                IngredientRecipes = false,
                recipeCategoryLinksRefs = false,
                loggedPortionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (RecipeEntries) db.recipeItems,
                    if (IngredientRecipes) db.recipeItems,
                    if (recipeCategoryLinksRefs) db.recipeCategoryLinks,
                    if (loggedPortionsRefs) db.loggedPortions,
                  ],
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
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable: $$RecipesTableReferences
                                        ._parentIdTable(db),
                                    referencedColumn: $$RecipesTableReferences
                                        ._parentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (RecipeEntries)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeItem
                        >(
                          currentTable: table,
                          referencedTable:
                              $$RecipesTableReferences._RecipeEntriesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).RecipeEntries,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (IngredientRecipes)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeItem
                        >(
                          currentTable: table,
                          referencedTable:
                              $$RecipesTableReferences._IngredientRecipesTable(
                                db,
                              ),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).IngredientRecipes,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientRecipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeCategoryLinksRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeCategoryLink
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeCategoryLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeCategoryLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (loggedPortionsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          LoggedPortion
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._loggedPortionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).loggedPortionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, $$RecipesTableReferences),
      Recipe,
      PrefetchHooks Function({
        bool parentId,
        bool RecipeEntries,
        bool IngredientRecipes,
        bool recipeCategoryLinksRefs,
        bool loggedPortionsRefs,
      })
    >;
typedef $$RecipeItemsTableCreateCompanionBuilder =
    RecipeItemsCompanion Function({
      Value<int> id,
      required int recipeId,
      Value<int?> ingredientFoodId,
      Value<int?> ingredientRecipeId,
      required double grams,
      required String unit,
      Value<int> position,
    });
typedef $$RecipeItemsTableUpdateCompanionBuilder =
    RecipeItemsCompanion Function({
      Value<int> id,
      Value<int> recipeId,
      Value<int?> ingredientFoodId,
      Value<int?> ingredientRecipeId,
      Value<double> grams,
      Value<String> unit,
      Value<int> position,
    });

final class $$RecipeItemsTableReferences
    extends BaseReferences<_$LiveDatabase, $RecipeItemsTable, RecipeItem> {
  $$RecipeItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _recipeIdTable(_$LiveDatabase db) =>
      db.recipes.createAlias(
        $_aliasNameGenerator(db.recipeItems.recipeId, db.recipes.id),
      );

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<int>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FoodsTable _ingredientFoodIdTable(_$LiveDatabase db) =>
      db.foods.createAlias(
        $_aliasNameGenerator(db.recipeItems.ingredientFoodId, db.foods.id),
      );

  $$FoodsTableProcessedTableManager? get ingredientFoodId {
    final $_column = $_itemColumn<int>('ingredient_food_id');
    if ($_column == null) return null;
    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientFoodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecipesTable _ingredientRecipeIdTable(_$LiveDatabase db) =>
      db.recipes.createAlias(
        $_aliasNameGenerator(db.recipeItems.ingredientRecipeId, db.recipes.id),
      );

  $$RecipesTableProcessedTableManager? get ingredientRecipeId {
    final $_column = $_itemColumn<int>('ingredient_recipe_id');
    if ($_column == null) return null;
    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientRecipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeItemsTableFilterComposer
    extends Composer<_$LiveDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableFilterComposer({
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

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableFilterComposer get ingredientFoodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientFoodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableFilterComposer get ingredientRecipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientRecipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableOrderingComposer
    extends Composer<_$LiveDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableOrderingComposer({
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

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableOrderingComposer get ingredientFoodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientFoodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableOrderingComposer get ingredientRecipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientRecipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableAnnotationComposer
    extends Composer<_$LiveDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodsTableAnnotationComposer get ingredientFoodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientFoodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableAnnotationComposer get ingredientRecipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientRecipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeItemsTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $RecipeItemsTable,
          RecipeItem,
          $$RecipeItemsTableFilterComposer,
          $$RecipeItemsTableOrderingComposer,
          $$RecipeItemsTableAnnotationComposer,
          $$RecipeItemsTableCreateCompanionBuilder,
          $$RecipeItemsTableUpdateCompanionBuilder,
          (RecipeItem, $$RecipeItemsTableReferences),
          RecipeItem,
          PrefetchHooks Function({
            bool recipeId,
            bool ingredientFoodId,
            bool ingredientRecipeId,
          })
        > {
  $$RecipeItemsTableTableManager(_$LiveDatabase db, $RecipeItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recipeId = const Value.absent(),
                Value<int?> ingredientFoodId = const Value.absent(),
                Value<int?> ingredientRecipeId = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => RecipeItemsCompanion(
                id: id,
                recipeId: recipeId,
                ingredientFoodId: ingredientFoodId,
                ingredientRecipeId: ingredientRecipeId,
                grams: grams,
                unit: unit,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recipeId,
                Value<int?> ingredientFoodId = const Value.absent(),
                Value<int?> ingredientRecipeId = const Value.absent(),
                required double grams,
                required String unit,
                Value<int> position = const Value.absent(),
              }) => RecipeItemsCompanion.insert(
                id: id,
                recipeId: recipeId,
                ingredientFoodId: ingredientFoodId,
                ingredientRecipeId: ingredientRecipeId,
                grams: grams,
                unit: unit,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                recipeId = false,
                ingredientFoodId = false,
                ingredientRecipeId = false,
              }) {
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
                        if (recipeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recipeId,
                                    referencedTable:
                                        $$RecipeItemsTableReferences
                                            ._recipeIdTable(db),
                                    referencedColumn:
                                        $$RecipeItemsTableReferences
                                            ._recipeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (ingredientFoodId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ingredientFoodId,
                                    referencedTable:
                                        $$RecipeItemsTableReferences
                                            ._ingredientFoodIdTable(db),
                                    referencedColumn:
                                        $$RecipeItemsTableReferences
                                            ._ingredientFoodIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (ingredientRecipeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ingredientRecipeId,
                                    referencedTable:
                                        $$RecipeItemsTableReferences
                                            ._ingredientRecipeIdTable(db),
                                    referencedColumn:
                                        $$RecipeItemsTableReferences
                                            ._ingredientRecipeIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$RecipeItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $RecipeItemsTable,
      RecipeItem,
      $$RecipeItemsTableFilterComposer,
      $$RecipeItemsTableOrderingComposer,
      $$RecipeItemsTableAnnotationComposer,
      $$RecipeItemsTableCreateCompanionBuilder,
      $$RecipeItemsTableUpdateCompanionBuilder,
      (RecipeItem, $$RecipeItemsTableReferences),
      RecipeItem,
      PrefetchHooks Function({
        bool recipeId,
        bool ingredientFoodId,
        bool ingredientRecipeId,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({Value<int> id, required String name});
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({Value<int> id, Value<String> name});

final class $$CategoriesTableReferences
    extends BaseReferences<_$LiveDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RecipeCategoryLinksTable,
    List<RecipeCategoryLink>
  >
  _recipeCategoryLinksRefsTable(_$LiveDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeCategoryLinks,
        aliasName: $_aliasNameGenerator(
          db.categories.id,
          db.recipeCategoryLinks.categoryId,
        ),
      );

  $$RecipeCategoryLinksTableProcessedTableManager get recipeCategoryLinksRefs {
    final manager = $$RecipeCategoryLinksTableTableManager(
      $_db,
      $_db.recipeCategoryLinks,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeCategoryLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$LiveDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeCategoryLinksRefs(
    Expression<bool> Function($$RecipeCategoryLinksTableFilterComposer f) f,
  ) {
    final $$RecipeCategoryLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeCategoryLinks,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeCategoryLinksTableFilterComposer(
            $db: $db,
            $table: $db.recipeCategoryLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$LiveDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$LiveDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> recipeCategoryLinksRefs<T extends Object>(
    Expression<T> Function($$RecipeCategoryLinksTableAnnotationComposer a) f,
  ) {
    final $$RecipeCategoryLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recipeCategoryLinks,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeCategoryLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeCategoryLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool recipeCategoryLinksRefs})
        > {
  $$CategoriesTableTableManager(_$LiveDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => CategoriesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  CategoriesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeCategoryLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recipeCategoryLinksRefs) db.recipeCategoryLinks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recipeCategoryLinksRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      RecipeCategoryLink
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._recipeCategoryLinksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).recipeCategoryLinksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool recipeCategoryLinksRefs})
    >;
typedef $$RecipeCategoryLinksTableCreateCompanionBuilder =
    RecipeCategoryLinksCompanion Function({
      required int recipeId,
      required int categoryId,
      Value<int> rowid,
    });
typedef $$RecipeCategoryLinksTableUpdateCompanionBuilder =
    RecipeCategoryLinksCompanion Function({
      Value<int> recipeId,
      Value<int> categoryId,
      Value<int> rowid,
    });

final class $$RecipeCategoryLinksTableReferences
    extends
        BaseReferences<
          _$LiveDatabase,
          $RecipeCategoryLinksTable,
          RecipeCategoryLink
        > {
  $$RecipeCategoryLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecipesTable _recipeIdTable(_$LiveDatabase db) =>
      db.recipes.createAlias(
        $_aliasNameGenerator(db.recipeCategoryLinks.recipeId, db.recipes.id),
      );

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<int>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$LiveDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(
          db.recipeCategoryLinks.categoryId,
          db.categories.id,
        ),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeCategoryLinksTableFilterComposer
    extends Composer<_$LiveDatabase, $RecipeCategoryLinksTable> {
  $$RecipeCategoryLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeCategoryLinksTableOrderingComposer
    extends Composer<_$LiveDatabase, $RecipeCategoryLinksTable> {
  $$RecipeCategoryLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeCategoryLinksTableAnnotationComposer
    extends Composer<_$LiveDatabase, $RecipeCategoryLinksTable> {
  $$RecipeCategoryLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeCategoryLinksTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $RecipeCategoryLinksTable,
          RecipeCategoryLink,
          $$RecipeCategoryLinksTableFilterComposer,
          $$RecipeCategoryLinksTableOrderingComposer,
          $$RecipeCategoryLinksTableAnnotationComposer,
          $$RecipeCategoryLinksTableCreateCompanionBuilder,
          $$RecipeCategoryLinksTableUpdateCompanionBuilder,
          (RecipeCategoryLink, $$RecipeCategoryLinksTableReferences),
          RecipeCategoryLink,
          PrefetchHooks Function({bool recipeId, bool categoryId})
        > {
  $$RecipeCategoryLinksTableTableManager(
    _$LiveDatabase db,
    $RecipeCategoryLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeCategoryLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeCategoryLinksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecipeCategoryLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> recipeId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeCategoryLinksCompanion(
                recipeId: recipeId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int recipeId,
                required int categoryId,
                Value<int> rowid = const Value.absent(),
              }) => RecipeCategoryLinksCompanion.insert(
                recipeId: recipeId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeCategoryLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false, categoryId = false}) {
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
                    if (recipeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeId,
                                referencedTable:
                                    $$RecipeCategoryLinksTableReferences
                                        ._recipeIdTable(db),
                                referencedColumn:
                                    $$RecipeCategoryLinksTableReferences
                                        ._recipeIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$RecipeCategoryLinksTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$RecipeCategoryLinksTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$RecipeCategoryLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $RecipeCategoryLinksTable,
      RecipeCategoryLink,
      $$RecipeCategoryLinksTableFilterComposer,
      $$RecipeCategoryLinksTableOrderingComposer,
      $$RecipeCategoryLinksTableAnnotationComposer,
      $$RecipeCategoryLinksTableCreateCompanionBuilder,
      $$RecipeCategoryLinksTableUpdateCompanionBuilder,
      (RecipeCategoryLink, $$RecipeCategoryLinksTableReferences),
      RecipeCategoryLink,
      PrefetchHooks Function({bool recipeId, bool categoryId})
    >;
typedef $$LoggedPortionsTableCreateCompanionBuilder =
    LoggedPortionsCompanion Function({
      Value<int> id,
      Value<int?> foodId,
      Value<int?> recipeId,
      required int logTimestamp,
      required double grams,
      required String unit,
      required double quantity,
    });
typedef $$LoggedPortionsTableUpdateCompanionBuilder =
    LoggedPortionsCompanion Function({
      Value<int> id,
      Value<int?> foodId,
      Value<int?> recipeId,
      Value<int> logTimestamp,
      Value<double> grams,
      Value<String> unit,
      Value<double> quantity,
    });

final class $$LoggedPortionsTableReferences
    extends
        BaseReferences<_$LiveDatabase, $LoggedPortionsTable, LoggedPortion> {
  $$LoggedPortionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FoodsTable _foodIdTable(_$LiveDatabase db) => db.foods.createAlias(
    $_aliasNameGenerator(db.loggedPortions.foodId, db.foods.id),
  );

  $$FoodsTableProcessedTableManager? get foodId {
    final $_column = $_itemColumn<int>('loggedFoodId');
    if ($_column == null) return null;
    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecipesTable _recipeIdTable(_$LiveDatabase db) =>
      db.recipes.createAlias(
        $_aliasNameGenerator(db.loggedPortions.recipeId, db.recipes.id),
      );

  $$RecipesTableProcessedTableManager? get recipeId {
    final $_column = $_itemColumn<int>('recipeId');
    if ($_column == null) return null;
    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoggedPortionsTableFilterComposer
    extends Composer<_$LiveDatabase, $LoggedPortionsTable> {
  $$LoggedPortionsTableFilterComposer({
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

  ColumnFilters<int> get logTimestamp => $composableBuilder(
    column: $table.logTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoggedPortionsTableOrderingComposer
    extends Composer<_$LiveDatabase, $LoggedPortionsTable> {
  $$LoggedPortionsTableOrderingComposer({
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

  ColumnOrderings<int> get logTimestamp => $composableBuilder(
    column: $table.logTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoggedPortionsTableAnnotationComposer
    extends Composer<_$LiveDatabase, $LoggedPortionsTable> {
  $$LoggedPortionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get logTimestamp => $composableBuilder(
    column: $table.logTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoggedPortionsTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $LoggedPortionsTable,
          LoggedPortion,
          $$LoggedPortionsTableFilterComposer,
          $$LoggedPortionsTableOrderingComposer,
          $$LoggedPortionsTableAnnotationComposer,
          $$LoggedPortionsTableCreateCompanionBuilder,
          $$LoggedPortionsTableUpdateCompanionBuilder,
          (LoggedPortion, $$LoggedPortionsTableReferences),
          LoggedPortion,
          PrefetchHooks Function({bool foodId, bool recipeId})
        > {
  $$LoggedPortionsTableTableManager(
    _$LiveDatabase db,
    $LoggedPortionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoggedPortionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoggedPortionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoggedPortionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> foodId = const Value.absent(),
                Value<int?> recipeId = const Value.absent(),
                Value<int> logTimestamp = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> quantity = const Value.absent(),
              }) => LoggedPortionsCompanion(
                id: id,
                foodId: foodId,
                recipeId: recipeId,
                logTimestamp: logTimestamp,
                grams: grams,
                unit: unit,
                quantity: quantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> foodId = const Value.absent(),
                Value<int?> recipeId = const Value.absent(),
                required int logTimestamp,
                required double grams,
                required String unit,
                required double quantity,
              }) => LoggedPortionsCompanion.insert(
                id: id,
                foodId: foodId,
                recipeId: recipeId,
                logTimestamp: logTimestamp,
                grams: grams,
                unit: unit,
                quantity: quantity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LoggedPortionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false, recipeId = false}) {
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
                    if (foodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.foodId,
                                referencedTable: $$LoggedPortionsTableReferences
                                    ._foodIdTable(db),
                                referencedColumn:
                                    $$LoggedPortionsTableReferences
                                        ._foodIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (recipeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeId,
                                referencedTable: $$LoggedPortionsTableReferences
                                    ._recipeIdTable(db),
                                referencedColumn:
                                    $$LoggedPortionsTableReferences
                                        ._recipeIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$LoggedPortionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $LoggedPortionsTable,
      LoggedPortion,
      $$LoggedPortionsTableFilterComposer,
      $$LoggedPortionsTableOrderingComposer,
      $$LoggedPortionsTableAnnotationComposer,
      $$LoggedPortionsTableCreateCompanionBuilder,
      $$LoggedPortionsTableUpdateCompanionBuilder,
      (LoggedPortion, $$LoggedPortionsTableReferences),
      LoggedPortion,
      PrefetchHooks Function({bool foodId, bool recipeId})
    >;
typedef $$WeightsTableCreateCompanionBuilder =
    WeightsCompanion Function({
      Value<int> id,
      required double weight,
      required int date,
    });
typedef $$WeightsTableUpdateCompanionBuilder =
    WeightsCompanion Function({
      Value<int> id,
      Value<double> weight,
      Value<int> date,
    });

class $$WeightsTableFilterComposer
    extends Composer<_$LiveDatabase, $WeightsTable> {
  $$WeightsTableFilterComposer({
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

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightsTableOrderingComposer
    extends Composer<_$LiveDatabase, $WeightsTable> {
  $$WeightsTableOrderingComposer({
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

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightsTableAnnotationComposer
    extends Composer<_$LiveDatabase, $WeightsTable> {
  $$WeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$WeightsTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $WeightsTable,
          Weight,
          $$WeightsTableFilterComposer,
          $$WeightsTableOrderingComposer,
          $$WeightsTableAnnotationComposer,
          $$WeightsTableCreateCompanionBuilder,
          $$WeightsTableUpdateCompanionBuilder,
          (Weight, BaseReferences<_$LiveDatabase, $WeightsTable, Weight>),
          Weight,
          PrefetchHooks Function()
        > {
  $$WeightsTableTableManager(_$LiveDatabase db, $WeightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> date = const Value.absent(),
              }) => WeightsCompanion(id: id, weight: weight, date: date),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double weight,
                required int date,
              }) => WeightsCompanion.insert(id: id, weight: weight, date: date),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightsTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $WeightsTable,
      Weight,
      $$WeightsTableFilterComposer,
      $$WeightsTableOrderingComposer,
      $$WeightsTableAnnotationComposer,
      $$WeightsTableCreateCompanionBuilder,
      $$WeightsTableUpdateCompanionBuilder,
      (Weight, BaseReferences<_$LiveDatabase, $WeightsTable, Weight>),
      Weight,
      PrefetchHooks Function()
    >;
typedef $$ContainersTableCreateCompanionBuilder =
    ContainersCompanion Function({
      Value<int> id,
      required String name,
      required double weight,
      Value<String> unit,
      Value<String?> thumbnail,
      Value<bool> hidden,
    });
typedef $$ContainersTableUpdateCompanionBuilder =
    ContainersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> weight,
      Value<String> unit,
      Value<String?> thumbnail,
      Value<bool> hidden,
    });

class $$ContainersTableFilterComposer
    extends Composer<_$LiveDatabase, $ContainersTable> {
  $$ContainersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContainersTableOrderingComposer
    extends Composer<_$LiveDatabase, $ContainersTable> {
  $$ContainersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContainersTableAnnotationComposer
    extends Composer<_$LiveDatabase, $ContainersTable> {
  $$ContainersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);
}

class $$ContainersTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $ContainersTable,
          ContainerEntity,
          $$ContainersTableFilterComposer,
          $$ContainersTableOrderingComposer,
          $$ContainersTableAnnotationComposer,
          $$ContainersTableCreateCompanionBuilder,
          $$ContainersTableUpdateCompanionBuilder,
          (
            ContainerEntity,
            BaseReferences<_$LiveDatabase, $ContainersTable, ContainerEntity>,
          ),
          ContainerEntity,
          PrefetchHooks Function()
        > {
  $$ContainersTableTableManager(_$LiveDatabase db, $ContainersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContainersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContainersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContainersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
              }) => ContainersCompanion(
                id: id,
                name: name,
                weight: weight,
                unit: unit,
                thumbnail: thumbnail,
                hidden: hidden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double weight,
                Value<String> unit = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
              }) => ContainersCompanion.insert(
                id: id,
                name: name,
                weight: weight,
                unit: unit,
                thumbnail: thumbnail,
                hidden: hidden,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContainersTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $ContainersTable,
      ContainerEntity,
      $$ContainersTableFilterComposer,
      $$ContainersTableOrderingComposer,
      $$ContainersTableAnnotationComposer,
      $$ContainersTableCreateCompanionBuilder,
      $$ContainersTableUpdateCompanionBuilder,
      (
        ContainerEntity,
        BaseReferences<_$LiveDatabase, $ContainersTable, ContainerEntity>,
      ),
      ContainerEntity,
      PrefetchHooks Function()
    >;
typedef $$FoodBarcodesTableCreateCompanionBuilder =
    FoodBarcodesCompanion Function({
      Value<int> id,
      required int foodId,
      required String barcode,
    });
typedef $$FoodBarcodesTableUpdateCompanionBuilder =
    FoodBarcodesCompanion Function({
      Value<int> id,
      Value<int> foodId,
      Value<String> barcode,
    });

final class $$FoodBarcodesTableReferences
    extends BaseReferences<_$LiveDatabase, $FoodBarcodesTable, FoodBarcode> {
  $$FoodBarcodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _foodIdTable(_$LiveDatabase db) => db.foods.createAlias(
    $_aliasNameGenerator(db.foodBarcodes.foodId, db.foods.id),
  );

  $$FoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<int>('food_id')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FoodBarcodesTableFilterComposer
    extends Composer<_$LiveDatabase, $FoodBarcodesTable> {
  $$FoodBarcodesTableFilterComposer({
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

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodBarcodesTableOrderingComposer
    extends Composer<_$LiveDatabase, $FoodBarcodesTable> {
  $$FoodBarcodesTableOrderingComposer({
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

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodBarcodesTableAnnotationComposer
    extends Composer<_$LiveDatabase, $FoodBarcodesTable> {
  $$FoodBarcodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodBarcodesTableTableManager
    extends
        RootTableManager<
          _$LiveDatabase,
          $FoodBarcodesTable,
          FoodBarcode,
          $$FoodBarcodesTableFilterComposer,
          $$FoodBarcodesTableOrderingComposer,
          $$FoodBarcodesTableAnnotationComposer,
          $$FoodBarcodesTableCreateCompanionBuilder,
          $$FoodBarcodesTableUpdateCompanionBuilder,
          (FoodBarcode, $$FoodBarcodesTableReferences),
          FoodBarcode,
          PrefetchHooks Function({bool foodId})
        > {
  $$FoodBarcodesTableTableManager(_$LiveDatabase db, $FoodBarcodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodBarcodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodBarcodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodBarcodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> foodId = const Value.absent(),
                Value<String> barcode = const Value.absent(),
              }) => FoodBarcodesCompanion(
                id: id,
                foodId: foodId,
                barcode: barcode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int foodId,
                required String barcode,
              }) => FoodBarcodesCompanion.insert(
                id: id,
                foodId: foodId,
                barcode: barcode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoodBarcodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false}) {
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
                    if (foodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.foodId,
                                referencedTable: $$FoodBarcodesTableReferences
                                    ._foodIdTable(db),
                                referencedColumn: $$FoodBarcodesTableReferences
                                    ._foodIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$FoodBarcodesTableProcessedTableManager =
    ProcessedTableManager<
      _$LiveDatabase,
      $FoodBarcodesTable,
      FoodBarcode,
      $$FoodBarcodesTableFilterComposer,
      $$FoodBarcodesTableOrderingComposer,
      $$FoodBarcodesTableAnnotationComposer,
      $$FoodBarcodesTableCreateCompanionBuilder,
      $$FoodBarcodesTableUpdateCompanionBuilder,
      (FoodBarcode, $$FoodBarcodesTableReferences),
      FoodBarcode,
      PrefetchHooks Function({bool foodId})
    >;

class $LiveDatabaseManager {
  final _$LiveDatabase _db;
  $LiveDatabaseManager(this._db);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$FoodPortionsTableTableManager get foodPortions =>
      $$FoodPortionsTableTableManager(_db, _db.foodPortions);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeItemsTableTableManager get recipeItems =>
      $$RecipeItemsTableTableManager(_db, _db.recipeItems);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecipeCategoryLinksTableTableManager get recipeCategoryLinks =>
      $$RecipeCategoryLinksTableTableManager(_db, _db.recipeCategoryLinks);
  $$LoggedPortionsTableTableManager get loggedPortions =>
      $$LoggedPortionsTableTableManager(_db, _db.loggedPortions);
  $$WeightsTableTableManager get weights =>
      $$WeightsTableTableManager(_db, _db.weights);
  $$ContainersTableTableManager get containers =>
      $$ContainersTableTableManager(_db, _db.containers);
  $$FoodBarcodesTableTableManager get foodBarcodes =>
      $$FoodBarcodesTableTableManager(_db, _db.foodBarcodes);
}
