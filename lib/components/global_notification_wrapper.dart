import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medsync/di/service_locator.dart';
import 'package:medsync/features/rutina/domain/services/in_app_notification_service.dart';
import 'package:medsync/features/rutina/domain/model/rutina_medicamento_model.dart';
import 'dart:async';
import 'app_colors.dart';

class GlobalNotificationWrapper extends StatefulWidget {
  final Widget child;

  const GlobalNotificationWrapper({super.key, required this.child});

  @override
  State<GlobalNotificationWrapper> createState() => _GlobalNotificationWrapperState();
}

class _GlobalNotificationWrapperState extends State<GlobalNotificationWrapper> {
  StreamSubscription<RutinaMedicamentoModel>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = sl<InAppNotificationService>()
        .notificationStream
        .listen(_onNotificationFired);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onNotificationFired(RutinaMedicamentoModel intake) {
    if (!mounted) return;

    final formattedTime = _formatTime(intake.scheduledDateTime);
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    
    if (scaffoldMessenger == null) return;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.access_time_filled_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Prepárate!',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Faltan 5 minutos para tu toma de ${intake.medicineName} a las $formattedTime.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${displayH.toString().padLeft(2, '0')}:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    // The wrapper just passes the child along, creating a UI layer point of listening
    return widget.child;
  }
}
