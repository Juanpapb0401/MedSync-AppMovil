import 'package:flutter/material.dart';
import 'app_colors.dart';

// AM-31 — DS-03 BackButton circular
// 40x40, fondo #F3F4F6, flecha izquierda #1A1A1A
// Si onPressed es null → Navigator.pop(context)
class MedSyncBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const MedSyncBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed ?? () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4F6),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          elevation: 0,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}
