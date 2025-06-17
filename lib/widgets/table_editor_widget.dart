import 'package:flutter/material.dart';
import '../models/table_model.dart';

class TableEditorWidget extends StatefulWidget {
  final TableModel table;
  final ValueChanged<TableModel> onChanged;
  final VoidCallback onDelete;

  const TableEditorWidget({
    Key? key,
    required this.table,
    required this.onChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<TableEditorWidget> createState() => _TableEditorWidgetState();
}

class _TableEditorWidgetState extends State<TableEditorWidget> {
  late TextEditingController _tableNameController;
  late List<TextEditingController> _columnControllers;

  @override
  void initState() {
    super.initState();
    _tableNameController = TextEditingController(text: widget.table.tableName);
    _columnControllers = widget.table.columns
        .map((col) => TextEditingController(text: col.name))
        .toList();
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    for (var c in _columnControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTableNameChanged(String value) {
    widget.onChanged(widget.table.copyWith(tableName: value));
  }

  void _onColumnChanged(int index, String value) {
    final newColumns = List<ColumnModel>.from(widget.table.columns);
    newColumns[index] = newColumns[index].copyWith(name: value);
    widget.onChanged(widget.table.copyWith(columns: newColumns));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tableNameController,
                    decoration: const InputDecoration(labelText: 'Table Name'),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    onChanged: _onTableNameChanged,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.table.columns.length,
              itemBuilder: (context, colIndex) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _columnControllers[colIndex],
                        decoration: const InputDecoration(labelText: 'Column Name'),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        onChanged: (value) => _onColumnChanged(colIndex, value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: widget.table.columns[colIndex].type,
                      items: const [
                        DropdownMenuItem(value: 'INTEGER', child: Text('INTEGER')),
                        DropdownMenuItem(value: 'TEXT', child: Text('TEXT')),
                        DropdownMenuItem(value: 'REAL', child: Text('REAL')),
                        DropdownMenuItem(value: 'BOOLEAN', child: Text('BOOLEAN')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        final newColumns = List<ColumnModel>.from(widget.table.columns);
                        newColumns[colIndex] = newColumns[colIndex].copyWith(type: value);
                        widget.onChanged(widget.table.copyWith(columns: newColumns));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        final newColumns = List<ColumnModel>.from(widget.table.columns)..removeAt(colIndex);
                        widget.onChanged(widget.table.copyWith(columns: newColumns));
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Column'),
              onPressed: () {
                final newColumns = List<ColumnModel>.from(widget.table.columns)
                  ..add(ColumnModel(name: '', type: 'TEXT'));
                widget.onChanged(widget.table.copyWith(columns: newColumns));
              },
            ),
          ],
        ),
      ),
    );
  }
}
