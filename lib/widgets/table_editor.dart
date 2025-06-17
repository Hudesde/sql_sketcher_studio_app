import 'package:flutter/material.dart';
import '../models/table_model.dart';

class TableEditor extends StatefulWidget {
  final TableModel table;
  final ValueChanged<TableModel> onChanged;
  final VoidCallback onDelete;

  const TableEditor({
    Key? key,
    required this.table,
    required this.onChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<TableEditor> createState() => _TableEditorState();
}

class _TableEditorState extends State<TableEditor> {
  late TextEditingController _tableNameController;
  final List<TextEditingController> _columnControllers = [];

  @override
  void initState() {
    super.initState();
    _tableNameController = TextEditingController(text: widget.table.tableName);
    _tableNameController.addListener(_tableNameListener);
    _initColumnControllers();
  }

  void _initColumnControllers() {
    // Mantener los controladores existentes si es posible
    final oldControllers = List<TextEditingController>.from(_columnControllers);
    _columnControllers.clear();
    for (int i = 0; i < widget.table.columns.length; i++) {
      if (i < oldControllers.length) {
        _columnControllers.add(oldControllers[i]);
        if (_columnControllers[i].text != widget.table.columns[i].name) {
          _columnControllers[i].text = widget.table.columns[i].name;
          _columnControllers[i].selection = TextSelection.collapsed(offset: _columnControllers[i].text.length);
        }
      } else {
        _columnControllers.add(TextEditingController(text: widget.table.columns[i].name));
      }
    }
    // Eliminar controladores sobrantes
    for (int i = widget.table.columns.length; i < oldControllers.length; i++) {
      oldControllers[i].dispose();
    }
  }

  void _initTableNameController() {
    final oldText = _tableNameController.text;
    _tableNameController.removeListener(_tableNameListener);
    _tableNameController.text = widget.table.tableName;
    _tableNameController.selection = TextSelection.collapsed(offset: _tableNameController.text.length);
    _tableNameController.addListener(_tableNameListener);
  }

  void _tableNameListener() {
    if (_tableNameController.text != widget.table.tableName) {
      widget.onChanged(widget.table.copyWith(tableName: _tableNameController.text));
    }
  }

  @override
  void didUpdateWidget(covariant TableEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.table.tableName != widget.table.tableName) {
      _initTableNameController();
    }
    if (oldWidget.table.columns.length != widget.table.columns.length) {
      _initColumnControllers();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    for (var c in _columnControllers) {
      c.dispose();
    }
    super.dispose();
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
                        onChanged: (value) {
                          final newColumns = List<ColumnModel>.from(widget.table.columns);
                          newColumns[colIndex] = newColumns[colIndex].copyWith(name: value);
                          widget.onChanged(widget.table.copyWith(columns: newColumns));
                        },
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
                        _initColumnControllers();
                        setState(() {});
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
                _initColumnControllers();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
