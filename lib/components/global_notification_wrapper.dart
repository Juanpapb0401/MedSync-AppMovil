import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medsync/di/service_locator.dart';
import 'package:medsync/features/rutina/domain/services/in_app_notification_service.dart';
import 'package:medsync/features/rutina/domain/model/rutina_medicamento_model.dart';
import 'package:medsync/features/rutina/domain/usecases/update_intake_status_usecase.dart';
import 'package:medsync/features/rutina/domain/usecases/remind_later_usecase.dart';
import 'package:medsync/features/rutina/ui/bloc/rutina_bloc.dart';
import 'dart:async';
import 'app_colors.dart';

class GlobalNotificationWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalNotificationWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<GlobalNotificationWrapper> createState() => _GlobalNotificationWrapperState();
}

class _GlobalNotificationWrapperState extends State<GlobalNotificationWrapper> {
  StreamSubscription<RutinaMedicamentoModel>? _subscription;
  StreamSubscription<RutinaMedicamentoModel>? _alarmSubscription;
  Timer? _alarmSoundTimer;
  bool _isAlarmShowing = false;

  @override
  void initState() {
    super.initState();
    _subscription = sl<InAppNotificationService>()
        .notificationStream
        .listen(_onNotificationFired);
    _alarmSubscription = sl<InAppNotificationService>()
        .alarmStream
        .listen(_onAlarmFired);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _alarmSubscription?.cancel();
    _stopRinging();
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

  void _onAlarmFired(RutinaMedicamentoModel intake) {
    final context = widget.navigatorKey.currentContext;
    if (context == null || _isAlarmShowing) return;
    _isAlarmShowing = true;
    _startRinging();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlarmDialog(
          intake: intake,
          onOpen: () {
            _stopRinging();
            Navigator.pop(dialogContext);
            _isAlarmShowing = false;
            _navigateToConfirmation(intake);
          },
          onSnooze: () {
            _stopRinging();
            Navigator.pop(dialogContext);
            _isAlarmShowing = false;
            _snoozeIntake(intake);
          },
        );
      },
    );
  }

  void _startRinging() {
    _stopRinging();
    _alarmSoundTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.vibrate();
    });
  }

  void _stopRinging() {
    _alarmSoundTimer?.cancel();
    _alarmSoundTimer = null;
  }

  void _navigateToConfirmation(RutinaMedicamentoModel intake) {
    widget.navigatorKey.currentState?.pushNamed(
      '/rutina/confirmar-toma',
      arguments: {
        'medicamento': intake,
        'currentDate': DateTime.now(),
      },
    ).then((result) async {
      if (!mounted) return;
      final navContext = widget.navigatorKey.currentContext;
      if (navContext != null) {
        try {
          // ignore: use_build_context_synchronously
          final bloc = BlocProvider.of<RutinaBloc>(navContext);
          if (result == 'tomado') {
            bloc.add(UpdateStatusEvent(
              notificationId: intake.notificationId,
              newStatus: 'tomado',
              date: DateTime.now(),
            ));
          } else if (result == 'recordar') {
            bloc.add(RemindLaterEvent(
              notificationId: intake.notificationId,
              date: DateTime.now(),
            ));
          }
        } catch (_) {
          // Fallback if RutinaBloc is not in the context
          if (result == 'tomado') {
            await sl<UpdateIntakeStatusUsecase>().execute(intake.notificationId, 'tomado');
            sl<InAppNotificationService>().clearAlarm(intake.notificationId);
          } else if (result == 'recordar') {
            await sl<RemindLaterUsecase>().execute(intake.notificationId);
            sl<InAppNotificationService>().snooze(intake.notificationId);
          }
        }
      }
    });
  }

  void _snoozeIntake(RutinaMedicamentoModel intake) async {
    final navContext = widget.navigatorKey.currentContext;
    if (navContext != null) {
      try {
        final bloc = BlocProvider.of<RutinaBloc>(navContext);
        bloc.add(RemindLaterEvent(
          notificationId: intake.notificationId,
          date: DateTime.now(),
        ));
      } catch (_) {
        // Fallback if RutinaBloc is not in the context
        await sl<RemindLaterUsecase>().execute(intake.notificationId);
        sl<InAppNotificationService>().snooze(intake.notificationId);
      }
    }
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
    return widget.child;
  }
}

class AlarmDialog extends StatefulWidget {
  final RutinaMedicamentoModel intake;
  final VoidCallback onOpen;
  final VoidCallback onSnooze;

  const AlarmDialog({
    super.key,
    required this.intake,
    required this.onOpen,
    required this.onSnooze,
  });

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: PopScope(
        canPop: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ringing Animation
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.primary,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '🚨 ¡Alarma de toma!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dangerText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Es hora de tomar tu medicamento',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // Medicine Detail Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(120),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withAlpha(40)),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.intake.medicineName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(widget.intake.scheduledDateTime),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dosis: ${widget.intake.dose} ${widget.intake.unit}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: widget.onOpen,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    'Ver y Confirmar',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: widget.onSnooze,
                  icon: const Icon(Icons.alarm_rounded, color: Color(0xFFB45309)),
                  label: Text(
                    'Recordar en 2 minutos',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF9C3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFFFFCC80)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Si no confirmas, tu cuidador será notificado después de 2 recordatorios.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

