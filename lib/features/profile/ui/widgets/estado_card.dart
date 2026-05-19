import 'package:flutter/material.dart';
import 'profile_card.dart';
import 'section_label.dart';
import 'status_row.dart';
import 'link_status_row.dart';

class EstadoCard extends StatelessWidget {
  final bool hasLinked;
  final String linkedLabel;
  final String linkedStatus;
  final String statusType;
  final VoidCallback? onLinkTap;

  const EstadoCard({
    super.key,
    required this.hasLinked,
    required this.linkedLabel,
    required this.linkedStatus,
    required this.statusType,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('ESTADO'),
          const SizedBox(height: 12),
          StatusRow(
            icon: Icons.check_circle_outline,
            label: 'Cuenta activa',
            badgeText: 'Activo',
            badgeBg: const Color(0xFFDCFCE7),
            badgeTextColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          LinkStatusRow(
            label: linkedLabel,
            hasLinked: hasLinked,
            linkedStatus: linkedStatus,
            onTap: onLinkTap,
          ),
        ],
      ),
    );
  }
}