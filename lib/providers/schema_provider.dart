import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table_model.dart';
import '../services/sql_history_service.dart';

/// Provider para manejar el estado del esquema de tablas
class SchemaProvider extends ChangeNotifier {
  List<TableModel> _tables = [];

  List<TableModel> get tables => _tables;

  void addTable(TableModel table) {
    _tables.add(table);
    notifyListeners();
  }

  void removeTable(TableModel table) {
    _tables.remove(table);
    notifyListeners();
  }

  void updateTable(int index, TableModel table) {
    _tables[index] = table;
    notifyListeners();
  }

  void clear() {
    _tables.clear();
    notifyListeners();
  }

  // Métodos enriquecidos
  void addColumn(int tableIndex, ColumnModel column) {
    _tables[tableIndex].columns.add(column);
    notifyListeners();
  }

  void removeColumn(int tableIndex, int columnIndex) {
    _tables[tableIndex].columns.removeAt(columnIndex);
    notifyListeners();
  }

  void updateColumn(int tableIndex, int columnIndex, ColumnModel column) {
    _tables[tableIndex].columns[columnIndex] = column;
    notifyListeners();
  }

  void saveSchemaToHistory(BuildContext context) async {
    final schemaProvider = Provider.of<SchemaProvider>(context, listen: false);
    if (schemaProvider.tables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tables to save')),
      );
      return;
    }

    final tablesDescription = schemaProvider.tables.map((table) => {
      'name': table.tableName,
      'attributes': table.columns.map((col) => {
        'name': col.name,
        'type': col.type,
      }).toList(),
    }).toList();

    try {
      await SqlHistoryService().saveHistoryEntryWithTables(
        'Schema Description',
        '',
        tablesDescription,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schema saved to history')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving schema: $e')),
      );
    }
  }

  String _editorContent = '';

  String get editorContent => _editorContent;

  void updateEditorContent(String content) {
    _editorContent = content;
    notifyListeners();
  }
}
