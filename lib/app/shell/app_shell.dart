import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_session.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/catalog/presentation/catalog_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/products/presentation/products_page.dart';
import '../../shared/design_system/app_colors.dart';
import 'coming_soon_page.dart';
import 'nav_destination.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// Signed-in layout: sidebar + top bar + the selected page.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.session});

  final AuthSession session;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  NavDestination _selected = NavDestination.dashboard;
  bool _collapsed = false;

  void _toggleSidebar() => setState(() => _collapsed = !_collapsed);

  void _select(NavDestination destination) =>
      setState(() => _selected = destination);

  Widget _pageFor(NavDestination destination) => switch (destination) {
    NavDestination.dashboard => DashboardPage(onNavigate: _select),
    NavDestination.products => const ProductsPage(),
    NavDestination.catalog => const CatalogPage(),
    _ => ComingSoonPage(title: destination.label),
  };

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user;
    final storeName = ref.watch(dashboardSummaryProvider).storeName;
    final roleName = user.role?.name ?? 'User';

    final items = NavDestination.values
        .where((d) => d.permission == null || user.hasPermission(d.permission!))
        .toList();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyB, control: true):
            _toggleSidebar,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 900;
              final collapsed = _collapsed || narrow;
              final contentWidth =
                  constraints.maxWidth -
                  (collapsed ? Sidebar.collapsedWidth : Sidebar.expandedWidth);

              return Row(
                children: [
                  Sidebar(
                    items: items,
                    selected: _selected,
                    onSelect: _select,
                    collapsed: collapsed,
                    canToggle: !narrow,
                    onToggle: _toggleSidebar,
                    storeName: storeName,
                    roleLabel: roleName,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        TopBar(
                          title: _selected.title,
                          storeName: storeName,
                          userName: user.name,
                          userEmail: user.email,
                          roleName: roleName,
                          onSignOut: () =>
                              ref.read(sessionProvider.notifier).signOut(),
                          showStore: contentWidth > 720,
                          showUserDetails: contentWidth > 520,
                        ),
                        Expanded(
                          child: ColoredBox(
                            color: AppColors.pageBg,
                            child: _pageFor(_selected),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
