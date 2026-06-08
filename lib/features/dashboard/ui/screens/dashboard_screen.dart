import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medsync/di/service_locator.dart';
import '../../../../components/app_colors.dart';
import '../../../../components/main_nav_bar.dart';
import '../../../dashboard/domain/model/daily_summary_model.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/calendar_modal.dart';
import '../widgets/medication_list_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(DashboardLoadData()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDateLabel(DateTime date) {
    final today = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    if (diff == 0) return 'Hoy';
    if (diff == -1) return 'Ayer';

    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatSectionLabel(DateTime date) {
    final today = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    if (diff == 0) return 'HOY';
    if (diff == -1) return 'AYER';

    const months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _openCalendar(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<DashboardBloc>(),
        child: CalendarModal(
          selectedDate: selectedDate,
          onDateSelected: (date) {
            context.read<DashboardBloc>().add(DashboardDateChanged(date));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final date = state.selectedDate;
            final canGoForward = !_isToday(date);
            final showBanner = !state.isLoading &&
                state.summary != null &&
                state.summary!.sinConfirmar > 0 &&
                _isToday(date);

            return Column(
              children: [
                _buildHeader(state),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateNav(context, date, canGoForward),
                        const SizedBox(height: 16),
                        _buildStatsRow(state),
                        if (showBanner) ...[
                          const SizedBox(height: 16),
                          _buildAlertBanner(state.summary!),
                        ],
                        const SizedBox(height: 16),
                        _buildMedicationSection(context, state, date),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const MainNavBar(
        userRole: 'cuidador',
        activeIndex: 1,
      ),
    );
  }

  Widget _buildHeader(DashboardState state) {
    final patientName = state.summary?.patientName ?? '';
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          if (patientName.isNotEmpty)
            Text(
              patientName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6a7282),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateNav(
    BuildContext context,
    DateTime date,
    bool canGoForward,
  ) {
    final tealBg = AppColors.primary.withValues(alpha: 0.1);
    final greyBg = const Color(0xFFF3F4F6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () =>
                context.read<DashboardBloc>().add(DashboardPreviousDay()),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tealBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_left,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _openCalendar(context, date),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateLabel(date),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: canGoForward
                ? () =>
                    context.read<DashboardBloc>().add(DashboardNextDay())
                : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: canGoForward ? tealBg : greyBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                color: canGoForward
                    ? AppColors.primary
                    : const Color(0xFF6B7280),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DashboardState state) {
    final summary = state.summary;
    final isLoading = state.isLoading;

    final tomadasStr =
        isLoading ? '--' : (summary?.tomadas.toString() ?? '--');
    final omitidasStr =
        isLoading ? '--' : (summary?.omitidas.toString() ?? '--');
    final logroStr = isLoading
        ? '--'
        : (summary?.logroPct != null
            ? '${summary!.logroPct!.round()}%'
            : '--');

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Tomadas',
            value: tomadasStr,
            valueColor: const Color(0xFF16a34a),
            borderColor: const Color(0xFFdcfce7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Omitidas',
            value: omitidasStr,
            valueColor: const Color(0xFFdc2626),
            borderColor: const Color(0xFFfee2e2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Logro',
            value: logroStr,
            valueColor: const Color(0xFFd97706),
            borderColor: const Color(0xFFfed7aa),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBanner(DailySummaryModel summary) {
    final count = summary.sinConfirmar;
    final patientName = summary.patientName;
    final tomaLabel = count == 1 ? '1 toma' : '$count tomas';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFfef2f2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFfecaca)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFdc2626),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: patientName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF364153),
                    ),
                  ),
                  TextSpan(
                    text: ' tiene ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF364153),
                    ),
                  ),
                  TextSpan(
                    text: tomaLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFdc2626),
                    ),
                  ),
                  TextSpan(
                    text: ' sin confirmar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF364153),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection(
    BuildContext context,
    DashboardState state,
    DateTime date,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatSectionLabel(date),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF99a1af),
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: 12),
        if (state.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Error al cargar medicamentos',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (state.summary == null ||
            state.summary!.notifications.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No hay medicamentos registrados para esta fecha',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Column(
            children: state.summary!.notifications
                .map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MedicationListItem(notification: n),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color borderColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6a7282),
            ),
          ),
        ],
      ),
    );
  }
}
