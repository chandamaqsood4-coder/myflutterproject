import 'package:flutter/material.dart';

/// Sidebar destinations. [permission] is the API permission that gates the
/// item (null = always visible). Confirm the mapping against docs/api.md.
enum NavDestination {
  dashboard('Owner Dashboard', 'Dashboard', Icons.dashboard_outlined, null),
  pos(
    'POS Terminal',
    'POS Terminal',
    Icons.shopping_cart_outlined,
    'invoices.create',
  ),
  products(
    'Products & Stock',
    'Products & Stock',
    Icons.inventory_2_outlined,
    'products.view',
  ),
  catalog(
    'Categories, Brands & Units',
    'Catalog',
    Icons.sell_outlined,
    'products.view',
  ),
  invoices(
    'Invoices',
    'Invoices',
    Icons.receipt_long_outlined,
    'invoices.view',
  ),
  returns(
    'Returns',
    'Returns',
    Icons.assignment_return_outlined,
    'returns.manage',
  ),
  quotations(
    'Quotations',
    'Quotations',
    Icons.request_quote_outlined,
    'quotations.manage',
  ),
  customers(
    'Customers & Ledger',
    'Customers & Ledger',
    Icons.groups_outlined,
    'customers.view',
  ),
  cashflow(
    'Daily Cashflow',
    'Daily Cashflow',
    Icons.account_balance_wallet_outlined,
    'expenses.manage',
  ),
  payroll(
    'Payroll & Salaries',
    'Payroll & Salaries',
    Icons.badge_outlined,
    'payroll.manage',
  ),
  reports(
    'Reports & Analytics',
    'Reports & Analytics',
    Icons.trending_up,
    'reports.view',
  ),
  storeUsers(
    'Store Users',
    'Store Users',
    Icons.manage_accounts_outlined,
    'users.manage',
  );

  const NavDestination(this.label, this.title, this.icon, this.permission);

  /// Text shown in the sidebar.
  final String label;

  /// Text shown in the top bar breadcrumb.
  final String title;
  final IconData icon;
  final String? permission;
}
