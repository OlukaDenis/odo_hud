// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_config_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetThemeConfigRecordCollection on Isar {
  IsarCollection<ThemeConfigRecord> get themeConfigRecords => this.collection();
}

const ThemeConfigRecordSchema = CollectionSchema(
  name: r'ThemeConfigRecord',
  id: -4027859691625913898,
  properties: {
    r'backgroundColorValue': PropertySchema(
      id: 0,
      name: r'backgroundColorValue',
      type: IsarType.long,
    ),
    r'cardBackgroundColor': PropertySchema(
      id: 1,
      name: r'cardBackgroundColor',
      type: IsarType.long,
    ),
    r'cardBorderColor': PropertySchema(
      id: 2,
      name: r'cardBorderColor',
      type: IsarType.long,
    ),
    r'cardLabelColor': PropertySchema(
      id: 3,
      name: r'cardLabelColor',
      type: IsarType.long,
    ),
    r'cardValueColor': PropertySchema(
      id: 4,
      name: r'cardValueColor',
      type: IsarType.long,
    ),
    r'criticalThresholdKmh': PropertySchema(
      id: 5,
      name: r'criticalThresholdKmh',
      type: IsarType.double,
    ),
    r'isMetric': PropertySchema(
      id: 6,
      name: r'isMetric',
      type: IsarType.bool,
    ),
    r'onboardingCompleted': PropertySchema(
      id: 7,
      name: r'onboardingCompleted',
      type: IsarType.bool,
    ),
    r'speedColorCritical': PropertySchema(
      id: 8,
      name: r'speedColorCritical',
      type: IsarType.long,
    ),
    r'speedColorNormal': PropertySchema(
      id: 9,
      name: r'speedColorNormal',
      type: IsarType.long,
    ),
    r'speedColorWarning': PropertySchema(
      id: 10,
      name: r'speedColorWarning',
      type: IsarType.long,
    ),
    r'speedFontFamily': PropertySchema(
      id: 11,
      name: r'speedFontFamily',
      type: IsarType.string,
    ),
    r'telemetryFontFamily': PropertySchema(
      id: 12,
      name: r'telemetryFontFamily',
      type: IsarType.string,
    ),
    r'warningThresholdKmh': PropertySchema(
      id: 13,
      name: r'warningThresholdKmh',
      type: IsarType.double,
    )
  },
  estimateSize: _themeConfigRecordEstimateSize,
  serialize: _themeConfigRecordSerialize,
  deserialize: _themeConfigRecordDeserialize,
  deserializeProp: _themeConfigRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _themeConfigRecordGetId,
  getLinks: _themeConfigRecordGetLinks,
  attach: _themeConfigRecordAttach,
  version: '3.1.0+1',
);

int _themeConfigRecordEstimateSize(
  ThemeConfigRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.speedFontFamily.length * 3;
  bytesCount += 3 + object.telemetryFontFamily.length * 3;
  return bytesCount;
}

void _themeConfigRecordSerialize(
  ThemeConfigRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.backgroundColorValue);
  writer.writeLong(offsets[1], object.cardBackgroundColor);
  writer.writeLong(offsets[2], object.cardBorderColor);
  writer.writeLong(offsets[3], object.cardLabelColor);
  writer.writeLong(offsets[4], object.cardValueColor);
  writer.writeDouble(offsets[5], object.criticalThresholdKmh);
  writer.writeBool(offsets[6], object.isMetric);
  writer.writeBool(offsets[7], object.onboardingCompleted);
  writer.writeLong(offsets[8], object.speedColorCritical);
  writer.writeLong(offsets[9], object.speedColorNormal);
  writer.writeLong(offsets[10], object.speedColorWarning);
  writer.writeString(offsets[11], object.speedFontFamily);
  writer.writeString(offsets[12], object.telemetryFontFamily);
  writer.writeDouble(offsets[13], object.warningThresholdKmh);
}

ThemeConfigRecord _themeConfigRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ThemeConfigRecord();
  object.backgroundColorValue = reader.readLong(offsets[0]);
  object.cardBackgroundColor = reader.readLong(offsets[1]);
  object.cardBorderColor = reader.readLong(offsets[2]);
  object.cardLabelColor = reader.readLong(offsets[3]);
  object.cardValueColor = reader.readLong(offsets[4]);
  object.criticalThresholdKmh = reader.readDouble(offsets[5]);
  object.id = id;
  object.isMetric = reader.readBool(offsets[6]);
  object.onboardingCompleted = reader.readBool(offsets[7]);
  object.speedColorCritical = reader.readLong(offsets[8]);
  object.speedColorNormal = reader.readLong(offsets[9]);
  object.speedColorWarning = reader.readLong(offsets[10]);
  object.speedFontFamily = reader.readString(offsets[11]);
  object.telemetryFontFamily = reader.readString(offsets[12]);
  object.warningThresholdKmh = reader.readDouble(offsets[13]);
  return object;
}

P _themeConfigRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _themeConfigRecordGetId(ThemeConfigRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _themeConfigRecordGetLinks(
    ThemeConfigRecord object) {
  return [];
}

void _themeConfigRecordAttach(
    IsarCollection<dynamic> col, Id id, ThemeConfigRecord object) {
  object.id = id;
}

extension ThemeConfigRecordQueryWhereSort
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QWhere> {
  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ThemeConfigRecordQueryWhere
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QWhereClause> {
  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ThemeConfigRecordQueryFilter
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QFilterCondition> {
  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      backgroundColorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backgroundColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      backgroundColorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backgroundColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      backgroundColorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backgroundColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      backgroundColorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backgroundColorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardBackgroundColorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardBackgroundColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardBackgroundColorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardBackgroundColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardBackgroundColorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardBackgroundColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardBackgroundColorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardBackgroundColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardBorderColorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardBorderColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardBorderColorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardBorderColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardBorderColorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardBorderColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardBorderColorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardBorderColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardLabelColorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardLabelColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardLabelColorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardLabelColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardLabelColorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardLabelColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardLabelColorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardLabelColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardValueColorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardValueColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardValueColorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardValueColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardValueColorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardValueColor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      cardValueColorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardValueColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      criticalThresholdKmhEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criticalThresholdKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      criticalThresholdKmhGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'criticalThresholdKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      criticalThresholdKmhLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'criticalThresholdKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      criticalThresholdKmhBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'criticalThresholdKmh',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      isMetricEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMetric',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      onboardingCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboardingCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorCriticalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedColorCritical',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorCriticalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedColorCritical',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorCriticalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedColorCritical',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorCriticalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedColorCritical',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorNormalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedColorNormal',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorNormalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedColorNormal',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorNormalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedColorNormal',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorNormalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedColorNormal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorWarningEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedColorWarning',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorWarningGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedColorWarning',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorWarningLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedColorWarning',
        value: value,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedColorWarningBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedColorWarning',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedFontFamily',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'speedFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'speedFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'speedFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'speedFontFamily',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      speedFontFamilyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'speedFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telemetryFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'telemetryFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'telemetryFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'telemetryFontFamily',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'telemetryFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'telemetryFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'telemetryFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'telemetryFontFamily',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telemetryFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      telemetryFontFamilyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'telemetryFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      warningThresholdKmhEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'warningThresholdKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      warningThresholdKmhGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'warningThresholdKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      warningThresholdKmhLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'warningThresholdKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterFilterCondition>
      warningThresholdKmhBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'warningThresholdKmh',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ThemeConfigRecordQueryObject
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QFilterCondition> {}

extension ThemeConfigRecordQueryLinks
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QFilterCondition> {}

extension ThemeConfigRecordQuerySortBy
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QSortBy> {
  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByBackgroundColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCardBackgroundColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBackgroundColor', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCardBackgroundColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBackgroundColor', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCardBorderColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBorderColor', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCardBorderColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBorderColor', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCardLabelColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardLabelColor', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCardLabelColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardLabelColor', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCardValueColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardValueColor', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCardValueColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardValueColor', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCriticalThresholdKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criticalThresholdKmh', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByCriticalThresholdKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criticalThresholdKmh', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByIsMetric() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetric', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByIsMetricDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetric', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortBySpeedColorCritical() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorCritical', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortBySpeedColorCriticalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorCritical', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortBySpeedColorNormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorNormal', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortBySpeedColorNormalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorNormal', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortBySpeedColorWarning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorWarning', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortBySpeedColorWarningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorWarning', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortBySpeedFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedFontFamily', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortBySpeedFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedFontFamily', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByTelemetryFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telemetryFontFamily', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByTelemetryFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telemetryFontFamily', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByWarningThresholdKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningThresholdKmh', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      sortByWarningThresholdKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningThresholdKmh', Sort.desc);
    });
  }
}

extension ThemeConfigRecordQuerySortThenBy
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QSortThenBy> {
  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByBackgroundColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCardBackgroundColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBackgroundColor', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCardBackgroundColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBackgroundColor', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCardBorderColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBorderColor', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCardBorderColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBorderColor', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCardLabelColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardLabelColor', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCardLabelColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardLabelColor', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCardValueColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardValueColor', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCardValueColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardValueColor', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCriticalThresholdKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criticalThresholdKmh', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByCriticalThresholdKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criticalThresholdKmh', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByIsMetric() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetric', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByIsMetricDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetric', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenBySpeedColorCritical() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorCritical', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenBySpeedColorCriticalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorCritical', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenBySpeedColorNormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorNormal', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenBySpeedColorNormalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorNormal', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenBySpeedColorWarning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorWarning', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenBySpeedColorWarningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedColorWarning', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenBySpeedFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedFontFamily', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenBySpeedFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedFontFamily', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByTelemetryFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telemetryFontFamily', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByTelemetryFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telemetryFontFamily', Sort.desc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByWarningThresholdKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningThresholdKmh', Sort.asc);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QAfterSortBy>
      thenByWarningThresholdKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningThresholdKmh', Sort.desc);
    });
  }
}

extension ThemeConfigRecordQueryWhereDistinct
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct> {
  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundColorValue');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByCardBackgroundColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardBackgroundColor');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByCardBorderColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardBorderColor');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByCardLabelColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardLabelColor');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByCardValueColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardValueColor');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByCriticalThresholdKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'criticalThresholdKmh');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByIsMetric() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMetric');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingCompleted');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctBySpeedColorCritical() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedColorCritical');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctBySpeedColorNormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedColorNormal');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctBySpeedColorWarning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedColorWarning');
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctBySpeedFontFamily({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedFontFamily',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByTelemetryFontFamily({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'telemetryFontFamily',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QDistinct>
      distinctByWarningThresholdKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'warningThresholdKmh');
    });
  }
}

extension ThemeConfigRecordQueryProperty
    on QueryBuilder<ThemeConfigRecord, ThemeConfigRecord, QQueryProperty> {
  QueryBuilder<ThemeConfigRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ThemeConfigRecord, int, QQueryOperations>
      backgroundColorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundColorValue');
    });
  }

  QueryBuilder<ThemeConfigRecord, int, QQueryOperations>
      cardBackgroundColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardBackgroundColor');
    });
  }

  QueryBuilder<ThemeConfigRecord, int, QQueryOperations>
      cardBorderColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardBorderColor');
    });
  }

  QueryBuilder<ThemeConfigRecord, int, QQueryOperations>
      cardLabelColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardLabelColor');
    });
  }

  QueryBuilder<ThemeConfigRecord, int, QQueryOperations>
      cardValueColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardValueColor');
    });
  }

  QueryBuilder<ThemeConfigRecord, double, QQueryOperations>
      criticalThresholdKmhProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'criticalThresholdKmh');
    });
  }

  QueryBuilder<ThemeConfigRecord, bool, QQueryOperations> isMetricProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMetric');
    });
  }

  QueryBuilder<ThemeConfigRecord, bool, QQueryOperations>
      onboardingCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingCompleted');
    });
  }

  QueryBuilder<ThemeConfigRecord, int, QQueryOperations>
      speedColorCriticalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedColorCritical');
    });
  }

  QueryBuilder<ThemeConfigRecord, int, QQueryOperations>
      speedColorNormalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedColorNormal');
    });
  }

  QueryBuilder<ThemeConfigRecord, int, QQueryOperations>
      speedColorWarningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedColorWarning');
    });
  }

  QueryBuilder<ThemeConfigRecord, String, QQueryOperations>
      speedFontFamilyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedFontFamily');
    });
  }

  QueryBuilder<ThemeConfigRecord, String, QQueryOperations>
      telemetryFontFamilyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'telemetryFontFamily');
    });
  }

  QueryBuilder<ThemeConfigRecord, double, QQueryOperations>
      warningThresholdKmhProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'warningThresholdKmh');
    });
  }
}
