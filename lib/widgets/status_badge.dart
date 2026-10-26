import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/lamaran.dart';

/// Kapsul status lamaran (Diproses / Diterima / Ditolak).
/// Dibuat sebagai widget sendiri karena dipakai di beberapa layar:
/// daftar lamaran, detail lamaran, dan kartu status di detail lowongan.
class StatusBadge extends StatelessWidget {
  final LamaranStatus status;
  const StatusBadge({super.key, required this.status});

  /// Warna teks/ikon tiap status (sama dengan yang dipakai di detail_screen).
  static Color colorOf(LamaranStatus status) => switch (status) {
        LamaranStatus.diproses => const Color(0xFFB45309),
        LamaranStatus.diterima => const Color(0xFF006058),
        LamaranStatus.ditolak => const Color(0xFFBA1A1A),
      };

  @override
  Widget build(BuildContext context) {
    final color = colorOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.22,
          color: color,
        ),
      ),
    );
  }
}