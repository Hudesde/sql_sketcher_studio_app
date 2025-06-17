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
        // Para web: usar la función de descarga web
        download.downloadFile(sqlProvider.sqlCode, 'generated_sql.sql');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Archivo SQL descargado con éxito!')),
        );
      } else {
        // Para móvil: guardar en documentos y mostrar ubicación
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
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Guardar en el historial',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Asigna un nombre para este SQL:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      hintText: 'Ejemplo: Esquema de gestión de usuarios',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            return;
                          }
                          Navigator.pop(context, name);
                        },
                        child: Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      try {
        // Guardar SQL y estructura de tablas en la misma entrada
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
          editorContent: schemaProvider.editorContent,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Guardado en el historial con éxito!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar en el historial: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final schemaProvider = Provider.of<SchemaProvider>(context);
    final sqlProvider = Provider.of<SqlProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2256A3),
        foregroundColor: Colors.white,
        title: const Text('Generate SQL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0.5,
        shadowColor: Colors.black12,
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (schemaProvider.tables.isNotEmpty)
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tables:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...schemaProvider.tables.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '- ${t.tableName.isEmpty ? '(unnamed)' : t.tableName}',
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: BlurredBlueButton(
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Generate SQL'),
                  onPressed: _loading ? null : () => _generateSQL(context),
                  height: 48,
                  borderRadius: 10,
                  borderColor: const Color(0xFF2256A3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            sqlProvider.sqlCode.isEmpty ? 'SQL code will appear here.' : sqlProvider.sqlCode,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 15, color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Copy',
                            icon: const Icon(Icons.copy_rounded, color: Color(0xFF2256A3)),
                            onPressed: sqlProvider.sqlCode.isEmpty ? null : () async {
                              await Clipboard.setData(ClipboardData(text: sqlProvider.sqlCode));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                            },
                          ),
                          IconButton(
                            tooltip: 'Download SQL',
                            icon: const Icon(Icons.download_rounded, color: Color(0xFF2256A3)),
                            onPressed: sqlProvider.sqlCode.isEmpty ? null : () => _downloadSQL(context),
                          ),
                          IconButton(
                            tooltip: 'Share',
                            icon: const Icon(Icons.share_rounded, color: Color(0xFF2256A3)),
                            onPressed: sqlProvider.sqlCode.isEmpty ? null : () async {
                              if (kIsWeb) {
                                // En web, solo copiamos al portapapeles
                                await Clipboard.setData(ClipboardData(text: sqlProvider.sqlCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('SQL copied to clipboard for sharing'))
                                );
                              } else {
                                // En móvil, compartimos el archivo
                                try {
                                  final directory = await getTemporaryDirectory();
                                  final file = File('${directory.path}/generated.sql');
                                  await file.writeAsString(sqlProvider.sqlCode);
                                  await Share.shareXFiles([XFile(file.path)], text: 'SQL generated with SQL Sketcher');
                                } catch (e) {
                                  // Si falla, copiamos al portapapeles como fallback
                                  await Clipboard.setData(ClipboardData(text: sqlProvider.sqlCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('SQL copied to clipboard'))
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Save to history',
                            icon: const Icon(Icons.bookmark_add, color: Color(0xFF2256A3)),
                            onPressed: sqlProvider.sqlCode.isEmpty ? null : () => _saveToHistory(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Tarjetas de presets
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: schemaProvider.tables.map((table) {
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(table.tableName),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 24),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/history'),
          icon: const Icon(Icons.history, color: Colors.white),
          label: const Text('Historial', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2256A3),
          elevation: 4,
        ),
      ),
    );
  }
}
