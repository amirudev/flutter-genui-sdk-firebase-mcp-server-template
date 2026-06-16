import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/database_item.dart';
import '../services/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: itemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No items found in Firestore.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .seedItems(mockItems);
                      },
                      icon: const Icon(Icons.dataset),
                      label: const Text('Seed Generic Mock Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            item.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: TextStyle(color: Colors.grey[600], height: 1.4),
                            ),
                            if (item.metadata.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: item.metadata.entries.map((entry) {
                                  return Chip(
                                    label: Text('${entry.key}: ${entry.value}'),
                                    backgroundColor: Colors.blue.shade50,
                                    labelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            final errorString = err.toString();
            bool isPermissionDenied = errorString.contains('permission-denied');
            if (isPermissionDenied) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.gpp_maybe, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text(
                        'Firestore Permission Denied',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'It looks like your Firebase project isn\'t fully initialized, or your Firestore security rules are blocking access.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'How to fix this:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Open your Firebase Console.\n'
                        '2. Navigate to Firestore Database.\n'
                        '3. If you haven\'t created a database yet, click "Create database".\n'
                        '4. Go to the "Rules" tab.\n'
                        '5. For development, update your rules to allow read/write access:',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SelectableText(
                          'rules_version = \'2\';\n'
                          'service cloud.firestore {\n'
                          '  match /databases/{database}/documents {\n'
                          '    match /{document=**} {\n'
                          '      allow read, write: if true;\n'
                          '    }\n'
                          '  }\n'
                          '}',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Note: Be sure to secure your rules before deploying to production!',
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Original error: $errorString',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $err')));
          },
        ),
      ),
    );
  }
}
