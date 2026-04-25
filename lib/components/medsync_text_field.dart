import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// AM-30 — DS-02 MedSyncTextField
// Height 56, border-radius 12, fondo #F8FAF9
// Borde default: 0.5px #E5E7EB | error: 1px #DC2626
// isPassword: ojo toggle. errorText: borde rojo + mensaje debajo.
class MedSyncTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final String? errorText;
  final TextInputType keyboardType;

  const MedSyncTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.label,
    this.prefixIcon,
    this.isPassword = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<MedSyncTextField> createState() => _MedSyncTextFieldState();
}

class _MedSyncTextFieldState extends State<MedSyncTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final field = TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textMuted,
        ),
        errorText: widget.errorText,
        errorStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.dangerText,
        ),
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.textMuted, size: 20)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? AppColors.dangerText : AppColors.cardBorder,
            width: hasError ? 1.0 : 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? AppColors.dangerText : AppColors.primary,
            width: hasError ? 1.0 : 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dangerText, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dangerText, width: 1.0),
        ),
      ),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label!,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
