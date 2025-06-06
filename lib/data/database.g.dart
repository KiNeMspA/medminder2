// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _concentrationMeta = const VerificationMeta(
    'concentration',
  );
  @override
  late final GeneratedColumn<double> concentration = GeneratedColumn<double>(
    'concentration',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concentrationUnitMeta = const VerificationMeta(
    'concentrationUnit',
  );
  @override
  late final GeneratedColumn<String> concentrationUnit =
      GeneratedColumn<String>(
        'concentration_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stockQuantityMeta = const VerificationMeta(
    'stockQuantity',
  );
  @override
  late final GeneratedColumn<double> stockQuantity = GeneratedColumn<double>(
    'stock_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    concentration,
    concentrationUnit,
    stockQuantity,
    form,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
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
    if (data.containsKey('concentration')) {
      context.handle(
        _concentrationMeta,
        concentration.isAcceptableOrUnknown(
          data['concentration']!,
          _concentrationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_concentrationMeta);
    }
    if (data.containsKey('concentration_unit')) {
      context.handle(
        _concentrationUnitMeta,
        concentrationUnit.isAcceptableOrUnknown(
          data['concentration_unit']!,
          _concentrationUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_concentrationUnitMeta);
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
        _stockQuantityMeta,
        stockQuantity.isAcceptableOrUnknown(
          data['stock_quantity']!,
          _stockQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockQuantityMeta);
    }
    if (data.containsKey('form')) {
      context.handle(
        _formMeta,
        form.isAcceptableOrUnknown(data['form']!, _formMeta),
      );
    } else if (isInserting) {
      context.missing(_formMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      concentration: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}concentration'],
      )!,
      concentrationUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concentration_unit'],
      )!,
      stockQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_quantity'],
      )!,
      form: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final String name;
  final double concentration;
  final String concentrationUnit;
  final double stockQuantity;
  final String form;
  const Medication({
    required this.id,
    required this.name,
    required this.concentration,
    required this.concentrationUnit,
    required this.stockQuantity,
    required this.form,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['concentration'] = Variable<double>(concentration);
    map['concentration_unit'] = Variable<String>(concentrationUnit);
    map['stock_quantity'] = Variable<double>(stockQuantity);
    map['form'] = Variable<String>(form);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      concentration: Value(concentration),
      concentrationUnit: Value(concentrationUnit),
      stockQuantity: Value(stockQuantity),
      form: Value(form),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      concentration: serializer.fromJson<double>(json['concentration']),
      concentrationUnit: serializer.fromJson<String>(json['concentrationUnit']),
      stockQuantity: serializer.fromJson<double>(json['stockQuantity']),
      form: serializer.fromJson<String>(json['form']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'concentration': serializer.toJson<double>(concentration),
      'concentrationUnit': serializer.toJson<String>(concentrationUnit),
      'stockQuantity': serializer.toJson<double>(stockQuantity),
      'form': serializer.toJson<String>(form),
    };
  }

  Medication copyWith({
    int? id,
    String? name,
    double? concentration,
    String? concentrationUnit,
    double? stockQuantity,
    String? form,
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    concentration: concentration ?? this.concentration,
    concentrationUnit: concentrationUnit ?? this.concentrationUnit,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    form: form ?? this.form,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      concentration: data.concentration.present
          ? data.concentration.value
          : this.concentration,
      concentrationUnit: data.concentrationUnit.present
          ? data.concentrationUnit.value
          : this.concentrationUnit,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      form: data.form.present ? data.form.value : this.form,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('concentration: $concentration, ')
          ..write('concentrationUnit: $concentrationUnit, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('form: $form')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    concentration,
    concentrationUnit,
    stockQuantity,
    form,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.concentration == this.concentration &&
          other.concentrationUnit == this.concentrationUnit &&
          other.stockQuantity == this.stockQuantity &&
          other.form == this.form);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> concentration;
  final Value<String> concentrationUnit;
  final Value<double> stockQuantity;
  final Value<String> form;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.concentration = const Value.absent(),
    this.concentrationUnit = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.form = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double concentration,
    required String concentrationUnit,
    required double stockQuantity,
    required String form,
  }) : name = Value(name),
       concentration = Value(concentration),
       concentrationUnit = Value(concentrationUnit),
       stockQuantity = Value(stockQuantity),
       form = Value(form);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? concentration,
    Expression<String>? concentrationUnit,
    Expression<double>? stockQuantity,
    Expression<String>? form,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (concentration != null) 'concentration': concentration,
      if (concentrationUnit != null) 'concentration_unit': concentrationUnit,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (form != null) 'form': form,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? concentration,
    Value<String>? concentrationUnit,
    Value<double>? stockQuantity,
    Value<String>? form,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      concentration: concentration ?? this.concentration,
      concentrationUnit: concentrationUnit ?? this.concentrationUnit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      form: form ?? this.form,
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
    if (concentration.present) {
      map['concentration'] = Variable<double>(concentration.value);
    }
    if (concentrationUnit.present) {
      map['concentration_unit'] = Variable<String>(concentrationUnit.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<double>(stockQuantity.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('concentration: $concentration, ')
          ..write('concentrationUnit: $concentrationUnit, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('form: $form')
          ..write(')'))
        .toString();
  }
}

class $DosesTable extends Doses with TableInfo<$DosesTable, Dose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DosesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
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
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    amount,
    unit,
    weight,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dose> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dose(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
    );
  }

  @override
  $DosesTable createAlias(String alias) {
    return $DosesTable(attachedDatabase, alias);
  }
}

class Dose extends DataClass implements Insertable<Dose> {
  final int id;
  final int medicationId;
  final double amount;
  final String unit;
  final double weight;
  final String? name;
  const Dose({
    required this.id,
    required this.medicationId,
    required this.amount,
    required this.unit,
    required this.weight,
    this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['amount'] = Variable<double>(amount);
    map['unit'] = Variable<String>(unit);
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  DosesCompanion toCompanion(bool nullToAbsent) {
    return DosesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      amount: Value(amount),
      unit: Value(unit),
      weight: Value(weight),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
    );
  }

  factory Dose.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dose(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      amount: serializer.fromJson<double>(json['amount']),
      unit: serializer.fromJson<String>(json['unit']),
      weight: serializer.fromJson<double>(json['weight']),
      name: serializer.fromJson<String?>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'amount': serializer.toJson<double>(amount),
      'unit': serializer.toJson<String>(unit),
      'weight': serializer.toJson<double>(weight),
      'name': serializer.toJson<String?>(name),
    };
  }

  Dose copyWith({
    int? id,
    int? medicationId,
    double? amount,
    String? unit,
    double? weight,
    Value<String?> name = const Value.absent(),
  }) => Dose(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    amount: amount ?? this.amount,
    unit: unit ?? this.unit,
    weight: weight ?? this.weight,
    name: name.present ? name.value : this.name,
  );
  Dose copyWithCompanion(DosesCompanion data) {
    return Dose(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      amount: data.amount.present ? data.amount.value : this.amount,
      unit: data.unit.present ? data.unit.value : this.unit,
      weight: data.weight.present ? data.weight.value : this.weight,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dose(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('weight: $weight, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, medicationId, amount, unit, weight, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dose &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.amount == this.amount &&
          other.unit == this.unit &&
          other.weight == this.weight &&
          other.name == this.name);
}

class DosesCompanion extends UpdateCompanion<Dose> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<double> amount;
  final Value<String> unit;
  final Value<double> weight;
  final Value<String?> name;
  const DosesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.amount = const Value.absent(),
    this.unit = const Value.absent(),
    this.weight = const Value.absent(),
    this.name = const Value.absent(),
  });
  DosesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required double amount,
    required String unit,
    this.weight = const Value.absent(),
    this.name = const Value.absent(),
  }) : medicationId = Value(medicationId),
       amount = Value(amount),
       unit = Value(unit);
  static Insertable<Dose> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<double>? amount,
    Expression<String>? unit,
    Expression<double>? weight,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (weight != null) 'weight': weight,
      if (name != null) 'name': name,
    });
  }

  DosesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<double>? amount,
    Value<String>? unit,
    Value<double>? weight,
    Value<String?>? name,
  }) {
    return DosesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DosesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('weight: $weight, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _doseIdMeta = const VerificationMeta('doseId');
  @override
  late final GeneratedColumn<int> doseId = GeneratedColumn<int>(
    'dose_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES doses (id)',
    ),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> days =
      GeneratedColumn<String>(
        'days',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($SchedulesTable.$converterdays);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<String> notificationId = GeneratedColumn<String>(
    'notification_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    doseId,
    frequency,
    days,
    time,
    name,
    notificationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Schedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dose_id')) {
      context.handle(
        _doseIdMeta,
        doseId.isAcceptableOrUnknown(data['dose_id']!, _doseIdMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      doseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dose_id'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      days: $SchedulesTable.$converterdays.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}days'],
        )!,
      ),
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_id'],
      ),
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterdays =
      const StringListConverter();
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final int? doseId;
  final String frequency;
  final List<String> days;
  final DateTime time;
  final String name;
  final String? notificationId;
  const Schedule({
    required this.id,
    this.doseId,
    required this.frequency,
    required this.days,
    required this.time,
    required this.name,
    this.notificationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || doseId != null) {
      map['dose_id'] = Variable<int>(doseId);
    }
    map['frequency'] = Variable<String>(frequency);
    {
      map['days'] = Variable<String>(
        $SchedulesTable.$converterdays.toSql(days),
      );
    }
    map['time'] = Variable<DateTime>(time);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<String>(notificationId);
    }
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      doseId: doseId == null && nullToAbsent
          ? const Value.absent()
          : Value(doseId),
      frequency: Value(frequency),
      days: Value(days),
      time: Value(time),
      name: Value(name),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
    );
  }

  factory Schedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      doseId: serializer.fromJson<int?>(json['doseId']),
      frequency: serializer.fromJson<String>(json['frequency']),
      days: serializer.fromJson<List<String>>(json['days']),
      time: serializer.fromJson<DateTime>(json['time']),
      name: serializer.fromJson<String>(json['name']),
      notificationId: serializer.fromJson<String?>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'doseId': serializer.toJson<int?>(doseId),
      'frequency': serializer.toJson<String>(frequency),
      'days': serializer.toJson<List<String>>(days),
      'time': serializer.toJson<DateTime>(time),
      'name': serializer.toJson<String>(name),
      'notificationId': serializer.toJson<String?>(notificationId),
    };
  }

  Schedule copyWith({
    int? id,
    Value<int?> doseId = const Value.absent(),
    String? frequency,
    List<String>? days,
    DateTime? time,
    String? name,
    Value<String?> notificationId = const Value.absent(),
  }) => Schedule(
    id: id ?? this.id,
    doseId: doseId.present ? doseId.value : this.doseId,
    frequency: frequency ?? this.frequency,
    days: days ?? this.days,
    time: time ?? this.time,
    name: name ?? this.name,
    notificationId: notificationId.present
        ? notificationId.value
        : this.notificationId,
  );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      doseId: data.doseId.present ? data.doseId.value : this.doseId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      days: data.days.present ? data.days.value : this.days,
      time: data.time.present ? data.time.value : this.time,
      name: data.name.present ? data.name.value : this.name,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('doseId: $doseId, ')
          ..write('frequency: $frequency, ')
          ..write('days: $days, ')
          ..write('time: $time, ')
          ..write('name: $name, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, doseId, frequency, days, time, name, notificationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.doseId == this.doseId &&
          other.frequency == this.frequency &&
          other.days == this.days &&
          other.time == this.time &&
          other.name == this.name &&
          other.notificationId == this.notificationId);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<int?> doseId;
  final Value<String> frequency;
  final Value<List<String>> days;
  final Value<DateTime> time;
  final Value<String> name;
  final Value<String?> notificationId;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.doseId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.days = const Value.absent(),
    this.time = const Value.absent(),
    this.name = const Value.absent(),
    this.notificationId = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    this.doseId = const Value.absent(),
    required String frequency,
    required List<String> days,
    required DateTime time,
    this.name = const Value.absent(),
    this.notificationId = const Value.absent(),
  }) : frequency = Value(frequency),
       days = Value(days),
       time = Value(time);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<int>? doseId,
    Expression<String>? frequency,
    Expression<String>? days,
    Expression<DateTime>? time,
    Expression<String>? name,
    Expression<String>? notificationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (doseId != null) 'dose_id': doseId,
      if (frequency != null) 'frequency': frequency,
      if (days != null) 'days': days,
      if (time != null) 'time': time,
      if (name != null) 'name': name,
      if (notificationId != null) 'notification_id': notificationId,
    });
  }

  SchedulesCompanion copyWith({
    Value<int>? id,
    Value<int?>? doseId,
    Value<String>? frequency,
    Value<List<String>>? days,
    Value<DateTime>? time,
    Value<String>? name,
    Value<String?>? notificationId,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      doseId: doseId ?? this.doseId,
      frequency: frequency ?? this.frequency,
      days: days ?? this.days,
      time: time ?? this.time,
      name: name ?? this.name,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (doseId.present) {
      map['dose_id'] = Variable<int>(doseId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (days.present) {
      map['days'] = Variable<String>(
        $SchedulesTable.$converterdays.toSql(days.value),
      );
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<String>(notificationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('doseId: $doseId, ')
          ..write('frequency: $frequency, ')
          ..write('days: $days, ')
          ..write('time: $time, ')
          ..write('name: $name, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }
}

class $DoseHistoryTable extends DoseHistory
    with TableInfo<$DoseHistoryTable, DoseHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseHistoryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _doseIdMeta = const VerificationMeta('doseId');
  @override
  late final GeneratedColumn<int> doseId = GeneratedColumn<int>(
    'dose_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES doses (id)',
    ),
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, doseId, takenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoseHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dose_id')) {
      context.handle(
        _doseIdMeta,
        doseId.isAcceptableOrUnknown(data['dose_id']!, _doseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_doseIdMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoseHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      doseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dose_id'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
    );
  }

  @override
  $DoseHistoryTable createAlias(String alias) {
    return $DoseHistoryTable(attachedDatabase, alias);
  }
}

class DoseHistoryData extends DataClass implements Insertable<DoseHistoryData> {
  final int id;
  final int doseId;
  final DateTime takenAt;
  const DoseHistoryData({
    required this.id,
    required this.doseId,
    required this.takenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dose_id'] = Variable<int>(doseId);
    map['taken_at'] = Variable<DateTime>(takenAt);
    return map;
  }

  DoseHistoryCompanion toCompanion(bool nullToAbsent) {
    return DoseHistoryCompanion(
      id: Value(id),
      doseId: Value(doseId),
      takenAt: Value(takenAt),
    );
  }

  factory DoseHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseHistoryData(
      id: serializer.fromJson<int>(json['id']),
      doseId: serializer.fromJson<int>(json['doseId']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'doseId': serializer.toJson<int>(doseId),
      'takenAt': serializer.toJson<DateTime>(takenAt),
    };
  }

  DoseHistoryData copyWith({int? id, int? doseId, DateTime? takenAt}) =>
      DoseHistoryData(
        id: id ?? this.id,
        doseId: doseId ?? this.doseId,
        takenAt: takenAt ?? this.takenAt,
      );
  DoseHistoryData copyWithCompanion(DoseHistoryCompanion data) {
    return DoseHistoryData(
      id: data.id.present ? data.id.value : this.id,
      doseId: data.doseId.present ? data.doseId.value : this.doseId,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseHistoryData(')
          ..write('id: $id, ')
          ..write('doseId: $doseId, ')
          ..write('takenAt: $takenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, doseId, takenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseHistoryData &&
          other.id == this.id &&
          other.doseId == this.doseId &&
          other.takenAt == this.takenAt);
}

class DoseHistoryCompanion extends UpdateCompanion<DoseHistoryData> {
  final Value<int> id;
  final Value<int> doseId;
  final Value<DateTime> takenAt;
  const DoseHistoryCompanion({
    this.id = const Value.absent(),
    this.doseId = const Value.absent(),
    this.takenAt = const Value.absent(),
  });
  DoseHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int doseId,
    required DateTime takenAt,
  }) : doseId = Value(doseId),
       takenAt = Value(takenAt);
  static Insertable<DoseHistoryData> custom({
    Expression<int>? id,
    Expression<int>? doseId,
    Expression<DateTime>? takenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (doseId != null) 'dose_id': doseId,
      if (takenAt != null) 'taken_at': takenAt,
    });
  }

  DoseHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? doseId,
    Value<DateTime>? takenAt,
  }) {
    return DoseHistoryCompanion(
      id: id ?? this.id,
      doseId: doseId ?? this.doseId,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (doseId.present) {
      map['dose_id'] = Variable<int>(doseId.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseHistoryCompanion(')
          ..write('id: $id, ')
          ..write('doseId: $doseId, ')
          ..write('takenAt: $takenAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $DosesTable doses = $DosesTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $DoseHistoryTable doseHistory = $DoseHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medications,
    doses,
    schedules,
    doseHistory,
  ];
}

typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required String name,
      required double concentration,
      required String concentrationUnit,
      required double stockQuantity,
      required String form,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> concentration,
      Value<String> concentrationUnit,
      Value<double> stockQuantity,
      Value<String> form,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DosesTable, List<Dose>> _dosesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.doses,
    aliasName: $_aliasNameGenerator(db.medications.id, db.doses.medicationId),
  );

  $$DosesTableProcessedTableManager get dosesRefs {
    final manager = $$DosesTableTableManager(
      $_db,
      $_db.doses,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dosesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
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

  ColumnFilters<double> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concentrationUnit => $composableBuilder(
    column: $table.concentrationUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dosesRefs(
    Expression<bool> Function($$DosesTableFilterComposer f) f,
  ) {
    final $$DosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableFilterComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
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

  ColumnOrderings<double> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concentrationUnit => $composableBuilder(
    column: $table.concentrationUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
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

  GeneratedColumn<double> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concentrationUnit => $composableBuilder(
    column: $table.concentrationUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  Expression<T> dosesRefs<T extends Object>(
    Expression<T> Function($$DosesTableAnnotationComposer a) f,
  ) {
    final $$DosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableAnnotationComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({bool dosesRefs})
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> concentration = const Value.absent(),
                Value<String> concentrationUnit = const Value.absent(),
                Value<double> stockQuantity = const Value.absent(),
                Value<String> form = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                concentration: concentration,
                concentrationUnit: concentrationUnit,
                stockQuantity: stockQuantity,
                form: form,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double concentration,
                required String concentrationUnit,
                required double stockQuantity,
                required String form,
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                concentration: concentration,
                concentrationUnit: concentrationUnit,
                stockQuantity: stockQuantity,
                form: form,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dosesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dosesRefs) db.doses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dosesRefs)
                    await $_getPrefetchedData<
                      Medication,
                      $MedicationsTable,
                      Dose
                    >(
                      currentTable: table,
                      referencedTable: $$MedicationsTableReferences
                          ._dosesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MedicationsTableReferences(db, table, p0).dosesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.medicationId == item.id,
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

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({bool dosesRefs})
    >;
typedef $$DosesTableCreateCompanionBuilder =
    DosesCompanion Function({
      Value<int> id,
      required int medicationId,
      required double amount,
      required String unit,
      Value<double> weight,
      Value<String?> name,
    });
typedef $$DosesTableUpdateCompanionBuilder =
    DosesCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<double> amount,
      Value<String> unit,
      Value<double> weight,
      Value<String?> name,
    });

final class $$DosesTableReferences
    extends BaseReferences<_$AppDatabase, $DosesTable, Dose> {
  $$DosesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(db.doses.medicationId, db.medications.id),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SchedulesTable, List<Schedule>>
  _schedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.schedules,
    aliasName: $_aliasNameGenerator(db.doses.id, db.schedules.doseId),
  );

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager(
      $_db,
      $_db.schedules,
    ).filter((f) => f.doseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DoseHistoryTable, List<DoseHistoryData>>
  _doseHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.doseHistory,
    aliasName: $_aliasNameGenerator(db.doses.id, db.doseHistory.doseId),
  );

  $$DoseHistoryTableProcessedTableManager get doseHistoryRefs {
    final manager = $$DoseHistoryTableTableManager(
      $_db,
      $_db.doseHistory,
    ).filter((f) => f.doseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_doseHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DosesTableFilterComposer extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableFilterComposer({
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

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> schedulesRefs(
    Expression<bool> Function($$SchedulesTableFilterComposer f) f,
  ) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.doseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableFilterComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> doseHistoryRefs(
    Expression<bool> Function($$DoseHistoryTableFilterComposer f) f,
  ) {
    final $$DoseHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doseHistory,
      getReferencedColumn: (t) => t.doseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoseHistoryTableFilterComposer(
            $db: $db,
            $table: $db.doseHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableOrderingComposer({
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

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> schedulesRefs<T extends Object>(
    Expression<T> Function($$SchedulesTableAnnotationComposer a) f,
  ) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.doseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> doseHistoryRefs<T extends Object>(
    Expression<T> Function($$DoseHistoryTableAnnotationComposer a) f,
  ) {
    final $$DoseHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doseHistory,
      getReferencedColumn: (t) => t.doseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoseHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.doseHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DosesTable,
          Dose,
          $$DosesTableFilterComposer,
          $$DosesTableOrderingComposer,
          $$DosesTableAnnotationComposer,
          $$DosesTableCreateCompanionBuilder,
          $$DosesTableUpdateCompanionBuilder,
          (Dose, $$DosesTableReferences),
          Dose,
          PrefetchHooks Function({
            bool medicationId,
            bool schedulesRefs,
            bool doseHistoryRefs,
          })
        > {
  $$DosesTableTableManager(_$AppDatabase db, $DosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String?> name = const Value.absent(),
              }) => DosesCompanion(
                id: id,
                medicationId: medicationId,
                amount: amount,
                unit: unit,
                weight: weight,
                name: name,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required double amount,
                required String unit,
                Value<double> weight = const Value.absent(),
                Value<String?> name = const Value.absent(),
              }) => DosesCompanion.insert(
                id: id,
                medicationId: medicationId,
                amount: amount,
                unit: unit,
                weight: weight,
                name: name,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DosesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicationId = false,
                schedulesRefs = false,
                doseHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (schedulesRefs) db.schedules,
                    if (doseHistoryRefs) db.doseHistory,
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
                        if (medicationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicationId,
                                    referencedTable: $$DosesTableReferences
                                        ._medicationIdTable(db),
                                    referencedColumn: $$DosesTableReferences
                                        ._medicationIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (schedulesRefs)
                        await $_getPrefetchedData<Dose, $DosesTable, Schedule>(
                          currentTable: table,
                          referencedTable: $$DosesTableReferences
                              ._schedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DosesTableReferences(
                                db,
                                table,
                                p0,
                              ).schedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.doseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (doseHistoryRefs)
                        await $_getPrefetchedData<
                          Dose,
                          $DosesTable,
                          DoseHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$DosesTableReferences
                              ._doseHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DosesTableReferences(
                                db,
                                table,
                                p0,
                              ).doseHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.doseId == item.id,
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

typedef $$DosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DosesTable,
      Dose,
      $$DosesTableFilterComposer,
      $$DosesTableOrderingComposer,
      $$DosesTableAnnotationComposer,
      $$DosesTableCreateCompanionBuilder,
      $$DosesTableUpdateCompanionBuilder,
      (Dose, $$DosesTableReferences),
      Dose,
      PrefetchHooks Function({
        bool medicationId,
        bool schedulesRefs,
        bool doseHistoryRefs,
      })
    >;
typedef $$SchedulesTableCreateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      Value<int?> doseId,
      required String frequency,
      required List<String> days,
      required DateTime time,
      Value<String> name,
      Value<String?> notificationId,
    });
typedef $$SchedulesTableUpdateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      Value<int?> doseId,
      Value<String> frequency,
      Value<List<String>> days,
      Value<DateTime> time,
      Value<String> name,
      Value<String?> notificationId,
    });

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, Schedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DosesTable _doseIdTable(_$AppDatabase db) => db.doses.createAlias(
    $_aliasNameGenerator(db.schedules.doseId, db.doses.id),
  );

  $$DosesTableProcessedTableManager? get doseId {
    final $_column = $_itemColumn<int>('dose_id');
    if ($_column == null) return null;
    final manager = $$DosesTableTableManager(
      $_db,
      $_db.doses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_doseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
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

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get days =>
      $composableBuilder(
        column: $table.days,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  $$DosesTableFilterComposer get doseId {
    final $$DosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableFilterComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
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

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  $$DosesTableOrderingComposer get doseId {
    final $$DosesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableOrderingComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  $$DosesTableAnnotationComposer get doseId {
    final $$DosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableAnnotationComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          Schedule,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (Schedule, $$SchedulesTableReferences),
          Schedule,
          PrefetchHooks Function({bool doseId})
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> doseId = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<List<String>> days = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notificationId = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                doseId: doseId,
                frequency: frequency,
                days: days,
                time: time,
                name: name,
                notificationId: notificationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> doseId = const Value.absent(),
                required String frequency,
                required List<String> days,
                required DateTime time,
                Value<String> name = const Value.absent(),
                Value<String?> notificationId = const Value.absent(),
              }) => SchedulesCompanion.insert(
                id: id,
                doseId: doseId,
                frequency: frequency,
                days: days,
                time: time,
                name: name,
                notificationId: notificationId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({doseId = false}) {
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
                    if (doseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.doseId,
                                referencedTable: $$SchedulesTableReferences
                                    ._doseIdTable(db),
                                referencedColumn: $$SchedulesTableReferences
                                    ._doseIdTable(db)
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

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      Schedule,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (Schedule, $$SchedulesTableReferences),
      Schedule,
      PrefetchHooks Function({bool doseId})
    >;
typedef $$DoseHistoryTableCreateCompanionBuilder =
    DoseHistoryCompanion Function({
      Value<int> id,
      required int doseId,
      required DateTime takenAt,
    });
typedef $$DoseHistoryTableUpdateCompanionBuilder =
    DoseHistoryCompanion Function({
      Value<int> id,
      Value<int> doseId,
      Value<DateTime> takenAt,
    });

final class $$DoseHistoryTableReferences
    extends BaseReferences<_$AppDatabase, $DoseHistoryTable, DoseHistoryData> {
  $$DoseHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DosesTable _doseIdTable(_$AppDatabase db) => db.doses.createAlias(
    $_aliasNameGenerator(db.doseHistory.doseId, db.doses.id),
  );

  $$DosesTableProcessedTableManager get doseId {
    final $_column = $_itemColumn<int>('dose_id')!;

    final manager = $$DosesTableTableManager(
      $_db,
      $_db.doses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_doseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DoseHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableFilterComposer({
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

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DosesTableFilterComposer get doseId {
    final $$DosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableFilterComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableOrderingComposer({
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

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DosesTableOrderingComposer get doseId {
    final $$DosesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableOrderingComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  $$DosesTableAnnotationComposer get doseId {
    final $$DosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doseId,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DosesTableAnnotationComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DoseHistoryTable,
          DoseHistoryData,
          $$DoseHistoryTableFilterComposer,
          $$DoseHistoryTableOrderingComposer,
          $$DoseHistoryTableAnnotationComposer,
          $$DoseHistoryTableCreateCompanionBuilder,
          $$DoseHistoryTableUpdateCompanionBuilder,
          (DoseHistoryData, $$DoseHistoryTableReferences),
          DoseHistoryData,
          PrefetchHooks Function({bool doseId})
        > {
  $$DoseHistoryTableTableManager(_$AppDatabase db, $DoseHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoseHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoseHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoseHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> doseId = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
              }) => DoseHistoryCompanion(
                id: id,
                doseId: doseId,
                takenAt: takenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int doseId,
                required DateTime takenAt,
              }) => DoseHistoryCompanion.insert(
                id: id,
                doseId: doseId,
                takenAt: takenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DoseHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({doseId = false}) {
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
                    if (doseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.doseId,
                                referencedTable: $$DoseHistoryTableReferences
                                    ._doseIdTable(db),
                                referencedColumn: $$DoseHistoryTableReferences
                                    ._doseIdTable(db)
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

typedef $$DoseHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DoseHistoryTable,
      DoseHistoryData,
      $$DoseHistoryTableFilterComposer,
      $$DoseHistoryTableOrderingComposer,
      $$DoseHistoryTableAnnotationComposer,
      $$DoseHistoryTableCreateCompanionBuilder,
      $$DoseHistoryTableUpdateCompanionBuilder,
      (DoseHistoryData, $$DoseHistoryTableReferences),
      DoseHistoryData,
      PrefetchHooks Function({bool doseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$DosesTableTableManager get doses =>
      $$DosesTableTableManager(_db, _db.doses);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$DoseHistoryTableTableManager get doseHistory =>
      $$DoseHistoryTableTableManager(_db, _db.doseHistory);
}
