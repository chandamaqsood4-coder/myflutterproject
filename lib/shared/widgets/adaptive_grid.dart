import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lays children out in equal-width columns that adapt to the width available.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 240,
    this.maxColumns = 4,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit =
            ((constraints.maxWidth + spacing) / (minItemWidth + spacing))
                .floor();
        final columns = math.max(1, math.min(maxColumns, fit));
        final itemWidth =
            ((constraints.maxWidth - spacing * (columns - 1)) / columns)
                .floorToDouble();
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
