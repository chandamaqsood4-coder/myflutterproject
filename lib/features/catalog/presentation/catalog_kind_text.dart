import 'package:flutter/material.dart';

import '../domain/catalog_entry.dart';

extension CatalogKindText on CatalogKind {
  String get plural => switch (this) {
    CatalogKind.category => 'Categories',
    CatalogKind.brand => 'Brands',
    CatalogKind.unit => 'Units',
  };

  String get singular => switch (this) {
    CatalogKind.category => 'Category',
    CatalogKind.brand => 'Brand',
    CatalogKind.unit => 'Unit',
  };

  IconData get icon => switch (this) {
    CatalogKind.category => Icons.sell_outlined,
    CatalogKind.brand => Icons.check_circle_outline,
    CatalogKind.unit => Icons.straighten,
  };

  String get searchHint => switch (this) {
    CatalogKind.category => 'Search categories by name or slug...',
    CatalogKind.brand => 'Search brands by name or slug...',
    CatalogKind.unit => 'Search units by name or slug...',
  };

  String get emptyMessage => switch (this) {
    CatalogKind.category => 'No categories yet.',
    CatalogKind.brand => 'No brands yet.',
    CatalogKind.unit => 'No units yet. Units are set on each product for now.',
  };
}
