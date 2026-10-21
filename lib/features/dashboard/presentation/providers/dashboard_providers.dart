import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_dashboard_data.dart';
import '../../domain/dashboard_summary.dart';

/// UI preview: serves mock data. Swap for a repository-backed provider
/// (reading the local database) without touching the widgets.
final dashboardSummaryProvider = Provider<DashboardSummary>(
  (ref) => mockDashboardSummary,
);
