import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/components.dart';
import '../bloc/otp_verification_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String email =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return BlocProvider(
      create: (_) => OtpVerificationBloc(),
      child: BlocConsumer<OtpVerificationBloc, OtpVerificationState>(
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            // Navegar a la pantalla de crear nueva contraseña (HU del compañero)
            Navigator.pushReplacementNamed(
              context,
              '/auth/create-new-password',
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is OtpVerificationLoading;
          final errorText = state is OtpVerificationError
              ? (state as OtpVerificationError).message
              : null;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: MedSyncBackButton(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // Ícono
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.password,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Ingresar código',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Ingresa el código de 8 dígitos enviado a\n',
                            ),
                            TextSpan(
                              text: email,
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Campo de código OTP
                      MedSyncTextField(
                        label: 'Código de 8 dígitos',
                        hint: '00000000',
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        prefixIcon: Icons.lock_outline,
                        errorText: errorText,
                      ),
                      const SizedBox(height: 32),
                      MedSyncButton(
                        label: 'Verificar código',
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_codeController.text.length == 8) {
                                  context.read<OtpVerificationBloc>().add(
                                    OtpVerificationRequested(
                                      email,
                                      _codeController.text.trim(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('El código debe tener 8 dígitos'),
                                      backgroundColor: AppColors.dangerText,
                                    ),
                                  );
                                }
                              },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Volver atrás',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
