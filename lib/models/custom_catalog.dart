import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

class CustomCatalog {
  static Catalog asCatalog() {
    return Catalog(
      [
        // 1. Column Layout
        CatalogItem(
          name: 'Column',
          dataSchema: S.object(properties: {'children': S.list(items: S.string())}),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final childrenIds = (props['children'] as List? ?? []).cast<String>();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: childrenIds.map((id) => itemContext.buildChild(id)).toList(),
            );
          },
        ),
        
        // 2. TextCard
        CatalogItem(
          name: 'TextCard',
          dataSchema: S.object(properties: {
            'title': S.string(),
            'content': S.string()
          }),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final context = itemContext.buildContext;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(props['title'] as String? ?? 'Card Title', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(props['content'] as String? ?? '', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          },
        ),
        
        // 3. ImageCard
        CatalogItem(
          name: 'ImageCard',
          dataSchema: S.object(properties: {
            'imageUrl': S.string(),
            'title': S.string(),
            'caption': S.string()
          }),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final context = itemContext.buildContext;
            return Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    props['imageUrl'] as String? ?? '',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 150, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(props['title'] as String? ?? '', style: Theme.of(context).textTheme.titleMedium),
                        Text(props['caption'] as String? ?? '', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        // 4. InteractiveButton
        CatalogItem(
          name: 'InteractiveButton',
          dataSchema: S.object(properties: {
            'label': S.string(),
            'actionId': S.string()
          }),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(itemContext.buildContext).showSnackBar(
                    SnackBar(content: Text('Action Triggered: ${props['actionId']}')),
                  );
                },
                child: Text(props['label'] as String? ?? 'Button'),
              ),
            );
          },
        ),
        
        // 5. ComparisonTable
        CatalogItem(
          name: 'ComparisonTable',
          dataSchema: S.object(properties: {
            'title': S.string(),
            'items': S.list(items: S.object(properties: {
              'label': S.string(),
              'values': S.list(items: S.string())
            })),
            'headers': S.list(items: S.string())
          }),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final headers = (props['headers'] as List? ?? []).cast<String>();
            final items = (props['items'] as List? ?? []);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(props['title'] as String? ?? 'Comparison', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: headers.map((h) => DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        rows: items.map((item) {
                          final row = item as Map<String, dynamic>;
                          final values = (row['values'] as List? ?? []).map((v) => v.toString()).toList();
                          final List<DataCell> cells = [DataCell(Text(row['label'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w500)))];
                          cells.addAll(values.map((v) => DataCell(Text(v))));
                          while (cells.length < headers.length) {
                            cells.add(const DataCell(Text('-')));
                          }
                          return DataRow(cells: cells.take(headers.length).toList());
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // 6. StatusIndicator
        CatalogItem(
          name: 'StatusIndicator',
          dataSchema: S.object(properties: {
            'label': S.string(),
            'status': S.string(),
            'colorHex': S.string()
          }),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final colorStr = props['colorHex'] as String? ?? '#4CAF50';
            final parsedColor = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: parsedColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text('${props['label']}: ${props['status']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        )
      ],
      catalogId: 'custom_catalog',
    );
  }
}
