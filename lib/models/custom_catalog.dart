import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

class CustomCatalog {
  static Catalog asCatalog() {
    return Catalog(
      [
        // TODO 1: Implement Column Layout CatalogItem
        // S.object(properties: {'children': S.list(items: S.string())})
        
        // TODO 2: Implement TextCard CatalogItem
        // S.object(properties: {'title': S.string(), 'content': S.string()})
        
        // TODO 3: Implement ImageCard CatalogItem
        // S.object(properties: {'imageUrl': S.string(), 'title': S.string(), 'caption': S.string()})
        
        // TODO 4: Implement InteractiveButton CatalogItem
        // S.object(properties: {'label': S.string(), 'actionId': S.string()})
        
        // TODO 5: Implement ComparisonTable CatalogItem
        // S.object(properties: {'title': S.string(), 'headers': S.list(...), 'items': S.list(...)})
        
        // TODO 6: Implement StatusIndicator CatalogItem
        // S.object(properties: {'label': S.string(), 'status': S.string(), 'colorHex': S.string()})
      ],
      catalogId: 'custom_catalog',
    );
  }
}
