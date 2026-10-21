enum InvoiceStatus { paid, partial, ledger }

class RecentInvoice {
  const RecentInvoice({
    required this.number,
    required this.customerName,
    required this.date,
    required this.totalMinor,
    required this.status,
  });

  final String number;
  final String customerName;
  final DateTime date;

  /// Amount in minor units (paisa).
  final int totalMinor;
  final InvoiceStatus status;
}

class DashboardSummary {
  const DashboardSummary({
    required this.storeName,
    required this.todaysSalesMinor,
    required this.monthlyRevenueMinor,
    required this.receivablesMinor,
    required this.lowStockCount,
    required this.recentInvoices,
  });

  final String storeName;
  final int todaysSalesMinor;
  final int monthlyRevenueMinor;
  final int receivablesMinor;
  final int lowStockCount;
  final List<RecentInvoice> recentInvoices;
}
