import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

class HelpDeskCatalog {
  static Catalog asCatalog() {
    return Catalog(
      [
        // TODO 1: Implement Column Layout CatalogItem
        // S.object(properties: {'children': S.list(items: S.string())})
        
        // TODO 2: Implement ProductCard CatalogItem
        // S.object(properties: {'name': S.string(), 'price': S.string(), 'imageUrl': S.string()})
        
        // TODO 3: Implement FAQCard CatalogItem
        // S.object(properties: {'question': S.string(), 'answer': S.string()})
        
        // TODO 4: Implement OrderStatus CatalogItem
        // S.object(properties: {'orderId': S.string(), 'status': S.string(), 'estimatedDelivery': S.string()})
        
        // TODO 5: Implement PromoCard CatalogItem
        // S.object(properties: {'title': S.string(), 'code': S.string(), 'discount': S.string(), 'expiry': S.string()})
        
        // TODO 6: Implement ComparisonTable CatalogItem
        // S.object(properties: {'title': S.string(), 'items': S.list(...), 'headers': S.list(...)})
        
        // TODO 7: Implement SupportContact CatalogItem
        // S.object(properties: {'type': S.string(), 'value': S.string()})
      ],
      catalogId: 'help_desk',
    );
  }
}
