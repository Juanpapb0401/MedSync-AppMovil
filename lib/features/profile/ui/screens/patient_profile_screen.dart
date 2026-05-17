import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import '../../../../components/main_nav_bar.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/estado_card.dart';
import '../widgets/linking_code_card.dart';
import '../widgets/ayuda_card_patient.dart';
import '../widgets/logout_button.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(LoadProfileEvent()),
      child: const _PatientProfileView(),
    );
  }
}

class _PatientProfileView extends StatelessWidget {
  const _PatientProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoadingState || state is ProfileInitialState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProfileErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state is ProfileLoadedState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    fullName: state.profile.fullName,
                    email: state.profile.email,
                    role: state.profile.type,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      children: [
                        EstadoCard(
                          hasLinked: state.profile.hasLinkedCaregiver,
                          linkedLabel: 'Cuidador vinculado',
                          linkedStatus: 'Vinculado',
                          statusType: 'caregiver',
                        ),
                        const SizedBox(height: 16),
                        LinkingCodeCard(code: state.profile.linkingCode),
                        const SizedBox(height: 16),
                        const AyudaCardPatient(),
                        const SizedBox(height: 8),
                        const LogoutButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const MainNavBar(
        userRole: 'paciente',
        activeIndex: 1,
      ),
    );
  }
}