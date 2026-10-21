import 'package:dukan_os/app/shell/app_shell.dart';
import 'package:dukan_os/features/auth/domain/auth_session.dart';
import 'package:dukan_os/features/auth/domain/auth_user.dart';
import 'package:dukan_os/shared/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the signed-in shell at a given size and fails the test if any
/// layout overflows. Overflows only surface at runtime, so this guards the
/// dashboard, sidebar and top bar against narrow windows and long text.
void main() {
  final session = AuthSession(
    token: 'test-token',
    user: AuthUser(
      id: 1,
      name: 'Administrator',
      email: 'admin@dukanos.com',
      status: 'active',
      permissions: const {
        'products.view',
        'customers.manage',
        'sales.view',
        'reports.view',
      },
      createdAt: DateTime(2026, 10, 20),
      role: const AuthRole(id: 1, name: 'Super Admin', slug: 'super_admin'),
    ),
  );

  Future<void> pumpShell(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: AppShell(session: session),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the shell without layout overflow', (
    WidgetTester tester,
  ) async {
    await pumpShell(tester);

    expect(find.text('Dashboard'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders on a narrow window without layout overflow', (
    WidgetTester tester,
  ) async {
    await pumpShell(tester, size: const Size(800, 600));

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at the minimum window size without layout overflow', (
    WidgetTester tester,
  ) async {
    // Matches the minimumSize set in lib/main.dart.
    await pumpShell(tester, size: const Size(480, 640));

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at a large text scale without layout overflow', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpShell(tester);

    expect(tester.takeException(), isNull);
  });
}
