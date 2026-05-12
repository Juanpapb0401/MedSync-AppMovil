import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import '../../domain/model/profile_model.dart';
import 'profile_card.dart';
import 'section_label.dart';

class LinkedPatientCard extends StatelessWidget {
  final LinkedPatientModel patient;

  const LinkedPatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('PACIENTE VINCULADO'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7F9F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Código: ${patient.linkingCode}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF99A1AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}