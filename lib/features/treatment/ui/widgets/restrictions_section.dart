import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import 'restriction_chip.dart';

class RestrictionsSection extends StatefulWidget {
  final List<String> selectedRestrictions;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const RestrictionsSection({
    super.key,
    required this.selectedRestrictions,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<RestrictionsSection> createState() => _RestrictionsSectionState();
}

class _RestrictionsSectionState extends State<RestrictionsSection> {
  bool _isAddingCustom = false;
  final TextEditingController _customController = TextEditingController();
  final List<String> _presets = [
    'Evitar lácteos',
    'No alcohol',
    'No cítrico',
    'No grasas',
    'Tomar con agua'
  ];

  @override
  Widget build(BuildContext context) {
    // Collect all unique restrictions to show as chips
    final allRestrictions = <String>{..._presets, ...widget.selectedRestrictions}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restricciones',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.navbarBackground,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allRestrictions.map((restriction) {
            // In the Figma, they look like unselected tags that you click.
            // Assuming clicking them selects/deselects. Let's make them look like the Figma.
            final isSelected = widget.selectedRestrictions.contains(restriction);
            
            return RestrictionChip(
              label: restriction,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) {
                  widget.onRemove(restriction);
                } else {
                  widget.onAdd(restriction);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (!_isAddingCustom)
          GestureDetector(
            onTap: () => setState(() => _isAddingCustom = true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: AppColors.primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Agregar restricción',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  autofocus: true,
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Escribe y presiona el check',
                    hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      widget.onAdd(val.trim());
                    }
                    setState(() {
                      _isAddingCustom = false;
                      _customController.clear();
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: AppColors.primary),
                onPressed: () {
                  if (_customController.text.trim().isNotEmpty) {
                    widget.onAdd(_customController.text.trim());
                  }
                  setState(() {
                    _isAddingCustom = false;
                    _customController.clear();
                  });
                },
              ),
            ],
          ),
      ],
    );
  }
}
