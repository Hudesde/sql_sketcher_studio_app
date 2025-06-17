import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SqlHistoryService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<void> saveHistoryEntry(String name, String sql, {String type = 'sql'}) async {
    if (userId == null) throw Exception('No user logged in');
    
    try {
      await _firestore.collection('users').doc(userId).collection('history').add({
        'name': name.trim(),
        'sql': sql.trim(),
        'type': type,
        'date': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveHistoryEntryWithTables(String name, String sql, List<Map<String, dynamic>> tables) async {
    if (userId == null) throw Exception('No user logged in');

    try {
      await _firestore.collection('users').doc(userId).collection('history').add({
        'name': name.trim(),
        'sql': sql.trim(),
        'tables': tables,
        'type': 'sql_with_tables',
        'date': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveUnifiedHistoryEntry(String name, String sql, List<Map<String, dynamic>> tables, {String? editorContent}) async {
    if (userId == null) throw Exception('No user logged in');

    try {
      await _firestore.collection('users').doc(userId).collection('history').add({
        'name': name.trim(),
        'sql': sql.trim(),
        'tables': tables,
        'editorContent': editorContent?.trim(),
        'type': 'unified_entry',
        'date': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserHistory() {
    if (userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Agregar el ID del documento
            return data;
          }).toList();
        });
  }

  Future<void> deleteHistoryEntry(String entryId) async {
    if (userId == null) throw Exception('No user logged in');
    
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(entryId)
        .delete();
  }
}
