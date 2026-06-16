class DatabaseItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final Map<String, dynamic> metadata;

  DatabaseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.metadata = const {},
  });
}

final List<DatabaseItem> mockItems = [
  DatabaseItem(
    id: '1',
    title: 'Generic Item 1',
    description: 'This is a placeholder description for the first generic item.',
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
    metadata: {'tag': 'General', 'value': 100.0},
  ),
  DatabaseItem(
    id: '2',
    title: 'Generic Item 2',
    description: 'This is a placeholder description for the second generic item.',
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
    metadata: {'tag': 'Feature', 'value': 250.0},
  ),
];
