import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Muestra el nivel de dificultad como puntos de colores.
class DifficultyIndicator extends StatelessWidget {
  final int difficulty; // 1, 2 o 3

  const DifficultyIndicator({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        Color color;
        if (i < difficulty) {
          switch (difficulty) {
            case 1:
              color = AppColors.difficultyEasy;
            case 2:
              color = AppColors.difficultyMedium;
            default:
              color = AppColors.difficultyHard;
          }
        } else {
          color = AppColors.lightGray;
        }
        return Container(
          margin: const EdgeInsets.only(right: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      }),
    );
  }
}
