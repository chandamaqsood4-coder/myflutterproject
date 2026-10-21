import 'package:flutter/material.dart';

import '../../shared/design_system/app_colors.dart';
import '../../shared/widgets/dukanos_logo.dart';
import 'nav_destination.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.collapsed,
    required this.canToggle,
    required this.onToggle,
    required this.storeName,
    required this.roleLabel,
  });

  static const double expandedWidth = 256;
  static const double collapsedWidth = 76;

  final List<NavDestination> items;
  final NavDestination selected;
  final ValueChanged<NavDestination> onSelect;
  final bool collapsed;
  final bool canToggle;
  final VoidCallback onToggle;
  final String storeName;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: collapsed ? collapsedWidth : expandedWidth,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 72,
              child: Center(
                child: DukanOsLogo(
                  height: collapsed ? 32 : 36,
                  iconOnly: collapsed,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _NavTile(
                        item: item,
                        selected: item == selected,
                        collapsed: collapsed,
                        onTap: () => onSelect(item),
                      ),
                    ),
                ],
              ),
            ),
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        roleLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (canToggle) ...[
              const Divider(height: 1, color: AppColors.border),
              _CollapseTile(collapsed: collapsed, onTap: onToggle),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final NavDestination item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.chipNeutralFg;

    final tile = Material(
      color: selected ? AppColors.ink : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: selected ? Colors.transparent : AppColors.hoverFill,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 14,
            vertical: 11,
          ),
          child: collapsed
              ? Center(child: Icon(item.icon, size: 20, color: color))
              : Row(
                  children: [
                    Icon(item.icon, size: 20, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: collapsed ? Tooltip(message: item.label, child: tile) : tile,
    );
  }
}

class _CollapseTile extends StatelessWidget {
  const _CollapseTile({required this.collapsed, required this.onTap});

  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      collapsed
          ? Icons.keyboard_double_arrow_right
          : Icons.keyboard_double_arrow_left,
      size: 20,
      color: AppColors.textSecondary,
    );

    return Tooltip(
      message: collapsed ? 'Expand sidebar (Ctrl+B)' : 'Collapse sidebar',
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.hoverFill,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 20,
            vertical: 16,
          ),
          child: collapsed
              ? Center(child: icon)
              : Row(
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Collapse',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chipNeutralBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Ctrl+B',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
