import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/app_routes.dart';

/// Halaman Tampilan Preferensi Kosong — sesuai Screenshot 2.
class PreferensiKosongScreen extends StatelessWidget {
  const PreferensiKosongScreen({super.key});

  static const _populerTags = [
    'Magang',
    'Part-time IT',
    'UI/UX',
    'Fleksibel Kuliah',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Preferensi Kosong',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Ikon Bintang Lingkaran Biru Muda
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_outline_rounded,
                    size: 38,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum Ada Preferensi Disimpan',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Atur preferensi pekerjaanmu untuk mendapatkan\nlowongan yang lebih relevan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Kotak Keuntungan Menentukan Karirmu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keuntungan Menentukan Karirmu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildBenefitItem(
                      icon: Icons.check_circle_outline,
                      title: 'Rekomendasi Lebih Akurat',
                      desc:
                          'Lowongan disesuaikan dengan minat dan keahlianmu.',
                    ),
                    const SizedBox(height: 14),
                    _buildBenefitItem(
                      icon: Icons.notifications_none_outlined,
                      title: 'Pemberitahuan Lowongan Baru',
                      desc:
                          'Dapatkan info langsung saat ada posisi yang cocok.',
                    ),
                    const SizedBox(height: 14),
                    _buildBenefitItem(
                      icon: Icons.school_outlined,
                      title: 'Kompatibel SKS Kampus',
                      desc: 'Mendukung program konversi magang dan MBKM.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Atur Preferensi Sekarang
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    // Buka halaman form preferensi
                    final hasil = await Navigator.pushNamed(
                      context,
                      AppRoutes.preferensiForm,
                    );
                    // Jika preferensi tersimpan, langsung kembali ke profil
                    if (hasil != null && context.mounted) {
                      Navigator.pop(context, hasil);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Atur Preferensi Sekarang',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bagian Populer Dicari Mahasiswa Lain
              Text(
                'Populer Dicari Mahasiswa Lain',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _populerTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
