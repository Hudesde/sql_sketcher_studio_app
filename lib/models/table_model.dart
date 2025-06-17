/// Modelo de tabla para el esquema de base de datos
class TableModel {
  String tableName;
  List<ColumnModel> columns;
  String? primaryKey;
  List<ForeignKeyModel>? foreignKeys;

  TableModel({
    required this.tableName,
    required this.columns,
    this.primaryKey,
    this.foreignKeys,
  });

  TableModel copyWith({
    String? tableName,
    List<ColumnModel>? columns,
    String? primaryKey,
    List<ForeignKeyModel>? foreignKeys,
  }) {
    return TableModel(
      tableName: tableName ?? this.tableName,
      columns: columns ?? this.columns,
      primaryKey: primaryKey ?? this.primaryKey,
      foreignKeys: foreignKeys ?? this.foreignKeys,
    );
  }
}

/// Modelo de columna
class ColumnModel {
  String name;
  String type;
  bool isNullable;

  ColumnModel({
    required this.name,
    required this.type,
    this.isNullable = true,
  });

  ColumnModel copyWith({
    String? name,
    String? type,
    bool? isNullable,
  }) {
    return ColumnModel(
      name: name ?? this.name,
      type: type ?? this.type,
      isNullable: isNullable ?? this.isNullable,
    );
  }
}

/// Modelo de clave foránea
class ForeignKeyModel {
  String column;
  String refTable;
  String refColumn;

  ForeignKeyModel({
    required this.column,
    required this.refTable,
    required this.refColumn,
  });
}
