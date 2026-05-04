import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/components.dart';
import '../bloc/caregiver_register_bloc.dart';

class CaregiverRegisterPage extends StatefulWidget {
  const CaregiverRegisterPage({super.key});

  @override
  State<CaregiverRegisterPage> createState() => _CaregiverRegisterPageState();
}

class _CaregiverRegisterPageState extends State<CaregiverRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _patientCodeController = TextEditingController();
  Uint8List? _avatarBytes;
  String? _avatarExt;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _patientCodeError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateFields);
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
    _confirmPasswordController.addListener(_validateFields);
    _patientCodeController.addListener(() {
      if (_patientCodeError != null) {
        setState(() => _patientCodeError = null);
      }
      _validateFields();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _patientCodeController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void _validateFields() {
    setState(() {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      _nameError = name.isEmpty ? 'Por favor ingresa tu nombre' : null;
      _emailError = email.isEmpty
          ? 'Por favor ingresa tu correo'
          : (_isEmailValid(email) ? null : 'Ingresa un correo válido');
      _passwordError = password.length < 6 ? 'Mínimo 6 caracteres' : null;
      _confirmPasswordError = confirmPassword.isEmpty
          ? 'Por favor confirma tu contraseña'
          : (confirmPassword != password
                ? 'Las contraseñas no coinciden'
                : null);
    });
  }

  bool get _isValid {
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _isEmailValid(_emailController.text.trim()) &&
        _passwordController.text.length >= 6 &&
        _confirmPasswordController.text == _passwordController.text;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);

    if (!_isValid) {
      _validateFields();
      return;
    }

    context.read<CaregiverRegisterBloc>().add(
          CaregiverRegisterSubmitEvent(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            avatarBytes: _avatarBytes,
            avatarExt: _avatarExt,
            patientCode: _patientCodeController.text.trim().isEmpty
                ? null
                : _patientCodeController.text.trim(),
          ),
        );
  }

  String? _fieldError(String? error, bool hasText) {
    if (!_submitted && !hasText) return null;
    return error;
  }

  bool _hasText(TextEditingController controller) =>
      controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CaregiverRegisterBloc, CaregiverRegisterState>(
      listener: (context, state) {
        if (state is CaregiverRegisterFailState) {
          final message = state.message;
          if (message.toLowerCase().contains('código')) {
            setState(() => _patientCodeError = message);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.dangerText,
              ),
            );
          }
        } else if (state is CaregiverRegisterSuccessState) {
          Navigator.pushReplacementNamed(context, '/configurar');
        }
      },
      builder: (context, state) {
        final isLoading = state is CaregiverRegisterLoadingState;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const MedSyncBackButton(),
              const SizedBox(height: 24),
              Text(
                'Crear cuenta',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rol: Cuidador',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: AvatarPicker(
                  onImageSelected: (bytes, ext) {
                    setState(() {
                      _avatarBytes = bytes;
                      _avatarExt = ext;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              MedSyncTextField(
                hint: 'Tu nombre',
                label: 'Nombre completo',
                controller: _nameController,
                keyboardType: TextInputType.name,
                errorText: _fieldError(_nameError, _hasText(_nameController)),
              ),
              const SizedBox(height: 20),
              MedSyncTextField(
                hint: 'correo@ejemplo.com',
                label: 'Correo electrónico',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _fieldError(_emailError, _hasText(_emailController)),
              ),
              const SizedBox(height: 20),
              MedSyncTextField(
                hint: 'Mínimo 6 caracteres',
                label: 'Contraseña',
                controller: _passwordController,
                isPassword: true,
                errorText: _fieldError(
                  _passwordError,
                  _hasText(_passwordController),
                ),
              ),
              const SizedBox(height: 20),
              MedSyncTextField(
                hint: 'Repite tu contraseña',
                label: 'Confirmar contraseña',
                controller: _confirmPasswordController,
                isPassword: true,
                errorText: _fieldError(
                  _confirmPasswordError,
                  _hasText(_confirmPasswordController),
                ),
              ),
              const SizedBox(height: 20),
              MedSyncTextField(
                hint: 'Ej. MED-4821',
                label: 'Código del paciente',
                controller: _patientCodeController,
                prefixIcon: Icons.link,
                errorText: _patientCodeError,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pídele el código a tu paciente (o regístralo después)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              MedSyncButton(
                label: 'Crear cuenta',
                onPressed: isLoading ? null : _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}