import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import 'faq_item.dart';

class AyudaCardCaregiver extends StatelessWidget {
  const AyudaCardCaregiver({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'AYUDA',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
                letterSpacing: 0.96,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFB2E8E2)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Correo de atención',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'soporte@medsync.app',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 13),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.help_outline,
                  size: 16,
                  color: Color(0xFF111827),
                ),
                const SizedBox(width: 8),
                Text(
                  'Preguntas frecuentes',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const FaqItem(
            question: '¿Cómo vinculo a mi paciente?',
            answer:
                'Comparte el código MED de tu paciente. El paciente debe ingresarlo en la sección de vinculación de su app.',
          ),
          const FaqItem(
            question: '¿Qué pasa si el paciente no confirma su toma?',
            answer:
                'Recibirás una notificación. Puedes ver el historial de tomas en el dashboard.',
          ),
          const FaqItem(
            question: '¿Puedo cambiar los horarios de medicamentos?',
            answer:
                'Sí, desde la sección "Configurar Tratamiento" puedes editar los horarios.',
          ),
          const FaqItem(
            question: '¿Cómo recupero mi contraseña?',
            answer:
                'En la pantalla de inicio de sesión, toca "¿Olvidaste tu contraseña?" y sigue las instrucciones.',
          ),
        ],
      ),
    );
  }
}