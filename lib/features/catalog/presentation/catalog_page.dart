import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/design_system/app_colors.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/pill_buttons.dart';
import '../../../shared/widgets/pills.dart';
import '../../../shared/widgets/search_field.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/catalog_entry.dart';
import '../domain/catalog_search.dart';
import 'catalog_kind_text.dart';
import 'providers/catalog_providers.dart';
import 'widgets/catalog_entry_dialog.dart';
import 'widgets/catalog_table.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  CatalogKind _kind = CatalogKind.category;
  String _query = '';

  void _selectKind(CatalogKind kind) => setState(() {
    _kind = kind;
    _query = '';
  });

  int? _count(CatalogKind kind) {
    final value = ref.watch(catalogEntriesProvider(kind));
    return value is AsyncData<List<CatalogEntry>> ? value.value.length : null;
  }

  Future<void> _openForm([CatalogEntry? entry]) async {
    if (_kind == CatalogKind.unit) {
      showMessage(
        context,
        'Units are not managed here yet. Set the unit on each product.',
      );
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => CatalogEntryDialog(kind: _kind, entry: entry),
    );
    if (saved == true && mounted) {
      ref.invalidate(catalogEntriesProvider(_kind));
      showMessage(context, '${_kind.singular} saved.');
    }
  }

  Future<void> _delete(CatalogEntry entry) async {
    final confirmed = await confirmDelete(
      context,
      title: 'Delete ${_kind.singular.toLowerCase()}?',
      message: '"${entry.name}" will be removed. This cannot be undone.',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(catalogRepositoryProvider).delete(_kind, entry.id);
      if (!mounted) return;
      ref.invalidate(catalogEntriesProvider(_kind));
      showMessage(context, 'Deleted ${entry.name}.');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(currentPermissionsProvider);
    final canCreate = permissions.contains('products.create');
    final canEdit = permissions.contains('products.update');
    final canDelete = permissions.contains('products.delete');

    final entries = ref.watch(catalogEntriesProvider(_kind));

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Categories, Brands & Units',
                subtitle: 'Manage the catalog taxonomy. Add, rename, and toggle categories, brands, and units of sale that products use.',
                action: canCreate
                    ? PrimaryPillButton(
                        icon: Icons.add,
                        label: 'Add ${_kind.singular}',
                        onPressed: () => _openForm(),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              _Tabs(selected: _kind, countOf: _count, onSelect: _selectKind),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: SearchField(
                    key: ValueKey(_kind),
                    hint: _kind.searchHint,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: entries.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error is ApiException
                              ? error.message
                              : 'Could not load ${_kind.plural.toLowerCase()}.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(catalogEntriesProvider(_kind)),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                  data: (all) {
                    final visible = filterCatalogEntries(all, _query);
                    return CatalogTable(
                      entries: visible,
                      nameHeader: '${_kind.singular} Name',
                      emptyMessage: _query.trim().isEmpty
                          ? _kind.emptyMessage
                          : 'Nothing matches your search.',
                      canEdit: canEdit,
                      canDelete: canDelete,
                      onEdit: _openForm,
                      onDelete: _delete,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.selected,
    required this.countOf,
    required this.onSelect,
  });

  final CatalogKind selected;
  final int? Function(CatalogKind) countOf;
  final ValueChanged<CatalogKind> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final kind in CatalogKind.values)
              _TabButton(
                kind: kind,
                count: countOf(kind),
                selected: kind == selected,
                onTap: () => onSelect(kind),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.kind,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final CatalogKind kind;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.ink : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(kind.icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                kind.plural,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                CountBadge(count: count!, highlighted: selected),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
