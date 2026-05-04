import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../components/components.dart';
import '../bloc/code_binding_bloc.dart';

class CodeBindingScreen extends StatefulWidget {
  const CodeBindingScreen({super.key});

  @override
  State<CodeBindingScreen> createState() => _CodeBindingScreenState();
}

class _CodeBindingScreenState extends State<CodeBindingScreen> {
  late final CodeBindingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CodeBindingBloc()..add(LoadCodeBindingEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 4,
                left: 24,
                child: MedSyncBackButton(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: BlocBuilder<CodeBindingBloc, CodeBindingState>(
                  builder: (context, state) {
                    if (state is CodeBindingLoadingState ||
                        state is CodeBindingInitialState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is CodeBindingErrorState) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is CodeBindingLoadedState) {
                      return _CodeBindingContent(code: state.code);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeBindingContent extends StatelessWidget {
  final String code;

  const _CodeBindingContent({required this.code});

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado al portapapeles'),
        backgroundColor: AppColors.successText,
      ),
    );
  }

  Future<void> _shareCode() async {
    await Share.share(
      'Mi código de vinculación en MedSync es $code. Úsalo para vincularte conmigo.',
    );
  }

  void _continueToApp(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/rutina');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  code,
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
                  width: 170,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () => _copyCode(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: Text(
                      'Copiar código',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
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
            onPressed: () => _continueToApp(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
