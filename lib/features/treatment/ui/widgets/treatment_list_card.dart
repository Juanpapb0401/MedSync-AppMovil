import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/app_colors.dart';
import '../../domain/model/treatment_list_model.dart';

class TreatmentListCard extends StatefulWidget {
  final TreatmentListItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TreatmentListCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TreatmentListCard> createState() => _TreatmentListCardState();
}

class _TreatmentListCardState extends State<TreatmentListCard>
    with TickerProviderStateMixin {
  static const _deleteDuration = Duration(seconds: 4);

  bool _isConfirmingDelete = false;
  AnimationController? _deleteTimer;

  void _requestDelete() {
    _deleteTimer?.dispose();
    _deleteTimer = AnimationController(
      vsync: this,
      duration: _deleteDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDelete();
        }
      });
    _deleteTimer!.forward();
    setState(() => _isConfirmingDelete = true);
  }

  void _undoDelete() {
    _deleteTimer?.stop();
    _deleteTimer?.dispose();
    _deleteTimer = null;
    setState(() => _isConfirmingDelete = false);
  }

  @override
  void dispose() {
    _deleteTimer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isConfirmingDelete ? AppColors.dangerText : AppColors.cardBorder,
          width: _isConfirmingDelete ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _isConfirmingDelete ? _buildConfirmState() : _buildNormalState(),
    );
  }

  Widget _buildNormalState() {
    final treatment = widget.item.treatment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.medication_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment.medicineName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${treatment.dose} ${treatment.unit}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIcon(
                  icon: Icons.edit_outlined,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primaryLight,
                  onTap: widget.onEdit,
                ),
                const SizedBox(width: 8),
                _ActionIcon(
                  icon: Icons.delete_outline,
                  color: AppColors.dangerText,
                  backgroundColor: AppColors.dangerBg,
                  onTap: _requestDelete,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ChipLabel(
              icon: Icons.bolt,
              text: treatment.frequency,
              backgroundColor: const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              textColor: const Color(0xFFEA8C00),
            ),
            _ChipLabel(
              icon: Icons.schedule,
              text: treatment.startTime,
              backgroundColor: const Color(0xFFF3F4F6),
              borderColor: const Color(0xFFE5E7EB),
              textColor: const Color(0xFF6B7280),
            ),
            ...treatment.restrictions.map(
              (restriction) => _ChipLabel(
                icon: Icons.circle,
                text: restriction,
                backgroundColor: const Color(0xFFFFF7ED),
                borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                textColor: const Color(0xFFEA8C00),
                iconSize: 8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmState() {
    final treatment = widget.item.treatment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.dangerText,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¿Estás seguro? Se eliminará ${treatment.medicineName}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _deleteTimer!,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _deleteTimer!.value,
                backgroundColor: AppColors.dangerBg,
                valueColor: const AlwaysStoppedAnimation(AppColors.dangerText),
                minHeight: 6,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _undoDelete,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
            child: Text(
              'Deshacer',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double iconSize;

  const _ChipLabel({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.iconSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
