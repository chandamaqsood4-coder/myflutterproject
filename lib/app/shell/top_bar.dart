import 'package:flutter/material.dart';

import '../../shared/design_system/app_colors.dart';
import 'user_menu.dart';

class TopBar extends StatelessWidget {
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
  });

  final String title;
  final String storeName;
  final String userName;
  final String userEmail;
  final String roleName;
  final VoidCallback onSignOut;
  final bool showStore;
  final bool showUserDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.home_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          const Spacer(),
          if (showStore) ...[
            _StorePill(name: storeName),
            const SizedBox(width: 20),
          ],
          UserMenu(
            name: userName,
            email: userEmail,
            roleName: roleName,
            onSignOut: onSignOut,
            showDetails: showUserDetails,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
