import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/components.dart';
import '../bloc/login_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<LoginBloc>().add(
          LoginSubmitEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isLoading = state is LoginLoadingState;
        final errorMessage = state is LoginFailState ? state.message : null;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MedSync',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cuidamos de ti',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Correo
              MedSyncTextField(
                label: 'Correo electrónico',
                hint: 'correo@ejemplo.com',
                controller: _emailController,
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              MedSyncTextField(
                label: 'Contraseña',
                hint: 'Tu contraseña',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              // Error inline
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.dangerText,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.dangerText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              MedSyncButton(
                label: 'Iniciar sesión',
                onPressed: isLoading ? null : _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),
              Center(
                child: MedSyncLinkButton(
                  label: '¿Olvidaste tu contraseña?',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/auth/forgot-password'),
                ),
              ),
              const SizedBox(height: 64),
              // Pie de pantalla
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  MedSyncLinkButton(
                    label: 'Registrarse',
                    onPressed: () =>
                        Navigator.pushNamed(context, '/auth/role-selection'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
