import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/model/daily_notification_model.dart';

class MedicationListItem extends StatelessWidget {
  final DailyNotificationModel notification;

  const MedicationListItem({super.key, required this.notification});

  Color get _dotColor {
    switch (notification.status) {
      case 'tomado':
        return const Color(0xFF16a34a);
      case 'omitido':
      case 'sin_confirmar':
        return const Color(0xFFdc2626);
      case 'pendiente':
      default:
        return const Color(0xFFd97706);
    }
  }

  Color get _badgeBg {
    switch (notification.status) {
      case 'tomado':
        return const Color(0xFFdcfce7);
      case 'omitido':
      case 'sin_confirmar':
        return const Color(0xFFfee2e2);
      case 'pendiente':
      default:
        return const Color(0xFFfef3c7);
    }
  }

  Color get _badgeText {
    switch (notification.status) {
      case 'tomado':
        return const Color(0xFF16a34a);
      case 'omitido':
      case 'sin_confirmar':
        return const Color(0xFFdc2626);
      case 'pendiente':
      default:
        return const Color(0xFFd97706);
    }
  }

  String get _badgeLabel {
    switch (notification.status) {
      case 'tomado':
        return 'Tomado';
      case 'omitido':
        return 'Omitido';
      case 'sin_confirmar':
        return 'Sin confirmar';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }

  String get _formattedTime {
    final dt = notification.scheduledDateTime;
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFf3f4f6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.medicineName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  _formattedTime,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF99a1af),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _badgeLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
