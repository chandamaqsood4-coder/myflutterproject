import 'package:flutter/material.dart';

import '../../shared/design_system/app_colors.dart';
import 'user_menu.dart';

class BreadcrumbItem {
  const BreadcrumbItem({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

class TopBar extends StatefulWidget {
  const TopBar({
    super.key,
    required this.title,
    required this.storeName,
    required this.userName,
    required this.userEmail,
    required this.roleName,
    required this.onSignOut,
    this.showStore = true,
    this.showUserDetails = true,
    this.breadcrumbs,
  });

  final String title;
  final String storeName;
  final String userName;
  final String userEmail;
  final String roleName;
  final VoidCallback onSignOut;
  final bool showStore;
  final bool showUserDetails;
  final List<BreadcrumbItem>? breadcrumbs;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmallScreen = constraints.maxWidth < 900;

          return Row(
            children: [
              const Icon(
                Icons.home_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 6),

              if (widget.breadcrumbs != null && widget.breadcrumbs!.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.breadcrumbs!.length; i++) ...[
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        if (i == widget.breadcrumbs!.length - 1)
                          Flexible(
                            child: Text(
                              widget.breadcrumbs![i].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          )
                        else ...[
                          InkWell(
                            onTap: widget.breadcrumbs![i].onTap,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Text(
                                widget.breadcrumbs![i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ],
                  ),
                )
              else ...[
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],

              Transform.translate(
                offset: Offset(isSmallScreen ? 0 : 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showStore) ...[
                      _StorePill(name: widget.storeName),
                      const SizedBox(width: 8),
                    ],

                    UserMenu(
                      name: widget.userName,
                      email: widget.userEmail,
                      roleName: widget.roleName,
                      onSignOut: widget.onSignOut,
                      showDetails: widget.showUserDetails,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StorePill extends StatelessWidget {
  const _StorePill({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 16, color: AppColors.brand),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
