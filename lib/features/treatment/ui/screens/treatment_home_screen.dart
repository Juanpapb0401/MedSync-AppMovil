import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import '../../../../components/main_nav_bar.dart';
import '../bloc/treatment_summary_bloc.dart';
import '../widgets/active_medicines_card.dart';
import '../widgets/action_card.dart';

class TreatmentHomeScreen extends StatelessWidget {
  const TreatmentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TreatmentSummaryBloc()..add(LoadTreatmentSummaryEvent()),
      child: const _TreatmentHomeView(),
    );
  }
}

class _TreatmentHomeView extends StatelessWidget {
  const _TreatmentHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tratamiento',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TreatmentSummaryBloc, TreatmentSummaryState>(
        builder: (context, state) {
          if (state is TreatmentSummaryLoadingState ||
              state is TreatmentSummaryInitialState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is TreatmentSummaryErrorState) {
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
          if (state is TreatmentSummaryLoadedState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Paciente: ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: state.summary.patientName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ActiveMedicinesCard(count: state.summary.activeMedicinesCount),
                  const SizedBox(height: 32),
                  Text(
                    'Acciones',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ActionCard(
                    icon: Icons.list_alt,
                    title: 'Ver Tratamientos',
                    description: 'Consulta y edita los medicamentos configurados',
                    onTap: () => Navigator.pushNamed(context, '/tratamientos/lista'),
                  ),
                  const SizedBox(height: 12),
                  ActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Crear Nuevo Tratamiento',
                    description: 'Agrega un nuevo medicamento al plan',
                    onTap: () => Navigator.pushNamed(context, '/tratamientos/crear'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const MainNavBar(
        userRole: 'cuidador',
        activeIndex: 0,
      ),
    );
  }
}