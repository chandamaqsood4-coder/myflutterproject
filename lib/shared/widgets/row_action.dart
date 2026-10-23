import 'package:flutter/material.dart';

/// Compact icon (+ optional label) action used at the end of table rows.
class RowAction extends StatelessWidget {
  const RowAction({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
