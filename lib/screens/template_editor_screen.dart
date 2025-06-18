import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schema_provider.dart';
import '../providers/sql_provider.dart';
import '../models/table_model.dart';
import '../widgets/table_editor.dart';
import '../utils/sql_generator.dart';
import '../widgets/blurred_blue_button.dart';
import '../services/sql_history_service.dart';
import '../widgets/blurred_save_template_dialog.dart';

class TemplateEditorScreen extends StatelessWidget {
  const TemplateEditorScreen({Key? key}) : super(key: key);

  void _saveTemplateToHistory(BuildContext context) async {
    final schemaProvider = Provider.of<SchemaProvider>(context, listen: false);
    if (schemaProvider.tables.isEmpty) return;
    final result = await showBlurredSaveTemplateDialog(context);
    if (result != null && result.isNotEmpty) {
      try {
        // Generar SQL y descripción de tablas
        final sql = SqlGenerator.generatePrompt(schemaProvider.tables);
        final tablesDescription = schemaProvider.tables.map((table) => {
          'name': table.tableName,
          'attributes': table.columns.map((col) => {
            'name': col.name,
            'type': col.type,
          }).toList(),
        }).toList();

        // Guardar en historial unificado
        await SqlHistoryService().saveUnifiedHistoryEntry(
          result,
          sql,
          tablesDescription,
          editorContent: schemaProvider.editorContent,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plantilla guardada en historial')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error guardando plantilla: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schemaProvider = Provider.of<SchemaProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2256A3),
        foregroundColor: Colors.white,
        title: const Text('Editar Tablas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0.5,
        shadowColor: Colors.black12,
        actions: [
          TextButton(
            onPressed: () {
              // Limpiar el SQL generado antes de navegar
              Provider.of<SqlProvider>(context, listen: false).clear();
              Navigator.pushNamed(context, '/sql-generation', arguments: schemaProvider.tables);
            },
            child: const Row(
              children: [
                Text(
                  'Continuar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 80), // Padding for FAB
        itemCount: schemaProvider.tables.length,
        itemBuilder: (context, tableIndex) {
          final table = schemaProvider.tables[tableIndex];
          return TableEditor(
            table: table,
            onChanged: (updatedTable) {
              schemaProvider.updateTable(tableIndex, updatedTable);
            },
            onDelete: () {
              schemaProvider.removeTable(table);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          schemaProvider.addTable(
            TableModel(tableName: '', columns: [ColumnModel(name: '', type: 'TEXT')]),
          );
        },
        backgroundColor: const Color(0xFF2256A3),
        tooltip: 'Agregar Tabla',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
