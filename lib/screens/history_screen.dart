import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sql_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/sql_generator.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2256A3),
        foregroundColor: Colors.white,
          title: const Text('Historial de SQL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SqlHistoryService().getUserHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay historial de SQL',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Genera o guarda algún SQL para verlo aquí',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: history.map((entry) {
              final name = entry['name'] ?? 'SQL sin nombre';
              final sql = entry['sql'] ?? '';
              final date = _formatDate(entry);
              final tables = entry['tables'] ?? [];

              return GestureDetector(
                onTap: () => _showSqlDialog(context, entry),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: Colors.blue[50],
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        ...tables.map<Widget>((table) {
                          final tableName = table['name'] ?? 'Tabla sin nombre';
                          final attributes = table['attributes'] ?? [];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tableName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2256A3)),
                              ),
                              const SizedBox(height: 4),
                              ...attributes.map<Widget>((attr) => Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 2),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 7, color: Color(0xFF2256A3)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${attr['name']} ',
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                    ),
                                    Text(
                                      '(${attr['type']})',
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                        Text(
                          date,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _formatDate(Map<String, dynamic> entry) {
    try {
      // Intentar usar serverTimestamp primero
      if (entry['date'] != null) {
        final timestamp = entry['date'];
        if (timestamp is Timestamp) {
          final date = timestamp.toDate();
          return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        }
      }
      
      // Fallback a createdAt
      if (entry['createdAt'] != null) {
        final dateStr = entry['createdAt'] as String;
        final date = DateTime.parse(dateStr);
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      
      return 'Fecha desconocida';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _showSqlDialog(BuildContext context, Map<String, dynamic> entry) {
    final name = entry['name'] ?? 'Unnamed SQL';
    final sql = entry['sql'] ?? '';
    final date = _formatDate(entry);
    final tables = entry['tables'] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Código SQL:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    sql,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tablas y Atributos:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...tables.map<Widget>((table) {
                  final tableName = table['name'] ?? 'Unnamed Table';
                  final attributes = table['attributes'] ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tableName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2256A3)),
                      ),
                      const SizedBox(height: 4),
                      ...attributes.map<Widget>((attr) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 7, color: Color(0xFF2256A3)),
                            const SizedBox(width: 6),
                            Text(
                              '${attr['name']} ',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                            Text(
                              '(${attr['type']})',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String sql) {
    Clipboard.setData(ClipboardData(text: sql));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SQL copiado al portapapeles')),
    );
  }

  void _deleteEntry(BuildContext context, String? entryId, String name) {
    if (entryId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar entrada'),
        content: Text('¿Estás seguro de que quieres eliminar "$name"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
            onPressed: () async {
              try {
                await SqlHistoryService().deleteHistoryEntry(entryId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entrada eliminada con éxito')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar la entrada: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _generateSqlAndUpdate(BuildContext context, Map<String, dynamic> entry) async {
    try {
      final tables = entry['tables'] ?? [];
      final generatedSql = SqlGenerator.generatePrompt(tables);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('history')
          .doc(entry['id'])
          .update({'sql': generatedSql});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SQL generado y actualizado')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar SQL: $e')),
        );
      }
    }
  }
}
