import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/app_colors.dart';
import '../../../../components/medsync_button.dart';
import '../../../../components/role_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _onContinue() {
    if (_selectedRole == 'paciente') {
      Navigator.pushNamed(context, '/auth/register-patient');
    } else if (_selectedRole == 'cuidador') {
      // TODO: Replace with the actual caregiver registration route once created.
      Navigator.pushNamed(context, '/auth/register-caregiver');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedRole != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              // Logo Circular MedSync
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Transform.rotate(
                    angle: -math.pi / 4, // Rota el ícono de píldora -45 grados
                    child: const Icon(
                      Icons.medication,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nombre de la App
              Text(
                'MedSync',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827), // Color súper oscuro para el título
                ),
              ),
              const SizedBox(height: 8),

              // Subtítulo
              Text(
                'Selecciona tu rol para continuar',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 48),

              // Tarjeta Paciente
              RoleCard(
                label: 'Paciente',
                description: 'Gestiona tus medicamentos rutina',
                icon: Icons.person_outline,
                isSelected: _selectedRole == 'paciente',
                onTap: () => _onRoleSelected('paciente'),
              ),
              const SizedBox(height: 16),

              // Tarjeta Cuidador
              RoleCard(
                label: 'Cuidador',
                description: 'Configura tratamientos, monitorea',
                icon: Icons.volunteer_activism_outlined, // Ícono similar al de la imagen
                isSelected: _selectedRole == 'cuidador',
                onTap: () => _onRoleSelected('cuidador'),
              ),
              
              const Spacer(),

              // Botón Continuar
              MedSyncButton(
                label: 'Continuar',
                onPressed: canContinue ? _onContinue : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
