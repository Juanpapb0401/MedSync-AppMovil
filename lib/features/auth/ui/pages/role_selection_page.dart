import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/components.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;

  void _continue() {
    if (_selectedRole == null) return;

    final route = _selectedRole == 'paciente'
        ? '/auth/register-patient'
        : '/auth/register-caregiver';

    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).vertical - 48,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_pharmacy_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'MedSync',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona tu rol para continuar',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              RoleCard(
                label: 'Paciente',
                description: 'Gestiona tus medicamentos y rutina',
                icon: Icons.person_outline,
                isSelected: _selectedRole == 'paciente',
                onTap: () => setState(() => _selectedRole = 'paciente'),
              ),
              const SizedBox(height: 12),
              RoleCard(
                label: 'Cuidador',
                description: 'Configura tratamientos y monitorea',
                icon: Icons.health_and_safety_outlined,
                isSelected: _selectedRole == 'cuidador',
                onTap: () => setState(() => _selectedRole = 'cuidador'),
              ),
              const Spacer(),
              MedSyncButton(
                label: 'Continuar',
                onPressed: _selectedRole == null ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}