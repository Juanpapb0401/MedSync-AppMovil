import 'package:flutter/material.dart';
import 'app_colors.dart';

// AM-35 — DS-07 OnboardingProgressDots
// Dot activo: pill #049B83, ~20px ancho
// Dots inactivos: círculo #E5E7EB, 8px, gap 6px
// Animación al cambiar dot activo
class OnboardingProgressDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OnboardingProgressDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
