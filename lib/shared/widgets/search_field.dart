import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';

/// Rounded search box. Change its [key] to clear it.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: AppColors.ink),
      cursorColor: AppColors.ink,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 15, color: AppColors.hint),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.brand, 1.5),
      ),
    );
  }
}
