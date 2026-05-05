import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/components.dart';
import '../bloc/create_new_password_bloc.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    setState(() {
      _newError = null;
      _confirmError = null;
    });

    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (newPass.isEmpty) {
      setState(() => _newError = 'La contraseña no puede estar vacía');
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _confirmError = 'Confirma tu contraseña');
      return;
    }
    if (newPass != confirm) {
      setState(() => _confirmError = 'Las contraseñas no coinciden');
      return;
    }

    context.read<CreateNewPasswordBloc>().add(
          CreateNewPasswordRequested(newPass),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateNewPasswordBloc(),
      child: BlocConsumer<CreateNewPasswordBloc, CreateNewPasswordState>(
        listener: (context, state) {
          if (state is CreateNewPasswordSuccess) {
            Navigator.pushReplacementNamed(context, '/auth/password-updated');
          }
          if (state is CreateNewPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.dangerText,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateNewPasswordLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const Padding(
                padding: EdgeInsets.only(left: 12, top: 8),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nueva contraseña',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea una contraseña segura para proteger tu cuenta',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      MedSyncTextField(
                        label: 'Nueva contraseña',
                        hint: '••••••••',
                        controller: _newController,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        errorText: _newError,
                      ),
                      const SizedBox(height: 16),
                      MedSyncTextField(
                        label: 'Confirmar contraseña',
                        hint: '••••••••',
                        controller: _confirmController,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        errorText: _confirmError,
                      ),
                      const SizedBox(height: 28),
                      MedSyncButton(
                        label: 'Restablecer contraseña',
                        onPressed: isLoading ? null : () => _onSubmit(context),
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 32),
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