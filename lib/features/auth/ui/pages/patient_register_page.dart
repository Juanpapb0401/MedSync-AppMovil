import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/components.dart';
import '../bloc/patient_register_bloc.dart';

class PatientRegisterPage extends StatefulWidget {
  const PatientRegisterPage({super.key});

  @override
  State<PatientRegisterPage> createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Uint8List? _avatarBytes;
  String? _avatarExt;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateFields);
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
    _confirmPasswordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Por favor ingresa tu nombre'
          : null;
      _emailError = _emailController.text.trim().isEmpty
          ? 'Por favor ingresa tu correo'
          : null;

      final password = _passwordController.text;
      _passwordError = password.length < 6 ? 'Mínimo 6 caracteres' : null;

      final confirmPassword = _confirmPasswordController.text;
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
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.length >= 6 &&
        _confirmPasswordController.text == _passwordController.text;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_isValid) {
      _validateFields();
      return;
    }

    context.read<PatientRegisterBloc>().add(
      PatientRegisterSubmitEvent(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        avatarBytes: _avatarBytes,
        avatarExt: _avatarExt,
      ),
    );
  }

  bool _hasStartedTyping(TextEditingController controller) =>
      controller.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientRegisterBloc, PatientRegisterState>(
      listener: (context, state) {
        if (state is PatientRegisterFailState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.dangerText,
            ),
          );
        } else if (state is PatientRegisterSuccessState) {
          Navigator.pushReplacementNamed(context, '/profile/patient');
        }
      },
      builder: (context, state) {
        final isLoading = state is PatientRegisterLoadingState;

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
                'Rol: Paciente',
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
                hint: 'Ej. Juan Pérez',
                label: 'Nombre completo',
                controller: _nameController,
                keyboardType: TextInputType.name,
                errorText: _hasStartedTyping(_nameController)
                    ? _nameError
                    : null,
              ),
              const SizedBox(height: 20),
              MedSyncTextField(
                hint: 'ejemplo@correo.com',
                label: 'Correo electrónico',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _hasStartedTyping(_emailController)
                    ? _emailError
                    : null,
              ),
              const SizedBox(height: 20),
              MedSyncTextField(
                hint: 'Ingresa tu contraseña',
                label: 'Contraseña',
                controller: _passwordController,
                isPassword: true,
                errorText: _hasStartedTyping(_passwordController)
                    ? _passwordError
                    : null,
              ),
              const SizedBox(height: 20),
              MedSyncTextField(
                hint: 'Repite tu contraseña',
                label: 'Confirmar contraseña',
                controller: _confirmPasswordController,
                isPassword: true,
                errorText: _hasStartedTyping(_confirmPasswordController)
                    ? _confirmPasswordError
                    : null,
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
