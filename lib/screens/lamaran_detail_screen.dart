import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/lamaran_repository.dart';
import '../models/cv_document.dart';
import '../models/lamaran.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/status_badge.dart';

// ---------- Warna & gaya dari desain Figma "Detail Lamaran" ----------
const _tealDone = Color(0xFF007B71);
const _tealLight = Color(0xFFB3FFF3);
const _tealText = Color(0xFF006058);
const _red = Color(0xFFBA1A1A);
const _blue = Color(0xFF2563EB);
const _blueText = Color(0xFF1D4ED8);

// Warna dialog pembatalan (Figma "Dialog Konfirmasi Pembatalan Lamaran")
const _dangerRed = Color(0xFFDC2626);
const _dangerBg = Color(0xFFFEF2F2);
const _dangerBorder = Color(0xFFFEE2E2);
const _dangerText = Color(0xFF991B1B);
const _amberBg = Color(0xFFFEF3C7);
const _amberText = Color(0xFF92400E);

TextStyle _jakarta(double size, FontWeight w, Color c) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: c);

TextStyle _inter(double size, FontWeight w, Color c,
        {double? spacing, double? height}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: w,
      color: c,
      letterSpacing: spacing,
      height: height == null ? null : height / size,
    );

/// FR-07 (Read): detail satu lamaran + timeline status.
/// DATA MASUK : objek [Lamaran] lewat `arguments` (dikirim dari daftar).
/// DATA KELUAR: String? (pesan untuk daftar) lewat Navigator.pop.
///   null = tidak ada perubahan. Diisi di Step 5 (tarik) dan Step 6 (edit).
class LamaranDetailScreen extends StatefulWidget {
  final Lamaran lamaran;
  const LamaranDetailScreen({super.key, required this.lamaran});

  @override
  State<LamaranDetailScreen> createState() => _LamaranDetailScreenState();
}

class _LamaranDetailScreenState extends State<LamaranDetailScreen> {
  // ---------- STATE ----------
  // Disalin ke state karena di Step 6 datanya bisa berubah setelah diedit.
  late Lamaran _lamaran;
  // Hasil yang dikembalikan ke layar daftar saat layar ini ditutup.
  String? _hasilUntukDaftar;

  final _repository = LamaranRepository();
  bool _isProcessing = false; // sedang menghapus? (tombol nonaktif + spinner)
  bool _simulateError = false; // khusus demo: paksa pembatalan gagal

  @override
  void initState() {
    super.initState();
    _lamaran = widget.lamaran;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Tutup layar sambil MENGEMBALIKAN hasil ke layar daftar.
  void _kembali() {
    if (_isProcessing) return; // jangan keluar saat proses masih berjalan
    Navigator.pop<String>(context, _hasilUntukDaftar);
  }

  /// FR-08 (Update). Alur:
  /// Event (tap Edit) -> KIRIM Lamaran ke layar edit -> TUNGGU hasil ->
  /// hasil null = keluar tanpa menyimpan, hasil Lamaran = tampilkan data baru.
  Future<void> _edit() async {
    final hasil = await Navigator.pushNamed<Lamaran>(
      context,
      AppRoutes.lamaranEdit,
      arguments: _lamaran,
    );
    if (!mounted || hasil == null) return; // null = tidak ada perubahan

    // STATE: pakai data baru + siapkan pesan untuk layar daftar
    setState(() {
      _lamaran = hasil;
      _hasilUntukDaftar = 'Lamaran "${hasil.jobTitle}" berhasil diperbarui.';
    });
    _snack('Perubahan lamaran berhasil disimpan.'); // FEEDBACK
  }

  /// FR-09 (Delete). Alur:
  /// Event (tap) -> Validasi aturan -> Konfirmasi -> Loading -> Hasil -> Navigasi
  Future<void> _tarik() async {
    // 1) VALIDASI aturan bisnis: hanya status "diproses"
    if (!_lamaran.bisaDiubah) {
      _snack('Lamaran berstatus ${_lamaran.status.label} tidak dapat dibatalkan.');
      return;
    }

    // 2) KONFIRMASI: dialog mengembalikan true (ya) / false atau null (batal)
    final yakin = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x990F172A),
      builder: (_) => _TarikLamaranDialog(lamaran: _lamaran),
    );
    if (yakin != true || !mounted) return; // user membatalkan -> tidak ada apa-apa

    // 3) LOADING: state berubah -> tombol nonaktif + spinner
    setState(() => _isProcessing = true);
    try {
      await _repository.delete(_lamaran.id, simulateError: _simulateError);
      if (!mounted) return;
      // 4) HASIL + NAVIGASI: kembali ke daftar membawa pesan (String)
      Navigator.pop<String>(
        context,
        'Lamaran "${_lamaran.jobTitle}" berhasil dibatalkan.',
      );
    } on LamaranException catch (e) {
      if (!mounted) return;
      _snack(e.message); // aturan bisnis dilanggar / data tidak ditemukan
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', '')); // gagal jaringan
    } finally {
      if (mounted) setState(() => _isProcessing = false); // loading selalu berhenti
    }
  }

  // ====================== BUILD ======================
  @override
  Widget build(BuildContext context) {
    // PopScope: tombol back SISTEM (Android) juga membawa hasil ke daftar.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _kembali();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildOverview(),
            const SizedBox(height: 16),
            _buildTimeline(),
            const SizedBox(height: 16),
            _buildDokumen(),
            const SizedBox(height: 16),
            _buildDataPelamar(),
            const SizedBox(height: 16),
            _buildAksi(),
            _buildBantuan(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: _kembali,
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.work, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text('JobConnect',
              style: _jakarta(18, FontWeight.w600, AppColors.textPrimary)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Bagikan',
          icon: const Icon(Icons.share_outlined,
              size: 20, color: AppColors.textSecondary),
          onPressed: () => _snack('Fitur bagikan belum tersedia'),
        ),
        PopupMenuButton<String>(
          tooltip: 'Pilihan lainnya',
          icon: const Icon(Icons.more_vert,
              size: 20, color: AppColors.textSecondary),
          onSelected: (value) {
            if (value == 'error') {
              setState(() => _simulateError = !_simulateError);
              _snack(_simulateError
                  ? 'Mode simulasi gagal membatalkan: AKTIF'
                  : 'Mode simulasi gagal membatalkan: nonaktif');
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'error',
              child: Text(_simulateError
                  ? 'Matikan simulasi gagal membatalkan'
                  : 'Simulasi gagal membatalkan'),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4, right: 16),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.segmentBackground,
            child: Icon(Icons.person, size: 18, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // ---------- Section 1: ringkasan lamaran ----------
  Widget _buildOverview() {
    final l = _lamaran;
    final jumlahBerkas = l.dokumenTambahan == null ? 1 : 2;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          l.id,
                          overflow: TextOverflow.ellipsis,
                          style: _inter(
                              11, FontWeight.w600, AppColors.textSecondary,
                              spacing: 0.22),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.tag, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: l.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.jobTitle,
                      style: _jakarta(20, FontWeight.w600, AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.company,
                      style: _inter(14, FontWeight.w500, AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l.jobLocation,
                            style: _inter(
                                12, FontWeight.w400, AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                icon: Icons.work_outline,
                text: l.jobType,
                bg: AppColors.inputFill,
                fg: AppColors.primary,
              ),
              _Pill(
                icon: Icons.attach_file,
                text: '$jumlahBerkas berkas dilampirkan',
                bg: AppColors.badgeBlueBg,
                fg: _blueText,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Dikirim pada ${l.tanggalLabel}',
                style: _inter(12, FontWeight.w400, AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Section 2: timeline status ----------
  /// Isi timeline MENGIKUTI status lamaran (state-driven UI).
  List<_StepData> _buildSteps() {
    final l = _lamaran;
    final terkirim = _StepData(
      state: _StepState.done,
      title: 'Lamaran Terkirim',
      description: 'Berkas pendaftaranmu sudah diterima oleh ${l.company}.',
      trailing: l.tanggalLabel,
    );
    switch (l.status) {
      case LamaranStatus.diproses:
        return [
          terkirim,
          _StepData(
            state: _StepState.active,
            title: 'Diproses',
            description: 'Berkas sedang ditinjau oleh tim ${l.company}.',
          ),
          const _StepData(
            state: _StepState.pending,
            title: 'Diterima / Ditolak',
            description: 'Keputusan akhir atas lamaranmu.',
          ),
        ];
      case LamaranStatus.diterima:
        return [
          terkirim,
          const _StepData(
            state: _StepState.done,
            title: 'Diproses',
            description: 'Berkasmu sudah selesai ditinjau.',
          ),
          const _StepData(
            state: _StepState.done,
            title: 'Diterima',
            description: 'Selamat! Lamaranmu diterima.',
          ),
        ];
      case LamaranStatus.ditolak:
        return [
          terkirim,
          const _StepData(
            state: _StepState.done,
            title: 'Diproses',
            description: 'Berkasmu sudah selesai ditinjau.',
          ),
          const _StepData(
            state: _StepState.rejected,
            title: 'Ditolak',
            description: 'Lamaranmu belum dapat diterima kali ini.',
          ),
        ];
    }
  }

  (String, String) get _calloutText {
    final company = _lamaran.company;
    return switch (_lamaran.status) {
      LamaranStatus.diproses => (
          'Apa yang terjadi sekarang?',
          'Lamaranmu sedang ditinjau oleh $company. Pantau halaman ini untuk '
              'melihat perubahan status. Selama masih "Diproses", kamu masih '
              'bisa mengedit atau menarik lamaran.',
        ),
      LamaranStatus.diterima => (
          'Selamat, lamaranmu diterima!',
          '$company akan menghubungimu lewat email atau nomor HP yang kamu '
              'cantumkan untuk langkah berikutnya.',
        ),
      LamaranStatus.ditolak => (
          'Lamaranmu belum diterima',
          'Jangan menyerah. Cari lowongan lain yang sesuai minatmu dan '
              'ajukan lamaran baru.',
        ),
    };
  }

  Widget _buildTimeline() {
    final steps = _buildSteps();
    final (judul, isi) = _calloutText;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle('Status Lamaran'),
              Text('Lacak progres',
                  style: _inter(11, FontWeight.w600, AppColors.textSecondary,
                      spacing: 0.22)),
            ],
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < steps.length; i++)
            _TimelineStep(data: steps[i], isLast: i == steps.length - 1),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.info_outline,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(judul,
                          style: _jakarta(
                              12, FontWeight.w600, AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(isi,
                          style: _inter(
                              12, FontWeight.w400, AppColors.textSecondary,
                              height: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Section 3: dokumen terlampir ----------
  Widget _buildDokumen() {
    final l = _lamaran;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: _SectionTitle('Dokumen Terlampir')),
              const Icon(Icons.folder_open_outlined,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Berkas yang kamu kirim bersama lamaran ini.',
            style: _inter(12, FontWeight.w400, AppColors.textSecondary,
                height: 16),
          ),
          const SizedBox(height: 14),
          _FileCard(
            tag: 'CV',
            doc: l.cv,
            iconColor: AppColors.primary,
            onView: () => _snack('Pratinjau berkas belum tersedia di versi demo'),
            onDownload: () => _snack('Unduh berkas belum tersedia di versi demo'),
          ),
          if (l.dokumenTambahan != null) ...[
            const SizedBox(height: 14),
            _FileCard(
              tag: 'Tambahan',
              doc: l.dokumenTambahan!,
              iconColor: _blueText,
              onView: () =>
                  _snack('Pratinjau berkas belum tersedia di versi demo'),
              onDownload: () =>
                  _snack('Unduh berkas belum tersedia di versi demo'),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    size: 14, color: _tealText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Berkas lamaranmu bersifat pribadi dan tidak dapat dilihat '
                    'pengguna lain.',
                    style: _inter(11, FontWeight.w600, AppColors.textSecondary,
                        spacing: 0.22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Data pelamar (dibutuhkan untuk melihat hasil edit di Step 6) ----------
  Widget _buildDataPelamar() {
    final l = _lamaran;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Data Pelamar'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Nama', value: l.namaPelamar),
          _InfoRow(label: 'Email', value: l.email),
          _InfoRow(label: 'No. HP', value: l.noHp),
          _InfoRow(
            label: 'Pesan',
            value: l.pesan.trim().isEmpty ? '-' : l.pesan,
          ),
        ],
      ),
    );
  }

  // ---------- Section 4: aksi lamaran ----------
  Widget _buildAksi() {
    final l = _lamaran;
    final bisa = l.bisaDiubah; // aturan bisnis: hanya status "diproses"
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Aksi Lamaran'),
          const SizedBox(height: 4),
          Text(
            'Kelola berkas atau perbarui kontakmu sebelum review berakhir.',
            style: _inter(12, FontWeight.w400, AppColors.textSecondary,
                height: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              // onPressed null = tombol otomatis nonaktif (abu-abu)
              // Desain Figma punya layar Ubah Lamaran versi read-only (status
              // Diterima), jadi tombol Edit aktif untuk SEMUA status.
              onPressed: _isProcessing ? null : _edit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text('Edit Lamaran',
                  style: _inter(14, FontWeight.w600, Colors.white,
                      spacing: 0.14)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.segmentBackground,
                disabledForegroundColor: AppColors.textHint,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              onPressed: bisa && !_isProcessing ? _tarik : null,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _red,
                      ),
                    )
                  : const Icon(Icons.delete_outline, size: 18),
              label: Text(_isProcessing ? 'Membatalkan...' : 'Tarik Lamaran',
                  style: _inter(14, FontWeight.w600, _red, spacing: 0.14)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.badgeBlueBg,
                foregroundColor: _red,
                disabledBackgroundColor: AppColors.inputFill,
                disabledForegroundColor: AppColors.textHint,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.info_outline, size: 18, color: _blueText),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bisa
                        ? 'Kamu dapat mengedit data atau menarik lamaran selama '
                            'statusnya masih "Diproses". Setelah ada keputusan, '
                            'lamaran tidak bisa diubah lagi.'
                        : 'Lamaran berstatus ${l.status.label} sudah final, '
                            'sehingga datanya hanya bisa dilihat dan tidak '
                            'dapat diubah atau ditarik.',
                    style: _inter(12, FontWeight.w400, AppColors.textSecondary,
                        height: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBantuan() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: () => _snack('Pusat bantuan belum tersedia'),
          icon: const Icon(Icons.help_outline,
              size: 14, color: AppColors.textSecondary),
          label: Text(
            'Butuh bantuan? Hubungi tim JobConnect',
            style: _inter(11, FontWeight.w600, AppColors.textSecondary,
                spacing: 0.22),
          ),
        ),
      ),
    );
  }
}

// ====================== WIDGET PEMBANTU ======================

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: _jakarta(18, FontWeight.w600, AppColors.textPrimary));
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
  const _Pill({
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(text,
              style: _inter(11, FontWeight.w600, fg, spacing: 0.22)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label,
                style: _inter(12, FontWeight.w400, AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: _inter(12, FontWeight.w600, AppColors.textPrimary,
                    height: 18)),
          ),
        ],
      ),
    );
  }
}

/// Kartu satu berkas (CV / dokumen tambahan).
class _FileCard extends StatelessWidget {
  final String tag;
  final CvDocument doc;
  final Color iconColor;
  final VoidCallback onView;
  final VoidCallback onDownload;

  const _FileCard({
    required this.tag,
    required this.doc,
    required this.iconColor,
    required this.onView,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD8E3FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: _inter(10, FontWeight.w600, Colors.white,
                            spacing: 0.25),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doc.name,
                        overflow: TextOverflow.ellipsis,
                        style: _jakarta(
                            12, FontWeight.w600, AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${doc.extension.toUpperCase()} • ${doc.sizeLabel}',
                  style: _inter(11, FontWeight.w600, AppColors.textSecondary,
                      spacing: 0.22),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Lihat',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.visibility_outlined,
                size: 18, color: AppColors.textSecondary),
            onPressed: onView,
          ),
          IconButton(
            tooltip: 'Unduh',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.download_outlined,
                size: 18, color: AppColors.textSecondary),
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}

// ---------- Timeline ----------
enum _StepState { done, active, pending, rejected }

class _StepData {
  final _StepState state;
  final String title;
  final String description;
  final String? trailing; // teks kecil di kanan judul (mis. tanggal)

  const _StepData({
    required this.state,
    required this.title,
    required this.description,
    this.trailing,
  });
}

class _TimelineStep extends StatelessWidget {
  final _StepData data;
  final bool isLast;

  const _TimelineStep({required this.data, required this.isLast});

  Widget _buildCircle() {
    switch (data.state) {
      case _StepState.done:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
              color: _tealDone, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 18, color: _tealLight),
        );
      case _StepState.active:
        // lingkaran biru + lingkaran transparan di luarnya (efek "denyut")
        return SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -4,
                top: -4,
                right: -4,
                bottom: -4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Center(
                  child: Icon(Icons.hourglass_top,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      case _StepState.pending:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
              color: AppColors.segmentBackground, shape: BoxShape.circle),
          child: const Icon(Icons.flag_outlined,
              size: 16, color: AppColors.textSecondary),
        );
      case _StepState.rejected:
        return Container(
          width: 32,
          height: 32,
          decoration:
              const BoxDecoration(color: _red, shape: BoxShape.circle),
          child: const Icon(Icons.close, size: 18, color: Colors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = data.state == _StepState.active;
    final isPending = data.state == _StepState.pending;
    final titleColor = switch (data.state) {
      _StepState.active => AppColors.primary,
      _StepState.rejected => _red,
      _ => AppColors.textPrimary,
    };
    // garis ke langkah berikutnya: biru jika langkah ini sudah selesai
    final lineColor =
        data.state == _StepState.done ? AppColors.primary : AppColors.divider;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                _buildCircle(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Opacity(
              opacity: isPending ? 0.6 : 1,
              child: Padding(
                padding: EdgeInsets.only(top: 2, bottom: isLast ? 0 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  data.title,
                                  style: _jakarta(
                                    14,
                                    isActive ? FontWeight.w700 : FontWeight.w600,
                                    titleColor,
                                  ),
                                ),
                              ),
                              if (isActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _blue,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.pill),
                                  ),
                                  child: Text(
                                    'Saat ini',
                                    style: _inter(
                                        11, FontWeight.w600, Colors.white,
                                        spacing: 0.22),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (data.trailing != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            data.trailing!,
                            style: _inter(
                                11, FontWeight.w600, AppColors.textSecondary,
                                spacing: 0.22),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.description,
                      style: _inter(12, FontWeight.w400,
                          AppColors.textSecondary,
                          height: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Dialog konfirmasi pembatalan (FR-09) ----------
/// Mengembalikan true (Ya, batalkan) atau false (Tidak, kembali) lewat
/// Navigator.pop. Menutup dialog lewat area gelap = null -> dianggap batal.
class _TarikLamaranDialog extends StatelessWidget {
  final Lamaran lamaran;
  const _TarikLamaranDialog({required this.lamaran});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _dangerBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    size: 28, color: _dangerRed),
              ),
              const SizedBox(height: 16),
              Text(
                'Batalkan Lamaran?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.45,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: _inter(12, FontWeight.w400, AppColors.textSecondary,
                      height: 20),
                  children: [
                    const TextSpan(
                      text: 'Apakah kamu yakin ingin membatalkan lamaran '
                          'untuk posisi ',
                    ),
                    TextSpan(
                      text: '${lamaran.jobTitle} di ${lamaran.company}',
                      style: _inter(12, FontWeight.w600, AppColors.textPrimary,
                          height: 20),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // ringkasan lamaran yang akan dibatalkan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xB3F0F3FF),
                  border: Border.all(color: const Color(0x66C3C6D7)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status lamaran',
                          style: _inter(
                              11, FontWeight.w600, AppColors.textPrimary,
                              spacing: 0.22),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _amberBg,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            lamaran.status.label,
                            style: _inter(11, FontWeight.w500, _amberText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tanggal pengajuan',
                            style: _inter(
                                12, FontWeight.w400, AppColors.textSecondary,
                                height: 18)),
                        Text(lamaran.tanggalLabel,
                            style: _inter(
                                12, FontWeight.w400, AppColors.textSecondary,
                                height: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // peringatan tindakan permanen
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _dangerBg,
                  border: Border.all(color: _dangerBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.info_outline,
                          size: 15, color: _dangerText),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tindakan ini tidak dapat dibatalkan. Lamaran beserta '
                        'berkas yang kamu lampirkan akan dihapus permanen.',
                        style: _inter(12, FontWeight.w500, _dangerText,
                            height: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text('Ya, Batalkan Lamaran',
                      style: _inter(14, FontWeight.w600, Colors.white,
                          spacing: 0.14)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _dangerRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF334155),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Tidak, Kembali',
                      style: _inter(
                          14, FontWeight.w600, const Color(0xFF334155),
                          spacing: 0.14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}