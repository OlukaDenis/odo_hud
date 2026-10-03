// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTelemetryRecordCollection on Isar {
  IsarCollection<TelemetryRecord> get telemetryRecords => this.collection();
}

const TelemetryRecordSchema = CollectionSchema(
  name: r'TelemetryRecord',
  id: -3169681680747218203,
  properties: {
    r'activeTripMeters': PropertySchema(
      id: 0,
      name: r'activeTripMeters',
      type: IsarType.double,
    ),
    r'activeTripMovingSeconds': PropertySchema(
      id: 1,
      name: r'activeTripMovingSeconds',
      type: IsarType.long,
    ),
    r'lastSavedTimestamp': PropertySchema(
      id: 2,
      name: r'lastSavedTimestamp',
      type: IsarType.dateTime,
    ),
    r'lifetimeOdometerMeters': PropertySchema(
      id: 3,
      name: r'lifetimeOdometerMeters',
      type: IsarType.double,
    ),
    r'maxSpeedKmh': PropertySchema(
      id: 4,
      name: r'maxSpeedKmh',
      type: IsarType.double,
    )
  },
  estimateSize: _telemetryRecordEstimateSize,
  serialize: _telemetryRecordSerialize,
  deserialize: _telemetryRecordDeserialize,
  deserializeProp: _telemetryRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _telemetryRecordGetId,
  getLinks: _telemetryRecordGetLinks,
  attach: _telemetryRecordAttach,
  version: '3.1.0+1',
);

int _telemetryRecordEstimateSize(
  TelemetryRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _telemetryRecordSerialize(
  TelemetryRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.activeTripMeters);
  writer.writeLong(offsets[1], object.activeTripMovingSeconds);
  writer.writeDateTime(offsets[2], object.lastSavedTimestamp);
  writer.writeDouble(offsets[3], object.lifetimeOdometerMeters);
  writer.writeDouble(offsets[4], object.maxSpeedKmh);
}

TelemetryRecord _telemetryRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TelemetryRecord();
  object.activeTripMeters = reader.readDouble(offsets[0]);
  object.activeTripMovingSeconds = reader.readLong(offsets[1]);
  object.id = id;
  object.lastSavedTimestamp = reader.readDateTime(offsets[2]);
  object.lifetimeOdometerMeters = reader.readDouble(offsets[3]);
  object.maxSpeedKmh = reader.readDouble(offsets[4]);
  return object;
}

P _telemetryRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _telemetryRecordGetId(TelemetryRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _telemetryRecordGetLinks(TelemetryRecord object) {
  return [];
}

void _telemetryRecordAttach(
    IsarCollection<dynamic> col, Id id, TelemetryRecord object) {
  object.id = id;
}

extension TelemetryRecordQueryWhereSort
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QWhere> {
  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TelemetryRecordQueryWhere
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QWhereClause> {
  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterWhereClause>
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

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterWhereClause> idBetween(
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

extension TelemetryRecordQueryFilter
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QFilterCondition> {
  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      activeTripMetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeTripMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      activeTripMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeTripMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      activeTripMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeTripMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      activeTripMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeTripMeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      activeTripMovingSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeTripMovingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      activeTripMovingSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeTripMovingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      activeTripMovingSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeTripMovingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      activeTripMovingSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeTripMovingSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
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

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
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

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
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

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      lastSavedTimestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSavedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      lastSavedTimestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSavedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      lastSavedTimestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSavedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      lastSavedTimestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSavedTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      lifetimeOdometerMetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifetimeOdometerMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      lifetimeOdometerMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lifetimeOdometerMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      lifetimeOdometerMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lifetimeOdometerMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      lifetimeOdometerMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lifetimeOdometerMeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      maxSpeedKmhEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      maxSpeedKmhGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      maxSpeedKmhLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterFilterCondition>
      maxSpeedKmhBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxSpeedKmh',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension TelemetryRecordQueryObject
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QFilterCondition> {}

extension TelemetryRecordQueryLinks
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QFilterCondition> {}

extension TelemetryRecordQuerySortBy
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QSortBy> {
  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByActiveTripMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTripMeters', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByActiveTripMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTripMeters', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByActiveTripMovingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTripMovingSeconds', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByActiveTripMovingSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTripMovingSeconds', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByLastSavedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByLastSavedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavedTimestamp', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByLifetimeOdometerMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeOdometerMeters', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByLifetimeOdometerMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeOdometerMeters', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByMaxSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeedKmh', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      sortByMaxSpeedKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeedKmh', Sort.desc);
    });
  }
}

extension TelemetryRecordQuerySortThenBy
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QSortThenBy> {
  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByActiveTripMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTripMeters', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByActiveTripMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTripMeters', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByActiveTripMovingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTripMovingSeconds', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByActiveTripMovingSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTripMovingSeconds', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByLastSavedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByLastSavedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavedTimestamp', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByLifetimeOdometerMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeOdometerMeters', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByLifetimeOdometerMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeOdometerMeters', Sort.desc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByMaxSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeedKmh', Sort.asc);
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QAfterSortBy>
      thenByMaxSpeedKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeedKmh', Sort.desc);
    });
  }
}

extension TelemetryRecordQueryWhereDistinct
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QDistinct> {
  QueryBuilder<TelemetryRecord, TelemetryRecord, QDistinct>
      distinctByActiveTripMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeTripMeters');
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QDistinct>
      distinctByActiveTripMovingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeTripMovingSeconds');
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QDistinct>
      distinctByLastSavedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSavedTimestamp');
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QDistinct>
      distinctByLifetimeOdometerMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lifetimeOdometerMeters');
    });
  }

  QueryBuilder<TelemetryRecord, TelemetryRecord, QDistinct>
      distinctByMaxSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxSpeedKmh');
    });
  }
}

extension TelemetryRecordQueryProperty
    on QueryBuilder<TelemetryRecord, TelemetryRecord, QQueryProperty> {
  QueryBuilder<TelemetryRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TelemetryRecord, double, QQueryOperations>
      activeTripMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeTripMeters');
    });
  }

  QueryBuilder<TelemetryRecord, int, QQueryOperations>
      activeTripMovingSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeTripMovingSeconds');
    });
  }

  QueryBuilder<TelemetryRecord, DateTime, QQueryOperations>
      lastSavedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSavedTimestamp');
    });
  }

  QueryBuilder<TelemetryRecord, double, QQueryOperations>
      lifetimeOdometerMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lifetimeOdometerMeters');
    });
  }

  QueryBuilder<TelemetryRecord, double, QQueryOperations>
      maxSpeedKmhProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxSpeedKmh');
    });
  }
}
