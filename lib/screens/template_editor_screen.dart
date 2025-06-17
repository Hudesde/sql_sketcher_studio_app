import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schema_provider.dart';
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
        title: const Text('Edit Tables', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0.5,
        shadowColor: Colors.black12,
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
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
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2256A3),
                  elevation: 2,
                  minimumSize: const Size(240, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFF2256A3), width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
                icon: const Icon(Icons.arrow_forward, size: 26),
                label: const Text('Dirigirse a SQL', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                onPressed: () {
                  Navigator.pushNamed(context, '/sql-generation', arguments: schemaProvider.tables);
                },
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2256A3),
                  elevation: 2,
                  minimumSize: const Size(240, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFF2256A3), width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
                icon: const Icon(Icons.add, size: 26),
                label: const Text('Agregar tabla', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                onPressed: () {
                  schemaProvider.addTable(
                    TableModel(tableName: '', columns: [ColumnModel(name: '', type: 'TEXT')]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
