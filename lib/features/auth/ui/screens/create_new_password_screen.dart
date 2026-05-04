import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/components.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
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

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacementNamed(context, '/auth/login');
  }

  @override
  Widget build(BuildContext context) {
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
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
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
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea una contraseña segura para proteger tu cuenta',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.left,
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
                  onPressed: _isLoading ? null : _onSubmit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
