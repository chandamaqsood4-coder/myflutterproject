import 'package:dukan_os/features/dashboard/presentation/dashboard_page.dart';
import 'package:dukan_os/shared/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpDashboard(
    WidgetTester tester, {
    required Set<String> permissions,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: DashboardPage(onNavigate: (_) {}, permissions: permissions),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows POS actions when the user can create invoices', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      permissions: const {'invoices.create', 'products.create'},
    );

    expect(find.text('Launch POS'), findsOneWidget);
    expect(find.text('New POS Invoice'), findsOneWidget);
    expect(find.text('Add Catalog Product'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides actions the user has no permission for', (tester) async {
    await pumpDashboard(tester, permissions: const {'customers.manage'});

    expect(find.text('Launch POS'), findsNothing);
    expect(find.text('New POS Invoice'), findsNothing);
    expect(find.text('Add Catalog Product'), findsNothing);
    expect(find.text('Daily Cashflow'), findsNothing);
    expect(find.text('Customer Account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides the action grid when the user has no permissions', (
    tester,
  ) async {
    await pumpDashboard(tester, permissions: const {});

    expect(find.text('Launch POS'), findsNothing);
    expect(find.text('Customer Account'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
