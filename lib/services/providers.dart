import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/database_item.dart';
import 'firestore_service.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final itemsStreamProvider = StreamProvider<List<DatabaseItem>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getItems();
});
