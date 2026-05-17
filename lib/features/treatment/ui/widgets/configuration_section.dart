import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/components.dart';
import '../../../../components/app_colors.dart';

class ConfigurationSection extends StatelessWidget {
  final TextEditingController medicineController;
  final TextEditingController doseController;
  final String selectedUnit;
  final String selectedFrequency;
  final String startTime;
  final Function(String) onUnitChanged;
  final Function(String) onFrequencyChanged;
  final VoidCallback onStartTimeTap;

  const ConfigurationSection({
    super.key,
    required this.medicineController,
    required this.doseController,
    required this.selectedUnit,
    required this.selectedFrequency,
    required this.startTime,
    required this.onUnitChanged,
    required this.onFrequencyChanged,
    required this.onStartTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.navbarBackground,
          ),
        ),
        const SizedBox(height: 16),
        MedSyncTextField(
          label: 'Medicamento',
          hint: 'Nombre del medicamento',
          controller: medicineController,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: MedSyncTextField(
                label: 'Dosis',
                hint: '850',
                controller: doseController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _DropdownField(
                label: 'Unidad',
                value: selectedUnit,
                items: const ['mg', 'ml', 'comprimidos'],
                onChanged: onUnitChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'Frecuencia',
          value: selectedFrequency,
          items: const ['Cada 8 horas', 'Cada 12 horas', 'Cada 24 horas'],
          onChanged: onFrequencyChanged,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onStartTimeTap,
          child: AbsorbPointer(
            child: MedSyncTextField(
              label: 'Hora de inicio',
              hint: '08:00 AM',
              controller: TextEditingController(text: startTime),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4B5563), // Un gris un poco más claro que el título
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Ajustado para igualar altura de MedSyncTextField
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
