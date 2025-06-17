import '../models/table_model.dart';

/// Plantillas predefinidas de esquemas de base de datos
class Templates {
  static final Map<String, List<TableModel>> templates = {
    'Sistema Escolar': [
      TableModel(
        tableName: 'alumnos',
        columns: [
          ColumnModel(name: 'id', type: 'INTEGER', isNullable: false),
          ColumnModel(name: 'nombre', type: 'TEXT'),
          ColumnModel(name: 'edad', type: 'INTEGER'),
        ],
        primaryKey: 'id',
      ),
      TableModel(
        tableName: 'cursos',
        columns: [
          ColumnModel(name: 'id', type: 'INTEGER', isNullable: false),
          ColumnModel(name: 'nombre', type: 'TEXT'),
        ],
        primaryKey: 'id',
      ),
      TableModel(
        tableName: 'inscripciones',
        columns: [
          ColumnModel(name: 'alumno_id', type: 'INTEGER', isNullable: false),
          ColumnModel(name: 'curso_id', type: 'INTEGER', isNullable: false),
        ],
        primaryKey: null,
        foreignKeys: [
          ForeignKeyModel(column: 'alumno_id', refTable: 'alumnos', refColumn: 'id'),
          ForeignKeyModel(column: 'curso_id', refTable: 'cursos', refColumn: 'id'),
        ],
      ),
    ],
    'Tienda en Línea': [
      TableModel(
        tableName: 'productos',
        columns: [
          ColumnModel(name: 'id', type: 'INTEGER', isNullable: false),
          ColumnModel(name: 'nombre', type: 'TEXT'),
          ColumnModel(name: 'precio', type: 'REAL'),
        ],
        primaryKey: 'id',
      ),
      TableModel(
        tableName: 'clientes',
        columns: [
          ColumnModel(name: 'id', type: 'INTEGER', isNullable: false),
          ColumnModel(name: 'nombre', type: 'TEXT'),
        ],
        primaryKey: 'id',
      ),
      TableModel(
        tableName: 'ordenes',
        columns: [
          ColumnModel(name: 'id', type: 'INTEGER', isNullable: false),
          ColumnModel(name: 'cliente_id', type: 'INTEGER'),
        ],
        primaryKey: 'id',
        foreignKeys: [
          ForeignKeyModel(column: 'cliente_id', refTable: 'clientes', refColumn: 'id'),
        ],
      ),
    ],
    'Blog': [
      TableModel(
        tableName: 'posts',
        columns: [
          ColumnModel(name: 'id', type: 'INTEGER', isNullable: false),
          ColumnModel(name: 'titulo', type: 'TEXT'),
          ColumnModel(name: 'contenido', type: 'TEXT'),
        ],
        primaryKey: 'id',
      ),
      TableModel(
        tableName: 'comentarios',
        columns: [
          ColumnModel(name: 'id', type: 'INTEGER', isNullable: false),
          ColumnModel(name: 'post_id', type: 'INTEGER'),
          ColumnModel(name: 'texto', type: 'TEXT'),
        ],
        primaryKey: 'id',
        foreignKeys: [
          ForeignKeyModel(column: 'post_id', refTable: 'posts', refColumn: 'id'),
        ],
      ),
    ],
  };
}
