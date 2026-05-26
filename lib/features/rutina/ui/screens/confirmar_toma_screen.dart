import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import '../../domain/model/rutina_medicamento_model.dart';

class ConfirmarTomaScreen extends StatefulWidget {
  final RutinaMedicamentoModel medicamento;
  final DateTime currentDate;

  const ConfirmarTomaScreen({
    super.key,
    required this.medicamento,
    required this.currentDate,
  });

  @override
  State<ConfirmarTomaScreen> createState() => _ConfirmarTomaScreenState();
}

class _ConfirmarTomaScreenState extends State<ConfirmarTomaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour;
    final m = local.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${displayH.toString().padLeft(2, '0')}:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medicamento;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Back button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF1A1A1A),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            // ── Scrollable content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      'Es hora de tomar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Pulse animation ─────────────────────────────
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Container(
                              width: 88,
                              height: 88,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                color: AppColors.primary,
                                size: 44,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── Medicine name ───────────────────────────────
                    Text(
                      med.medicineName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _formatTime(med.scheduledDateTime),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Dose card ───────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${med.dose} ${med.unit}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Restrictions ────────────────────────────────
                    if (med.restrictions.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFCC80)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFEF6C00),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Restricciones',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFEF6C00),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...med.restrictions.map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Icon(
                                        Icons.circle,
                                        size: 5,
                                        color: Color(0xFFEF6C00),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        r,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: const Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Action buttons ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, 'tomado'),
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                      label: Text(
                        'Ya me la tomé',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, 'recordar'),
                      icon: const Icon(Icons.alarm_rounded,
                          color: Color(0xFFB45309)),
                      label: Text(
                        'Recordar en 2 minutos',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF9C3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(color: Color(0xFFFFCC80)),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Si no confirmas, te recordaremos en 2 minutos',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
