import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/database_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<DatabaseItem>> getItems() {
    return _db.collection('items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DatabaseItem(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
        );
      }).toList();
    });
  }

  Future<void> seedItems(List<DatabaseItem> items) async {
    final batch = _db.batch();
    for (var item in items) {
      final docRef = _db.collection('items').doc(item.id);
      batch.set(docRef, {
        'title': item.title,
        'description': item.description,
        'imageUrl': item.imageUrl,
        'metadata': item.metadata,
      });
    }
    await batch.commit();
  }
}
