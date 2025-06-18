import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sql_provider.dart';
import '../providers/schema_provider.dart';
import '../services/openai_service.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/blurred_blue_button.dart';
import '../services/sql_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
// Import condicional para descargas
import '../utils/web_download.dart' if (dart.library.io) '../utils/mobile_download.dart' as download;

class SqlGenerationScreen extends StatefulWidget {
  const SqlGenerationScreen({Key? key}) : super(key: key);

  @override
  State<SqlGenerationScreen> createState() => _SqlGenerationScreenState();
}

class _SqlGenerationScreenState extends State<SqlGenerationScreen> {
  bool _loading = false;
  String? _error;
  late OpenAIService openAIService;

  @override
  void initState() {
    super.initState();
    final apiKey = Provider.of<SqlProvider>(context, listen: false).apiKey;
    openAIService = OpenAIService(apiKey: apiKey);
    // Generar SQL automáticamente al entrar en la pantalla si no hay código previo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sqlProvider = Provider.of<SqlProvider>(context, listen: false);
      if (sqlProvider.sqlCode.isEmpty) {
        _generateSQL(context);
      }
    });
  }

  Future<void> _generateSQL(BuildContext context) async {
    setState(() { _loading = true; _error = null; });
    final schemaProvider = Provider.of<SchemaProvider>(context, listen: false);
    final sqlProvider = Provider.of<SqlProvider>(context, listen: false);
    try {
      await openAIService.generateAndStoreSQL(
        tables: schemaProvider.tables,
        sqlProvider: sqlProvider,
      );
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _downloadSQL(BuildContext context) async {
    final sqlProvider = Provider.of<SqlProvider>(context, listen: false);
    if (sqlProvider.sqlCode.isEmpty) return;

    try {
      if (kIsWeb) {
        download.downloadFile(sqlProvider.sqlCode, 'generated_sql.sql');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Archivo SQL descargado con éxito!')),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/generated_sql.sql');
        await file.writeAsString(sqlProvider.sqlCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SQL guardado en ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el archivo: $e')),
      );
    }
  }

  void _saveToHistory(BuildContext context) async {
    final sqlProvider = Provider.of<SqlProvider>(context, listen: false);
    if (sqlProvider.sqlCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay código SQL para guardar')),
      );
      return;
    }
    
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Guardar en Historial',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2256A3),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Asigna un nombre para este SQL:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  labelText: 'Nombre del Historial',
                  hintText: 'Ej: Esquema de usuarios',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        Navigator.pop(context, nameController.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2256A3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      try {
        final schemaProvider = Provider.of<SchemaProvider>(context, listen: false);
        final tables = schemaProvider.tables.map((table) => {
          'name': table.tableName,
          'attributes': table.columns.map((col) => {
            'name': col.name,
            'type': col.type,
          }).toList(),
        }).toList();
        await SqlHistoryService().saveUnifiedHistoryEntry(
          result,
          sqlProvider.sqlCode,
          tables,
          editorContent: sqlProvider.sqlCode, // Guardar el contenido del editor
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Guardado en el historial con éxito')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar en el historial: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sqlProvider = context.watch<SqlProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2256A3),
        foregroundColor: Colors.white,
        title: const Text('Generador de SQL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0.5,
        shadowColor: Colors.black12,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, size: 28),
            tooltip: 'Ver Historial',
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              sqlProvider.sqlCode,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            context,
                            icon: Icons.copy,
                            label: 'Copiar',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: sqlProvider.sqlCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('SQL copiado al portapapeles')),
                              );
                            },
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.download,
                            label: 'Descargar',
                            onPressed: () => _downloadSQL(context),
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.save,
                            label: 'Guardar',
                            onPressed: () => _saveToHistory(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: const Color(0xFF2256A3),
            foregroundColor: Colors.white,
            elevation: 3,
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
