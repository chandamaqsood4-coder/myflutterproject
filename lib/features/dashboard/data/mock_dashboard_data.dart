import '../domain/dashboard_summary.dart';

/// Demo data for the UI preview only.
/// TODO: replace with a repository that reads the local database.
final DashboardSummary mockDashboardSummary = DashboardSummary(
  storeName: 'Demo Retail Store',
  todaysSalesMinor: 0,
  monthlyRevenueMinor: 5430000,
  receivablesMinor: 34909660,
  lowStockCount: 2,
  recentInvoices: [
    RecentInvoice(
      number: 'INV-0035',
      customerName: 'Tariq Javed',
      date: DateTime(2026, 8, 28),
      totalMinor: 17200000,
      status: InvoiceStatus.partial,
    ),
    RecentInvoice(
      number: 'INV-0034',
      customerName: 'Walk-in Customer',
      date: DateTime(2026, 8, 25),
      totalMinor: 1542000,
      status: InvoiceStatus.paid,
    ),
    RecentInvoice(
      number: 'INV-0033',
      customerName: 'Muhammad Aslam',
      date: DateTime(2026, 8, 22),
      totalMinor: 8760800,
      status: InvoiceStatus.ledger,
    ),
    RecentInvoice(
      number: 'INV-0032',
      customerName: 'Zafar Iqbal',
      date: DateTime(2026, 8, 20),
      totalMinor: 1970000,
      status: InvoiceStatus.paid,
    ),
  ],
);
