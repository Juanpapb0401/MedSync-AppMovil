import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../components/components.dart';

class CodeBindingScreen extends StatefulWidget {
  final String? code;

  const CodeBindingScreen({super.key, this.code});

  @override
  State<CodeBindingScreen> createState() => _CodeBindingScreenState();
}

class _CodeBindingScreenState extends State<CodeBindingScreen> {
  late final String _bindingCode;

  @override
  void initState() {
    super.initState();
    _bindingCode = widget.code ?? _generateCode();
  }

  String _generateCode() {
    final random = Random();
    final number = random.nextInt(900) + 100;
    return 'MED-$number';
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _bindingCode));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado al portapapeles'),
        backgroundColor: AppColors.successText,
      ),
    );
  }

  Future<void> _shareCode() async {
    await Share.share(
      'Mi código de vinculación en MedSync es $_bindingCode. Úsalo para vincularte conmigo.',
    );
  }

  void _continueToApp() {
    Navigator.pushReplacementNamed(context, '/rutina');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tu código de vinculación',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Comparte este código con tu cuidador para que pueda vincularse contigo',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'TU CÓDIGO ÚNICO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _bindingCode,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 152,
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: _copyCode,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          backgroundColor: AppColors.background,
                          foregroundColor: AppColors.primary,
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text(
                          'Copiar código',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningBg.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 20,
                      color: AppColors.warningText,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tu cuidador necesitará este código al registrarse en MedSync para vincularse contigo.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warningText,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              MedSyncButton(
                label: 'Compartir código',
                onPressed: _shareCode,
                leadingIcon: Icons.share_outlined,
              ),
              const SizedBox(height: 12),
              MedSyncOutlinedButton(
                label: 'Continuar a la app',
                onPressed: _continueToApp,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
