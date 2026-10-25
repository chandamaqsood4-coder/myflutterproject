import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_colors.dart';
import '../../../../shared/design_system/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/pills.dart';
import '../../../../shared/widgets/row_action.dart';
import '../../domain/catalog_entry.dart';

const double _actionsWidth = 240;
const double _minTableWidth = 640;
const double _rowHeight = 64;
const double _headerHeight = 46;

class CatalogTable extends StatelessWidget {
  const CatalogTable({
    super.key,
    required this.entries,
    required this.nameHeader,
    required this.emptyMessage,
    required this.onEdit,
    required this.onDelete,
    required this.canEdit,
    required this.canDelete,
  });

  final bool canEdit;
  final bool canDelete;
  final List<CatalogEntry> entries;
  final String nameHeader;
  final String emptyMessage;
  final ValueChanged<CatalogEntry> onEdit;
  final ValueChanged<CatalogEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return AppCard(
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // The action labels grow with the text scale, so the column widens with
    // them instead of clipping the labels.
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final actionsWidth = (_actionsWidth * scale).clamp(200.0, 320.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final table = AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _HeaderRow(nameHeader: nameHeader, actionsWidth: actionsWidth),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemExtent: _rowHeight,
                  itemBuilder: (context, index) => _EntryRow(
                    entry: entries[index],
                    onEdit: () => onEdit(entries[index]),
                    onDelete: () => onDelete(entries[index]),
                    canEdit: canEdit,
                    canDelete: canDelete,
                    actionsWidth: actionsWidth,
                  ),
                ),
              ),
            ],
          ),
        );

        if (constraints.maxWidth >= _minTableWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _minTableWidth,
            height: constraints.maxHeight,
            child: table,
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.nameHeader, required this.actionsWidth});

  final String nameHeader;
  final double actionsWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _headerHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(nameHeader, style: AppTextStyles.tableHeader),
            ),
            const Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'Linked Products',
                  style: AppTextStyles.tableHeader,
                ),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Center(
                child: Text('Status', style: AppTextStyles.tableHeader),
              ),
            ),
            SizedBox(
              width: actionsWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Actions',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.tableHeader,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    required this.canEdit,
    required this.canDelete,
    required this.actionsWidth,
  });

  final bool canEdit;
  final bool canDelete;
  final CatalogEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double actionsWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.slug,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: entry.linkedProducts == null
                    ? const Text(
                        '—',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    : CountBadge(
                        count: entry.linkedProducts!,
                        highlighted: entry.linkedProducts! > 0,
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: StatusPill(
                  label: entry.isActive ? 'ACTIVE' : 'INACTIVE',
                  tone: entry.isActive ? PillTone.success : PillTone.danger,
                ),
              ),
            ),
            SizedBox(
              width: actionsWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit)
                      Flexible(
                        child: RowAction(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          color: AppColors.brand,
                          tooltip: 'Edit ${entry.name}',
                          onTap: onEdit,
                        ),
                      ),
                    if (canEdit && canDelete) const SizedBox(width: 8),
                    if (canDelete)
                      Flexible(
                        child: RowAction(
                          icon: Icons.delete_outline,
                          label: 'Delete',
                          color: AppColors.error,
                          tooltip: 'Delete ${entry.name}',
                          onTap: onDelete,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
