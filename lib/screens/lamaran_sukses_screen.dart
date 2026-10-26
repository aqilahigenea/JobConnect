import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/lamaran.dart';
import '../routes/app_routes.dart';

// ---------- Warna dari desain Figma "Status Lamaran Berhasil" ----------
const _bg = Color(0xFFF9F9FF);
const _ink = Color(0xFF111C2D);
const _muted = Color(0xFF434655);
const _hint = Color(0xFF737686);
const _blue = Color(0xFF004AC6);
const _blueDark = Color(0xFF1D4ED8);
const _teal = Color(0xFF006058);
const _chip = Color(0xFFE7EEFF);
const _tile = Color(0xFFF0F3FF);
const _line = Color(0xFFC3C6D7);
const _pendingBg = Color(0xFFD8E3FB);

TextStyle _inter(double size, FontWeight w, Color c,
        {double? height, double? spacing}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: w,
      color: c,
      height: height == null ? null : height / size,
      letterSpacing: spacing,
    );

TextStyle _jakarta(double size, FontWeight w, Color c, {double? spacing}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: w,
      color: c,
      letterSpacing: spacing,
    );

/// FR-06 (Feedback): halaman "Lamaran Berhasil Dikirim".
///
/// Dibuka dari DetailScreen setelah form lamaran mengembalikan Lamaran.
/// Data yang DITERIMA: objek Lamaran (lewat arguments).
/// Data yang DIKEMBALIKAN: bool? lewat Navigator.pop
///   true = pengguna menekan "Lihat Status Lamaran" -> DetailScreen membuka
///          halaman detail lamaran; null = kembali biasa.
class LamaranSuksesScreen extends StatelessWidget {
  final Lamaran lamaran;

  const LamaranSuksesScreen({super.key, required this.lamaran});

  // Label dan ikon tahapan di timeline kecil
  static const _stepLabels = ['Terkirim', 'Diproses', 'Wawancara', 'Hasil'];
  static const _stepIcons = [
    Icons.check,
    Icons.hourglass_top,
    Icons.groups_outlined,
    Icons.flag_outlined,
  ];

  Future<void> _copyId(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: lamaran.id));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('ID lamaran disalin')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Cahaya dekoratif di belakang badge
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 288,
                height: 288,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x4D89F5E7),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4D89F5E7),
                      blurRadius: 64,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) =>
                            Transform.scale(scale: value, child: child),
                        child: _buildBadge(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Lamaran Berhasil Dikirim!',
                        textAlign: TextAlign.center,
                        style: _jakarta(24, FontWeight.w700, _ink,
                            spacing: -0.6),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          'Lamaranmu untuk posisi ${lamaran.jobTitle} di '
                          '${lamaran.company} sudah kami terima dan akan '
                          'segera diproses.',
                          textAlign: TextAlign.center,
                          style: _inter(14, FontWeight.w400, _muted,
                              height: 23),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildReceipt(context),
                      const SizedBox(height: 16),
                      _buildTips(),
                      const SizedBox(height: 24),
                      _buildButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Badge centang dengan lingkaran berlapis ----------
  Widget _buildBadge() {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x3D89F5E7),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _tile,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x4D6BD8CB),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _teal,
            ),
            child: const Icon(Icons.check, size: 30, color: Colors.white),
          ),
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.auto_awesome, size: 16, color: _teal),
          ),
          const Positioned(
            bottom: 12,
            left: 8,
            child: Opacity(
              opacity: 0.75,
              child: Icon(Icons.auto_awesome, size: 14, color: _blueDark),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kartu ringkasan lamaran (struk) ----------
  Widget _buildReceipt(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Garis gradien di atas kartu
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_blue, _teal, _blueDark]),
            ),
          ),

          // Baris header: ID lamaran + tombol Salin
          Container(
            color: const Color(0x99F0F3FF),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID LAMARAN',
                        style: _inter(11, FontWeight.w600, _hint,
                            spacing: 0.22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lamaran.id,
                        overflow: TextOverflow.ellipsis,
                        style: _inter(14, FontWeight.w700, _blue,
                            spacing: 0.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _chip,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _copyId(context),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy, size: 12, color: _muted),
                          const SizedBox(width: 4),
                          Text(
                            'Salin',
                            style: _inter(11, FontWeight.w600, _muted,
                                spacing: 0.22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lowongan + perusahaan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _chip,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.work_outline, size: 18, color: _blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lamaran.jobTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _jakarta(18, FontWeight.w600, _ink),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              lamaran.company,
                              overflow: TextOverflow.ellipsis,
                              style: _inter(12, FontWeight.w400, _muted),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _hint,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lamaran.jobType,
                            style: _inter(12, FontWeight.w500, _teal),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Detail: tanggal + lokasi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x66F0F3FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _detailRow(Icons.calendar_today_outlined,
                          'Tanggal Pengajuan', lamaran.tanggalLabel),
                      const SizedBox(height: 8),
                      _detailRow(Icons.location_on_outlined, 'Lokasi',
                          lamaran.jobLocation),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status saat ini
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _chip,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4069F2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'STATUS SAAT INI',
                          style: _inter(11, FontWeight.w600, _ink,
                              spacing: 0.22),
                        ),
                      ),
                      Text(
                        lamaran.status.label,
                        style: _inter(11, FontWeight.w500, _blueDark,
                            spacing: 0.22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Timeline kecil
                _buildTimeline(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: _hint),
        const SizedBox(width: 6),
        Text(label, style: _inter(12, FontWeight.w400, _muted)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: _inter(12, FontWeight.w500, _ink, spacing: 0.12),
          ),
        ),
      ],
    );
  }

  // ---------- Timeline: Terkirim -> Diproses -> Wawancara -> Hasil ----------
  Widget _buildTimeline() {
    final children = <Widget>[];
    for (var i = 0; i < _stepLabels.length; i++) {
      if (i > 0) {
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 11, 4, 0),
              child: Container(
                height: 2,
                // garis pertama sudah dilewati (biru), sisanya abu-abu
                color: i == 1 ? const Color(0x66004AC6) : _line,
              ),
            ),
          ),
        );
      }
      children.add(_buildStepNode(i));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildStepNode(int i) {
    final done = i == 0; // Terkirim: selesai
    final active = i == 1; // Diproses: tahap saat ini
    final circleColor = done ? _teal : (active ? _blue : _pendingBg);
    final iconColor = (done || active) ? Colors.white : _hint;
    final labelColor = done ? _teal : (active ? _blue : _hint);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
            boxShadow: active
                ? const [
                    BoxShadow(color: Color(0x33004AC6), spreadRadius: 2),
                  ]
                : null,
          ),
          child: Icon(_stepIcons[i], size: 12, color: iconColor),
        ),
        const SizedBox(height: 4),
        Text(
          _stepLabels[i],
          style: _inter(10, active ? FontWeight.w600 : FontWeight.w500,
              labelColor,
              height: 15),
        ),
      ],
    );
  }

  // ---------- Kotak "Langkah Selanjutnya" ----------
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _chip,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb_outline,
                size: 16, color: _blueDark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Langkah Selanjutnya',
                  style: _jakarta(18, FontWeight.w600, _ink),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pantau status lamaranmu secara berkala. Kamu akan '
                  'menerima notifikasi saat status lamaran berubah. '
                  'Sambil menunggu, jelajahi lowongan lain yang sesuai '
                  'minatmu.',
                  style: _inter(12, FontWeight.w400, _muted, height: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tombol aksi ----------
  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            // tutup halaman ini sambil mengirim sinyal `true` ke DetailScreen,
            // yang kemudian membuka halaman detail lamaran (LamaranDetailScreen)
            onPressed: () => Navigator.pop<bool>(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: Text(
              'Lihat Status Lamaran',
              style: _inter(14, FontWeight.w600, Colors.white, spacing: 0.14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            // kembali ke Home (daftar lowongan)
            onPressed: () =>
                Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home)),
            style: FilledButton.styleFrom(
              backgroundColor: _chip,
              foregroundColor: _ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.explore_outlined, size: 16),
            label: Text(
              'Cari Lowongan Lain',
              style: _inter(14, FontWeight.w600, _ink, spacing: 0.14),
            ),
          ),
        ),
      ],
    );
  }
}