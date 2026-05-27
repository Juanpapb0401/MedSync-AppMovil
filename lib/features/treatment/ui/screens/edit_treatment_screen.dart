import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medsync/di/service_locator.dart';
import '../../../../components/app_colors.dart';
import '../../../../components/medsync_back_button.dart';
import '../../../../components/medsync_button.dart';
import '../../domain/model/treatment_model.dart';
import '../bloc/edit_treatment_bloc.dart';
import '../widgets/configuration_section.dart';
import '../widgets/restrictions_section.dart';

class EditTreatmentScreen extends StatelessWidget {
  final String treatmentId;
  final TreatmentModel initialTreatment;
  final String patientName;

  const EditTreatmentScreen({
    super.key,
    required this.treatmentId,
    required this.initialTreatment,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditTreatmentBloc(
        sl(),
        treatmentId,
        initialTreatment,
      ),
      child: _EditTreatmentView(
        treatmentId: treatmentId,
        initialTreatment: initialTreatment,
        patientName: patientName,
      ),
    );
  }
}

class _EditTreatmentView extends StatelessWidget {
  final String treatmentId;
  final TreatmentModel initialTreatment;
  final String patientName;

  const _EditTreatmentView({
    required this.treatmentId,
    required this.initialTreatment,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditTreatmentBloc, EditTreatmentState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tratamiento actualizado exitosamente'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context, true);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.dangerText,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<EditTreatmentBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        MedSyncBackButton(
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editar Tratamiento',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navbarBackground,
                              ),
                            ),
                            Text(
                              'Paciente: $patientName',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE047), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Color(0xFFCA8A04), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Editando: ${initialTreatment.medicineName}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFCA8A04),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    _EditFormSection(bloc: bloc, state: state),
                    const SizedBox(height: 32),

                    _EditRestrictionsSection(bloc: bloc, state: state),
                    const SizedBox(height: 48),

                    MedSyncButton(
                      label: 'Guardar cambios',
                      isLoading: state.isLoading,
                      onPressed: state.isLoading ? null : () => bloc.add(EditSaveRequested()),
                      leadingIcon: Icons.edit,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EditFormSection extends StatelessWidget {
  final EditTreatmentBloc bloc;
  final EditTreatmentState state;

  const _EditFormSection({required this.bloc, required this.state});

  @override
  Widget build(BuildContext context) {
    return ConfigurationSection(
      medicineController: TextEditingController(text: state.medicineName),
      doseController: TextEditingController(text: state.dose),
      selectedUnit: state.unit,
      selectedFrequency: state.frequency,
      startTime: state.startTime,
      onUnitChanged: (val) => bloc.add(EditUpdateUnit(val)),
      onFrequencyChanged: (val) => bloc.add(EditUpdateFrequency(val)),
      onStartTimeTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null && context.mounted) {
          bloc.add(EditUpdateStartTime(picked.format(context)));
        }
      },
    );
  }
}

class _EditRestrictionsSection extends StatelessWidget {
  final EditTreatmentBloc bloc;
  final EditTreatmentState state;

  const _EditRestrictionsSection({required this.bloc, required this.state});

  @override
  Widget build(BuildContext context) {
    return RestrictionsSection(
      selectedRestrictions: state.restrictions,
      onAdd: (restriction) => bloc.add(EditAddRestriction(restriction)),
      onRemove: (restriction) => bloc.add(EditRemoveRestriction(restriction)),
    );
  }
}
