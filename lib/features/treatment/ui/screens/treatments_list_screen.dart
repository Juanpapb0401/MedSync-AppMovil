import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/components.dart';
import '../../domain/model/treatment_model.dart';
import '../bloc/treatments_list_bloc.dart';
import '../widgets/treatment_list_card.dart';

class TreatmentsListScreen extends StatelessWidget {
  const TreatmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TreatmentsListBloc()..add(LoadTreatmentsEvent()),
      child: const _TreatmentsListView(),
    );
  }
}

class _TreatmentsListView extends StatelessWidget {
  const _TreatmentsListView();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: BlocBuilder<TreatmentsListBloc, TreatmentsListState>(
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
                                      item: item,
                                      onEdit: () {
                                        _openEditScreen(
                                          context,
                                          item.id,
                                          item.treatment,
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