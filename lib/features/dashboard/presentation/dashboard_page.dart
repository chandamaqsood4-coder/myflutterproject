import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/nav_destination.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design_system/app_colors.dart';
import '../../../shared/widgets/adaptive_grid.dart';
import 'providers/dashboard_providers.dart';
import 'widgets/kpi_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/recent_invoices_section.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    super.key,
    required this.onNavigate,
    required this.permissions,
  });

  final ValueChanged<NavDestination> onNavigate;
  final Set<String> permissions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final canCreateInvoice = permissions.contains('invoices.create');
    final canCreateProduct = permissions.contains('products.create');
    final canManageCustomers = permissions.contains('customers.manage');
    final canManageExpenses = permissions.contains('expenses.manage');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Owner Dashboard',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (canCreateInvoice)
                    ElevatedButton.icon(
                      onPressed: () => onNavigate(NavDestination.pos),
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text(
                        'Launch POS',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 21,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                "Today's snapshot for ${summary.storeName}",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              AdaptiveGrid(
                children: [
                  KpiCard(
                    label: "Today's Sales",
                    value: formatPkr(summary.todaysSalesMinor),
                    icon: Icons.attach_money,
                    iconColor: AppColors.brand,
                    footerLabel: 'Collected today',
                    footerNote: 'vs yesterday',
                  ),
                  KpiCard(
                    label: 'Monthly Revenue',
                    value: formatPkr(summary.monthlyRevenueMinor),
                    icon: Icons.north_east,
                    footerLabel: 'Collected this month',
                    footerNote: 'vs last month',
                  ),
                  KpiCard(
                    label: 'Customer Receivables',
                    value: formatPkr(summary.receivablesMinor),
                    icon: Icons.groups_outlined,
                    iconColor: AppColors.accentAmber,
                    footerLabel: 'On-account ledgers',
                  ),
                  KpiCard(
                    label: 'Low Stock Watchlist',
                    value: '${summary.lowStockCount}',
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.error,
                    footerLabel: 'Requires purchase order',
                    tone: KpiTone.danger,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AdaptiveGrid(
                minItemWidth: 280,
                maxColumns: 4,
                spacing: 16,
                children: [
                  if (canCreateInvoice)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 90),
                      child: QuickActionCard(
                        icon: Icons.shopping_cart_outlined,
                        title: 'New POS Invoice',
                        subtitle: 'High speed counter sales',
                        onTap: () => onNavigate(NavDestination.pos),
                      ),
                    ),
                  if (canCreateProduct)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 90),
                      child: QuickActionCard(
                        icon: Icons.add,
                        title: 'Add Catalog Product',
                        subtitle: 'Item & electrical specs',
                        onTap: () => onNavigate(NavDestination.products),
                      ),
                    ),
                  if (canManageCustomers)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 90),
                      child: QuickActionCard(
                        icon: Icons.person_add_alt_outlined,
                        title: 'Customer Account',
                        subtitle: 'Ledgers & credit terms',
                        onTap: () => onNavigate(NavDestination.customers),
                      ),
                    ),
                  if (canManageExpenses)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 90),
                      child: QuickActionCard(
                        icon: Icons.credit_card_outlined,
                        title: 'Daily Cashflow',
                        subtitle: 'Operational income/expense',
                        onTap: () => onNavigate(NavDestination.cashflow),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              RecentInvoicesSection(
                invoices: summary.recentInvoices,
                onViewAll: () => onNavigate(NavDestination.invoices),
                onOpenInvoice: (_) => onNavigate(NavDestination.invoices),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
