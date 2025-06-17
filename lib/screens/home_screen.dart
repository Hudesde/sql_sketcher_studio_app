import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schema_provider.dart';
import '../data/templates.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _routes = [
    '/',
    '/template-editor',
    '/sql-generation',
    '/history',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) return; // Ya estamos en Home
    Navigator.pushNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final templateNames = Templates.templates.keys.toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2256A3),
        title: const Text('SQL Sketcher', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text(
              'Choose a Template',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              itemCount: templateNames.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final name = templateNames[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1.5,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectTemplate(context, name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Row(
                        children: [
                          Icon(_iconForTemplate(name), size: 36, color: const Color(0xFF2256A3)),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _subtitleForTemplate(name),
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.black38, size: 28),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2256A3),
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Plantillas'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'Editor'),
          BottomNavigationBarItem(icon: Icon(Icons.code), label: 'SQL'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  void _selectTemplate(BuildContext context, String templateName) {
    final schemaProvider = Provider.of<SchemaProvider>(context, listen: false);
    schemaProvider.clear();
    schemaProvider.tables.addAll(Templates.templates[templateName]!);
    Navigator.pushNamed(context, '/template-editor');
  }

  IconData _iconForTemplate(String name) {
    switch (name) {
      case 'Sistema Escolar':
        return Icons.school;
      case 'Tienda en Línea':
        return Icons.shopping_cart;
      case 'Punto de Venta':
        return Icons.point_of_sale;
      case 'Blog':
        return Icons.article;
      default:
        return Icons.table_chart;
    }
  }

  String _subtitleForTemplate(String name) {
    switch (name) {
      case 'Sistema Escolar':
        return 'Alumnos, cursos, calificaciones';
      case 'Tienda en Línea':
        return 'Productos, órdenes, clientes';
      case 'Punto de Venta':
        return 'Ventas, clientes, pagos';
      case 'Blog':
        return 'Posts, comentarios, usuarios';
      default:
        return '';
    }
  }
}

