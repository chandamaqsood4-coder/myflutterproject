import 'package:dukan_os/features/auth/domain/auth_exception.dart';
import 'package:dukan_os/features/auth/domain/auth_repository.dart';
import 'package:dukan_os/features/auth/domain/auth_session.dart';
import 'package:dukan_os/features/auth/domain/auth_user.dart';
import 'package:dukan_os/features/auth/presentation/login_screen.dart';
import 'package:dukan_os/features/auth/presentation/providers/auth_providers.dart';
import 'package:dukan_os/shared/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository double so widget tests never touch the network or the OS
/// credential store.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.error});

  /// When set, [signIn] fails with this error.
  final AuthException? error;

  String? lastEmail;
  String? lastPassword;
  bool? lastRememberMe;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    lastEmail = email;
    lastPassword = password;
    lastRememberMe = rememberMe;
    final failure = error;
    if (failure != null) throw failure;
    return _session;
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> signOut() async {}

  static final AuthSession _session = AuthSession(
    token: 'test-token',
    user: AuthUser(
      id: 1,
      name: 'Admin',
      email: 'admin@dukanos.com',
      status: 'active',
      permissions: const {'products.view'},
      createdAt: null,
    ),
  );
}

Widget _harness(_FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
  );
}

void main() {
  testWidgets('renders the login form', (WidgetTester tester) async {
    await tester.pumpWidget(_harness(_FakeAuthRepository()));
    await tester.pump();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Forgot Password'), findsOneWidget);
  });

  testWidgets('shows validation errors on empty submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeAuthRepository()));
    await tester.pump();

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Read the errors from the form fields rather than the rendered text: the
    // field hint and the error message are the same string.
    final fields = tester.stateList<FormFieldState<String>>(
      find.byType(TextFormField),
    );
    expect(
      fields.map((field) => field.errorText),
      containsAll(<String>['Enter your email', 'Enter your password']),
    );
  });

  testWidgets('shows the server error message on failed sign in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        _FakeAuthRepository(
          error: const AuthException(
            AuthFailureType.invalidCredentials,
            'Incorrect email or password.',
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your email'),
      'admin@dukanos.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'secret',
    );
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('passes the typed credentials to the repository', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_harness(repository));
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your email'),
      '  admin@dukanos.com  ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'secret',
    );
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump();

    expect(repository.lastEmail, 'admin@dukanos.com');
    expect(repository.lastPassword, 'secret');
    expect(repository.lastRememberMe, isFalse);
  });
}
