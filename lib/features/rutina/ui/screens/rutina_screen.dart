import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medsync/di/service_locator.dart';
import '../../../../components/app_colors.dart';
import '../../../../components/main_nav_bar.dart';
import '../../../../components/notification_center_modal.dart';
import '../../domain/model/rutina_medicamento_model.dart';
import '../bloc/rutina_bloc.dart';
import '../bloc/notification_center_bloc.dart';

class RutinaScreen extends StatelessWidget {
  const RutinaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RutinaBloc>()..add(LoadRutinaEvent(DateTime.now())),
      child: const _RutinaScreenContent(),
    );
  }
}

class _RutinaScreenContent extends StatelessWidget {
  const _RutinaScreenContent();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<RutinaBloc, RutinaState>(
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mi Rutina',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_getGreeting()}, ${state is RutinaLoadedState ? state.patientName : 'Paciente'}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      BlocBuilder<NotificationCenterBloc, NotificationCenterState>(
                        builder: (context, notifState) {
                          final count = notifState.notifications.length;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
                                  onPressed: () => NotificationCenterModal.show(context),
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.dangerBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      count.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.dangerText,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ── Body ─────────────────────────────────────────────────
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const MainNavBar(
        userRole: 'paciente',
        activeIndex: 0,
      ),
    );
  }

  Widget _buildBody(BuildContext context, RutinaState state) {
    if (state is RutinaLoadingState || state is RutinaInitialState) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (state is RutinaErrorState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 56, color: AppColors.dangerText),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context
                    .read<RutinaBloc>()
                    .add(LoadRutinaEvent(DateTime.now())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is RutinaLoadedState) {
      final routine = state.routine;
      final pending = routine.where((i) => i.isPending).toList();
      final nextPending = pending.isNotEmpty ? pending.first : null;

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<RutinaBloc>().add(LoadRutinaEvent(state.currentDate));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            // ── Pending banner ──────────────────────────────────────
            if (pending.isNotEmpty)
              _PendingBanner(
                count: pending.length,
                nextPending: nextPending,
              ),

            if (pending.isNotEmpty) const SizedBox(height: 16),

            // ── Medication cards ────────────────────────────────────
            if (routine.isEmpty)
              _EmptyState()
            else
              ...routine.map(
                (intake) => _MedicationCard(
                  intake: intake,
                  currentDate: state.currentDate,
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ── Pending Banner ─────────────────────────────────────────────────────────────
class _PendingBanner extends StatelessWidget {
  final int count;
  final RutinaMedicamentoModel? nextPending;

  const _PendingBanner({required this.count, this.nextPending});

  @override
  Widget build(BuildContext context) {
    final nextName = nextPending?.medicineName ?? '';
    final nextTime =
        nextPending != null ? _formatTime(nextPending!.scheduledDateTime) : '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: const Color(0xFFFF6D00),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notification_important_rounded,
                            color: Color(0xFFE65100),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hoy tienes $count toma${count > 1 ? 's' : ''} pendiente${count > 1 ? 's' : ''}',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (nextPending != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Text(
                            'Próxima: $nextName a las $nextTime',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFEF6C00),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
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
}


// ── Medication Card ─────────────────────────────────────────────────────────────
class _MedicationCard extends StatelessWidget {
  final RutinaMedicamentoModel intake;
  final DateTime currentDate;

  const _MedicationCard({
    required this.intake,
    required this.currentDate,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${displayH.toString().padLeft(2, '0')}:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (intake.isPending) {
          final bloc = context.read<RutinaBloc>();
          Navigator.pushNamed(
            context,
            '/rutina/confirmar-toma',
            arguments: {
              'medicamento': intake,
              'currentDate': currentDate,
            },
          ).then((result) {
            if (result == 'tomado') {
              bloc.add(UpdateStatusEvent(
                notificationId: intake.notificationId,
                newStatus: 'tomado',
                date: currentDate,
              ));
            } else if (result == 'recordar') {
              bloc.add(RemindLaterEvent(
                notificationId: intake.notificationId,
                date: currentDate,
              ));
            }
          });
        } else {
          _showStatusSheet(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pill icon circle ──────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + time
                  Text(
                    intake.medicineName,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    _formatTime(intake.scheduledDateTime),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dose
                  Text(
                    'Dosis: ${intake.dose}${intake.unit}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Restrictions + Status badge on same row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ...intake.restrictions.map(
                        (r) => _RestrictionChip(label: r),
                      ),
                      _StatusBadge(status: intake.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context) {
    final bloc = context.read<RutinaBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                intake.medicineName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dosis: ${intake.dose}${intake.unit}',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              _SheetOption(
                icon: Icons.check_circle_outline,
                label: 'Marcar como Tomado',
                color: AppColors.successText,
                bgColor: AppColors.successBg,
                onTap: () {
                  bloc.add(UpdateStatusEvent(
                    notificationId: intake.notificationId,
                    newStatus: 'tomado',
                    date: currentDate,
                  ));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.cancel_outlined,
                label: 'Marcar como Omitido',
                color: AppColors.dangerText,
                bgColor: AppColors.dangerBg,
                onTap: () {
                  bloc.add(UpdateStatusEvent(
                    notificationId: intake.notificationId,
                    newStatus: 'omitido',
                    date: currentDate,
                  ));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.hourglass_empty_rounded,
                label: 'Volver a Pendiente',
                color: const Color(0xFFB45309),
                bgColor: AppColors.warningBg,
                onTap: () {
                  bloc.add(UpdateStatusEvent(
                    notificationId: intake.notificationId,
                    newStatus: 'pendiente',
                    date: currentDate,
                  ));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Restriction Chip ────────────────────────────────────────────────────────────
class _RestrictionChip extends StatelessWidget {
  final String label;
  const _RestrictionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 13,
            color: Color(0xFFEF6C00),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEF6C00),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;

    switch (status) {
      case 'tomado':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        icon = Icons.check_circle_outline;
        label = 'Tomado';
        break;
      case 'omitido':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        icon = Icons.cancel_outlined;
        label = 'Omitido';
        break;
      default: // pendiente / sin_confirmar
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFB45309);
        icon = Icons.hourglass_empty_rounded;
        label = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sheet Option ────────────────────────────────────────────────────────────────
class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: bgColor.withAlpha(140),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.done_all_rounded,
              size: 72,
              color: AppColors.primary.withAlpha(80),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Sin medicamentos hoy!',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No tienes tomas programadas para hoy.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}