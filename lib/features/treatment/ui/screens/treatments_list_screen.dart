import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medsync/di/service_locator.dart';
import '../../../../components/components.dart';
import '../../domain/model/treatment_model.dart';
import '../bloc/treatments_list_bloc.dart';
import '../widgets/treatment_list_card.dart';

class TreatmentsListScreen extends StatelessWidget {
  const TreatmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TreatmentsListBloc>()..add(LoadTreatmentsEvent()),
      child: const _TreatmentsListView(),
    );
  }
}

class _TreatmentsListView extends StatefulWidget {
  const _TreatmentsListView();

  @override
  State<_TreatmentsListView> createState() => _TreatmentsListViewState();
}

class _TreatmentsListViewState extends State<_TreatmentsListView> {
  String? _pendingToastMessage;

  Future<void> _openEditScreen(
    BuildContext context,
    String treatmentId,
    TreatmentModel treatment,
    String patientName,
  ) async {
    await Navigator.pushNamed(
      context,
      '/tratamientos/editar',
      arguments: {
        'treatmentId': treatmentId,
        'treatment': treatment,
        'patientName': patientName,
      },
    );

    if (context.mounted) {
      context.read<TreatmentsListBloc>().add(LoadTreatmentsEvent());
    }
  }

  void _deleteTreatment(
    BuildContext context,
    String treatmentId,
    String medicineName,
    String patientName,
  ) {
    _pendingToastMessage =
        'Medicamento eliminado — $medicineName fue removido del plan de $patientName';

    context.read<TreatmentsListBloc>().add(
      DeleteTreatmentEvent(
        treatmentId: treatmentId,
        medicineName: medicineName,
        patientName: patientName,
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          _NotificationBanner(message: message, onDismiss: () => entry.remove()),
        ],
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: BlocConsumer<TreatmentsListBloc, TreatmentsListState>(
          listener: (context, state) {
            if (state is TreatmentsListLoadedState && _pendingToastMessage != null) {
              _showToast(context, _pendingToastMessage!);
              _pendingToastMessage = null;
            }
          },
          builder: (context, state) {
            if (state is TreatmentsListLoadingState ||
                state is TreatmentsListInitialState) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is TreatmentsListErrorState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is TreatmentsListLoadedState) {
              final treatments = state.result.treatments;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MedSyncBackButton(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ver Tratamientos',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Paciente: ${state.result.patientName}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${treatments.length} medicamentos configurados',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: treatments.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hay medicamentos configurados todavía',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 110),
                                  itemCount: treatments.length,
                                  separatorBuilder: (context, separatorIndex) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = treatments[index];
                                    return TreatmentListCard(
                                      key: ValueKey(item.id),
                                      item: item,
                                      onEdit: () {
                                        _openEditScreen(
                                          context,
                                          item.id,
                                          item.treatment,
                                          state.result.patientName,
                                        );
                                      },
                                      onDelete: () {
                                        _deleteTreatment(
                                          context,
                                          item.id,
                                          item.treatment.medicineName,
                                          state.result.patientName,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/tratamientos/crear');
          if (context.mounted) {
            context.read<TreatmentsListBloc>().add(LoadTreatmentsEvent());
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const MainNavBar(
        userRole: 'cuidador',
        activeIndex: 0,
      ),
    );
  }
}

class _NotificationBanner extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _NotificationBanner({required this.message, required this.onDismiss});

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 6,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _controller.reverse().then((_) => widget.onDismiss());
                    },
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
