import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/api_catalog_repository.dart';
import '../../domain/catalog_entry.dart';
import '../../domain/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => ApiCatalogRepository(ref.watch(dioProvider)),
);

final catalogEntriesProvider =
    FutureProvider.family<List<CatalogEntry>, CatalogKind>(
      (ref, kind) => ref.watch(catalogRepositoryProvider).fetch(kind),
    );
