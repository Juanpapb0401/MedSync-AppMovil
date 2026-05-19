import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/app_colors.dart';
import '../../../../components/components.dart';
import '../bloc/link_patient_bloc.dart';

class LinkPatientDialog extends StatefulWidget {
  const LinkPatientDialog({super.key});

  @override
  State<LinkPatientDialog> createState() => _LinkPatientDialogState();
}

class _LinkPatientDialogState extends State<LinkPatientDialog> {
  final _patientCodeController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _patientCodeController.addListener(() {
      if (_errorText != null) {
        setState(() => _errorText = null);
      }
    });
  }

  @override
  void dispose() {
    _patientCodeController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    final patientCode = _patientCodeController.text.trim();

    if (patientCode.isEmpty) {
      setState(() => _errorText = 'Ingresa el código del paciente');
      return;
    }

    context.read<LinkPatientBloc>().add(SubmitLinkPatientEvent(patientCode));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LinkPatientBloc, LinkPatientState>(
      listener: (context, state) {
        if (state is LinkPatientFailState) {
          setState(() => _errorText = state.message);
        } else if (state is LinkPatientSuccessState) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final isLoading = state is LinkPatientLoadingState;

        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7F9F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.link,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vincular paciente',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Ingresa el código de tu paciente para vincularlo a tu cuenta.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                MedSyncTextField(
                  hint: 'Ej. MED-4821',
                  label: 'Código del paciente',
                  controller: _patientCodeController,
                  prefixIcon: Icons.link,
                  errorText: _errorText,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MedSyncButton(
                        label: 'Vincular',
                        onPressed: isLoading ? null : () => _submit(context),
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}