import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/preferensi_repository.dart';
import '../data/user_session.dart';
import '../models/preferensi.dart';

/// Halaman Pengaturan Preferensi Pekerjaan — sesuai Screenshot 3 & 4 (FR-11 & FR-13).
class PreferensiFormScreen extends StatefulWidget {
  const PreferensiFormScreen({super.key});

  @override
  State<PreferensiFormScreen> createState() => _PreferensiFormScreenState();
}

class _PreferensiFormScreenState extends State<PreferensiFormScreen> {
  final _repository = PreferensiRepository();

  // Data jenis pekerjaan dengan badge & deskripsi sesuai desain UI
  static const _jobTypeOptions = [
    (
      title: 'Magang (Internship)',
      tag: 'Prioritas',
      desc: 'Minimal 3-6 bulan, konversi SKS MBKM resmi fakultas',
    ),
    (
      title: 'Part-time (Paruh Waktu)',
      tag: 'Fleksibel',
      desc: 'Jadwal fleksibel di luar jam perkuliahan & ujian',
    ),
    (
      title: 'Freelance (Proyek Lepas)',
      tag: 'Per Proyek',
      desc: 'Berdasarkan penyelesaian proyek / tugas mandiri',
    ),
  ];

  // 9 opsi bidang minat sesuai Screenshot 3 & 4
  static const _bidangOptions = [
    'IT & Software Development',
    'UI/UX & Desain Grafis',
    'F&B & Barista',
    'Digital Marketing & Sosmed',
    'Administrasi & Data Entry',
    'Content Creator & Video',
    'Tutor & Pendidikan',
    'Keuangan & Akuntansi',
    'Operasional & Logistik',
  ];

  final Set<String> _selectedJobTypes = {};
  final Set<String> _selectedInterests = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final existing = await _repository.getPreferensi();
    if (existing != null && mounted) {
      setState(() {
        _selectedJobTypes.addAll(existing.jenisPekerjaan);
        _selectedInterests.addAll(existing.bidangMinat);
      });
    }
  }

  void _toggleJobType(String title) {
    setState(() {
      if (_selectedJobTypes.contains(title)) {
        _selectedJobTypes.remove(title);
      } else {
        _selectedJobTypes.add(title);
      }
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length >= 5) {
          _snack('Maksimal 5 bidang yang dapat dipilih.');
          return;
        }
        _selectedInterests.add(interest);
      }
    });
  }

  void _resetPilihan() {
    setState(() {
      _selectedJobTypes.clear();
      _selectedInterests.clear();
    });
    _snack('Pilihan berhasil direset.');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _simpan() async {
    if (_selectedJobTypes.isEmpty) {
      _snack('Pilih minimal 1 jenis pekerjaan.');
      return;
    }
    if (_selectedInterests.isEmpty) {
      _snack('Pilih minimal 1 bidang yang diminati.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final saved = await _repository.simpanPreferensi(
        jenisPekerjaan: _selectedJobTypes.toList(),
        bidangMinat: _selectedInterests.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Preferensi pekerjaan berhasil disimpan!'),
            backgroundColor: Color(0xFF2563EB),
          ),
        );

      Navigator.pop<Preferensi>(context, saved);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business_center,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Preferensi Pekerjaan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0F172A)),
            onSelected: (value) {
              if (value == 'reset') {
                _resetPilihan();
              } else if (value == 'info') {
                _snack(
                  'Preferensi digunakan untuk menampilkan lowongan yang paling relevan.',
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset Pilihan'),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Text('Bantuan & Info'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 20),
                  _buildJobTypeSection(),
                  const SizedBox(height: 24),
                  _buildInterestsSection(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  /// Banner Biru Rekomendasi Terarah
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi Terarah',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Halo, ${UserSession().fullName} (Sistem Informasi). '
                  'Atur preferensi pekerjaanmu agar JobConnect menampilkan lowongan yang paling relevan.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF1E40AF),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bagian Jenis Pekerjaan (Checkboxes)
  Widget _buildJobTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jenis Pekerjaan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_selectedJobTypes.length} Dipilih',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Pilih satu atau lebih tipe komitmen',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        for (final opt in _jobTypeOptions) ...[
          _buildJobTypeCard(
            title: opt.title,
            tag: opt.tag,
            desc: opt.desc,
            selected: _selectedJobTypes.contains(opt.title),
            onTap: () => _toggleJobType(opt.title),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildJobTypeCard({
    required String title,
    required String tag,
    required String desc,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8FAFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox Kustom
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bagian Bidang yang Diminati (Chips)
  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bidang yang Diminati',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_selectedInterests.length}/5 Terpilih',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Pilih minimal 1 bidang:',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _bidangOptions.map((bidang) {
            final isSelected = _selectedInterests.contains(bidang);
            return InkWell(
              onTap: () => _toggleInterest(bidang),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFCBD5E1),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check : Icons.add,
                      size: 14,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF334155),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bidang,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Tombol Simpan Preferensi di Bagian Bawah
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: _isSaving ? null : _simpan,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Simpan Preferensi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
