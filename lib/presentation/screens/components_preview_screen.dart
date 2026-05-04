import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/components.dart';

class ComponentsPreviewScreen extends StatefulWidget {
  const ComponentsPreviewScreen({super.key});

  @override
  State<ComponentsPreviewScreen> createState() =>
      _ComponentsPreviewScreenState();
}

class _ComponentsPreviewScreenState extends State<ComponentsPreviewScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _errorController = TextEditingController();

  String? _selectedRole;
  int _dotIndex = 0;
  bool _buttonLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  void _toggleLoading() async {
    setState(() => _buttonLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _buttonLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Design System',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ── Botones ──────────────────────────────────────────────────
            _SectionTitle(label: 'AM-29 — Botones'),
            const SizedBox(height: 12),
            MedSyncButton(
              label: 'Iniciar sesión',
              onPressed: _toggleLoading,
              isLoading: _buttonLoading,
            ),
            const SizedBox(height: 12),
            MedSyncOutlinedButton(label: 'Compartir código', onPressed: () {}),
            const SizedBox(height: 12),
            Center(
              child: MedSyncLinkButton(
                label: '¿Olvidaste tu contraseña?',
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 12),
            MedSyncButton(label: 'Botón deshabilitado', onPressed: null),
            const SizedBox(height: 32),

            // ── TextFields ───────────────────────────────────────────────
            _SectionTitle(label: 'AM-30 — Campos de texto'),
            const SizedBox(height: 12),
            MedSyncTextField(
              hint: 'correo@ejemplo.com',
              controller: _emailController,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            MedSyncTextField(
              hint: 'Contraseña',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 12),
            MedSyncTextField(
              hint: 'Campo con error',
              controller: _errorController,
              prefixIcon: Icons.person_outline,
              errorText: 'Este campo es obligatorio',
            ),
            const SizedBox(height: 32),

            // ── BackButton ───────────────────────────────────────────────
            _SectionTitle(label: 'AM-31 — BackButton circular'),
            const SizedBox(height: 12),
            Row(
              children: [
                MedSyncBackButton(onPressed: () {}),
                const SizedBox(width: 16),
                Text(
                  'Volver a la pantalla anterior',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── RoleCards ────────────────────────────────────────────────
            _SectionTitle(label: 'AM-32 — RoleCards seleccionables'),
            const SizedBox(height: 12),
            RoleCard(
              label: 'Paciente',
              description: 'Recibo y confirmo mis tomas',
              icon: Icons.person_outline,
              isSelected: _selectedRole == 'paciente',
              onTap: () => setState(() => _selectedRole = 'paciente'),
            ),
            const SizedBox(height: 12),
            RoleCard(
              label: 'Cuidador',
              description: 'Configuro el tratamiento',
              icon: Icons.favorite_outline,
              isSelected: _selectedRole == 'cuidador',
              onTap: () => setState(() => _selectedRole = 'cuidador'),
            ),
            const SizedBox(height: 32),

            // ── InfoCard ─────────────────────────────────────────────────
            _SectionTitle(label: 'AM-33 — InfoCard'),
            const SizedBox(height: 12),
            const InfoCard(
              label: 'Revisa tu correo',
              description:
                  'Si no encuentras el correo, revisa tu carpeta de spam.',
            ),
            const SizedBox(height: 12),
            const InfoCard(
              label: 'Código de paciente',
              description: 'Pídele el código a tu paciente en formato MED-XXXX.',
              icon: Icons.link,
            ),
            const SizedBox(height: 32),

            // ── AvatarPicker ─────────────────────────────────────────────
            _SectionTitle(label: 'AM-34 — AvatarPicker'),
            const SizedBox(height: 12),
            Center(child: AvatarPicker(onImageSelected: (bytes, ext) {})),
            const SizedBox(height: 32),

            // ── Progress Dots ─────────────────────────────────────────────
            _SectionTitle(label: 'AM-35 — OnboardingProgressDots'),
            const SizedBox(height: 16),
            Center(
              child: OnboardingProgressDots(count: 3, currentIndex: _dotIndex),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                MedSyncBackButton(
                  onPressed: _dotIndex > 0
                      ? () => setState(() => _dotIndex--)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MedSyncButton(
                    label: _dotIndex < 2 ? 'Siguiente' : 'Comenzar',
                    onPressed: _dotIndex < 2
                        ? () => setState(() => _dotIndex++)
                        : () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: 0.3,
      ),
    );
  }
}
