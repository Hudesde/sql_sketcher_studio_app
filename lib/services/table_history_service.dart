import 'package:cloud_firestore/cloud_firestore.dart';

class TableHistoryService {
  final CollectionReference _tableHistoryCollection =
      FirebaseFirestore.instance.collection('tables_history');

  Future<void> addTableHistory({
    required String userId,
    required String name,
    required List<Map<String, dynamic>> columns,
    DateTime? createdAt,
  }) async {
    await _tableHistoryCollection.add({
      'userId': userId,
      'name': name,
      'columns': columns,
      'createdAt': createdAt ?? DateTime.now(),
    });
  }

  Stream<QuerySnapshot> getUserTableHistory(String userId) {
    return _tableHistoryCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
