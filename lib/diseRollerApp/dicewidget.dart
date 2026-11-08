import 'package:flutter/material.dart';

class DiceWidget extends StatelessWidget {
  final int value;
  final Color color;
  final double size;

  const DiceWidget({
    super.key,
    required this.value,
    this.color = const Color(0xFF9575CD),
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final positions = <int, List<Alignment>>{
      1: [Alignment.center],
      2: [Alignment.topLeft, Alignment.bottomRight],
      3: [Alignment.topLeft, Alignment.center, Alignment.bottomRight],
      4: [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
      5: [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.center,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
      6: [
        Alignment.topLeft,
        Alignment.centerLeft,
        Alignment.bottomLeft,
        Alignment.topRight,
        Alignment.centerRight,
        Alignment.bottomRight,
      ],
    };

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Stack(
        children: (positions[value] ?? positions[1]!)
            .map(
              (alignment) => Align(
                alignment: alignment,
                child: Container(
                  width: size * 0.15,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
