import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/app_colors.dart';
import '../../../../components/medsync_back_button.dart';
import '../../../../components/medsync_button.dart';
import '../../domain/model/treatment_model.dart';
import '../widgets/configuration_section.dart';
import '../widgets/restrictions_section.dart';

class EditTreatmentScreen extends StatefulWidget {
  final TreatmentModel initialTreatment;
  final String patientName;

  const EditTreatmentScreen({
    super.key,
    required this.initialTreatment,
    required this.patientName,
  });

  @override
  State<EditTreatmentScreen> createState() => _EditTreatmentScreenState();
}

class _EditTreatmentScreenState extends State<EditTreatmentScreen> {
  late TextEditingController _medicineController;
  late TextEditingController _doseController;
  late String _selectedUnit;
  late String _selectedFrequency;
  late String _startTime;
  late List<String> _selectedRestrictions;

  @override
  void initState() {
    super.initState();
    _medicineController = TextEditingController(text: widget.initialTreatment.medicineName);
    _doseController = TextEditingController(text: widget.initialTreatment.dose);
    _selectedUnit = widget.initialTreatment.unit;
    _selectedFrequency = widget.initialTreatment.frequency;
    _startTime = widget.initialTreatment.startTime;
    _selectedRestrictions = List.from(widget.initialTreatment.restrictions);
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Aquí iría la lógica para enviar al Repositorio / Bloc
    // Simularemos éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tratamiento actualizado exitosamente'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context); // Volveríamos a Ver Tratamientos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Flecha + Títulos)
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
                          'Paciente: ${widget.patientName}',
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

                // Banner "Editando: [Medicamento]" en amarillo claro con texto naranja/amarillo oscuro (según mockup)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF9C3), // Amarillo clarito
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE047), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Color(0xFFCA8A04), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Editando: ${widget.initialTreatment.medicineName}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFCA8A04), // Texto amarillo-naranja
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Formulario Principal
                ConfigurationSection(
                  medicineController: _medicineController,
                  doseController: _doseController,
                  selectedUnit: _selectedUnit,
                  selectedFrequency: _selectedFrequency,
                  startTime: _startTime,
                  onUnitChanged: (val) => setState(() => _selectedUnit = val),
                  onFrequencyChanged: (val) => setState(() => _selectedFrequency = val),
                  onStartTimeTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(), // Podría parsearse startTime
                    );
                    if (picked != null && context.mounted) {
                      setState(() {
                        _startTime = picked.format(context);
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Restricciones
                RestrictionsSection(
                  selectedRestrictions: _selectedRestrictions,
                  onAdd: (restriction) {
                    setState(() {
                      if (!_selectedRestrictions.contains(restriction)) {
                        _selectedRestrictions.add(restriction);
                      }
                    });
                  },
                  onRemove: (restriction) {
                    setState(() {
                      _selectedRestrictions.remove(restriction);
                    });
                  },
                ),
                const SizedBox(height: 48),

                // Footer Botón Guardar
                MedSyncButton(
                  label: 'Guardar cambios',
                  onPressed: _saveChanges,
                  leadingIcon: Icons.edit,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
