import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import 'faq_item.dart';

class AyudaCardPatient extends StatelessWidget {
  const AyudaCardPatient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AYUDA',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.96,
            ),
          ),
          const SizedBox(height: 13),
          Container(
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
          Row(
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
          const SizedBox(height: 8),
          const FaqItem(
            question: '¿Cómo vinculo a mi cuidador?',
            answer:
                'Comparte tu código MED con tu cuidador. El cuidador debe ingresarlo en la sección de vinculación de su app.',
          ),
          const FaqItem(
            question: '¿Qué pasa si no confirmo mi toma?',
            answer:
                'Tu cuidador recibirá una notificación. El sistema registrará la toma como sin confirmar.',
          ),
          const FaqItem(
            question: '¿Puedo ver mis medicamentos programados?',
            answer:
                'Sí, desde la sección "Mi Rutina" puedes ver todos tus medicamentos y horarios.',
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