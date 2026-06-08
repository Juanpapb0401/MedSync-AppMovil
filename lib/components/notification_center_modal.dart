import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medsync/features/rutina/ui/bloc/notification_center_bloc.dart';
import 'package:medsync/features/rutina/domain/model/rutina_medicamento_model.dart';
import 'package:medsync/components/app_colors.dart';

class NotificationCenterModal extends StatelessWidget {
  const NotificationCenterModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<NotificationCenterBloc>(),
        child: const NotificationCenterModal(),
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
    return BlocBuilder<NotificationCenterBloc, NotificationCenterState>(
      builder: (context, state) {
        final notifications = state.notifications;
        
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title and Clear All
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notificaciones',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (notifications.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          context.read<NotificationCenterBloc>().add(ClearAllNotifications());
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.dangerText,
                        ),
                        child: Text(
                          'Limpiar',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // List
                Expanded(
                  child: notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: notifications.length,
                          separatorBuilder: (context, _) => const Divider(
                            height: 24,
                            color: Color(0xFFE5E7EB),
                          ),
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(context, notifications[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.primary.withAlpha(80)),
          const SizedBox(height: 16),
          Text(
            'Sin notificaciones recientes',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, RutinaMedicamentoModel intake) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTime.now().isBefore(intake.scheduledDateTime)
                    ? '¡Faltan 5 minutos para tu toma!'
                    : '¡Es hora de tomar tu medicamento!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${intake.medicineName} a las ${_formatTime(intake.scheduledDateTime)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 20),
          onPressed: () {
            context.read<NotificationCenterBloc>().add(RemoveNotification(intake.notificationId));
          },
        ),
      ],
    );
  }
}
