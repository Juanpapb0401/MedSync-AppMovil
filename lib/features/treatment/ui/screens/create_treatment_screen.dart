import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../components/components.dart';
import '../../../../components/app_colors.dart';
import '../bloc/create_treatment_bloc.dart';
import '../widgets/treatment_form_header.dart';
import '../widgets/configuration_section.dart';
import '../widgets/restrictions_section.dart';

class CreateTreatmentScreen extends StatefulWidget {
  const CreateTreatmentScreen({super.key});

  @override
  State<CreateTreatmentScreen> createState() => _CreateTreatmentScreenState();
}

class _CreateTreatmentScreenState extends State<CreateTreatmentScreen> {
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  @override
  void dispose() {
    _medicineController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateTreatmentBloc(),
      child: BlocConsumer<CreateTreatmentBloc, CreateTreatmentState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tratamiento guardado con éxito'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context); // O navegar a la lista
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
          final bloc = context.read<CreateTreatmentBloc>();

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Column(
              children: [
                TreatmentFormHeader(
                  patientName: 'Juan Pérez', // Podría venir por argumentos
                  onCancel: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        ConfigurationSection(
                          medicineController: _medicineController,
                          doseController: _doseController,
                          selectedUnit: state.unit,
                          selectedFrequency: state.frequency,
                          startTime: state.startTime,
                          onUnitChanged: (val) => bloc.add(UpdateUnit(val)),
                          onFrequencyChanged: (val) => bloc.add(UpdateFrequency(val)),
                          onStartTimeTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppColors.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              final formatted = picked.format(context);
                              bloc.add(UpdateStartTime(formatted));
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        RestrictionsSection(
                          selectedRestrictions: state.restrictions,
                          onAdd: (val) => bloc.add(AddRestriction(val)),
                          onRemove: (val) => bloc.add(RemoveRestriction(val)),
                        ),
                        const SizedBox(height: 48),
                        MedSyncButton(
                          label: 'Guardar tratamiento',
                          isLoading: state.isLoading,
                          leadingIcon: Icons.medication_outlined, // Icono de píldora
                          onPressed: () {
                            bloc.add(UpdateMedicineName(_medicineController.text));
                            bloc.add(UpdateDose(_doseController.text));
                            bloc.add(SaveTreatmentRequested());
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
