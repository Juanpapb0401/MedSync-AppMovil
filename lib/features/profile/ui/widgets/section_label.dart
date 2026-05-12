import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4A5565),
        letterSpacing: 0.35,
      ),
    );
  }
}