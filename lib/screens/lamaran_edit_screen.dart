import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/lamaran_repository.dart';
import '../models/cv_document.dart';
import '../models/lamaran.dart';
import '../services/cv_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/lamaran_validators.dart';
import '../utils/validators.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';

// ---------- Warna & gaya dari desain Figma "Ubah Lamaran" ----------
const _red = Color(0xFFBA1A1A);
const _teal = Color(0xFF006058);
const _noticeIcon = Color(0xFF4069F2);
const _amberBg = Color(0xFFFFFBEB);
const _amberIconBg = Color(0xFFFEF3C7);
const _amberText = Color(0xFF92400E);
const _amberTitle = Color(0xFF451A03);
const _fileIconBg = Color(0xFFD8E3FB);

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

/// FR-08 (Update): ubah data lamaran.
/// DATA MASUK : objek [Lamaran] lewat `arguments`.
/// DATA KELUAR: objek [Lamaran] BARU hasil edit lewat Navigator.pop,
///              atau null jika pengguna keluar tanpa menyimpan.
/// Status "Diproses"  -> form bisa diedit.
/// Status lain        -> tampilan read-only (data terkunci).
class LamaranEditScreen extends StatefulWidget {
  final Lamaran lamaran;
  const LamaranEditScreen({super.key, required this.lamaran});

  @override
  State<LamaranEditScreen> createState() => _LamaranEditScreenState();
}

class _LamaranEditScreenState extends State<LamaranEditScreen> {
  static const _maxPesan = 300;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _hpController;
  late final TextEditingController _pesanController;
  final _repository = LamaranRepository();

  // ---------- STATE ----------
  late CvDocument _cv; // CV wajib: selalu ada, bisa diganti
  CvDocument? _extra; // dokumen tambahan: opsional
  String? _cvError;
  String? _extraError;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _simulateError = false; // khusus demo: paksa penyimpanan gagal

  bool get _readOnly => !widget.lamaran.bisaDiubah;

  @override
  void initState() {
    super.initState();
    final l = widget.lamaran;
    // FORM TERISI DATA LAMA: controller diberi nilai awal dari lamaran
    _namaController = TextEditingController(text: l.namaPelamar);
    _emailController = TextEditingController(text: l.email);
    _hpController = TextEditingController(text: l.noHp);
    _pesanController = TextEditingController(text: l.pesan);
    _cv = l.cv;
    _extra = l.dokumenTambahan;
    // setiap ketikan -> rebuild, supaya tombol Simpan & penghitung ikut berubah
    for (final c in [
      _namaController,
      _emailController,
      _hpController,
      _pesanController,
    ]) {
      c.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  // ---------- Deteksi perubahan (dirty) ----------
  static bool _sameDoc(CvDocument? a, CvDocument? b) {
    if (a == null || b == null) return a == b; // null == null -> true
    return a.name == b.name && a.sizeInBytes == b.sizeInBytes;
  }

  bool get _isDirty {
    final l = widget.lamaran;
    return _namaController.text.trim() != l.namaPelamar ||
        _emailController.text.trim() != l.email ||
        _hpController.text.trim() != l.noHp ||
        _pesanController.text.trim() != l.pesan ||
        !_sameDoc(_cv, l.cv) ||
        !_sameDoc(_extra, l.dokumenTambahan);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------- Pilih / ganti / hapus berkas ----------
  Future<void> _pickCv() async {
    if (_isSubmitting) return;
    try {
      final doc = await CvPicker.pickCv();
      if (!mounted || doc == null) return; // null = user batal
      setState(() {
        _cv = doc;
        _cvError = LamaranValidators.cv(doc);
      });
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal membuka berkas. Coba lagi.');
    }
  }

  Future<void> _pickExtra() async {
    if (_isSubmitting) return;
    try {
      final doc = await CvPicker.pickCv();
      if (!mounted || doc == null) return;
      setState(() {
        _extra = doc;
        _extraError = LamaranValidators.dokumenTambahan(doc);
      });
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal membuka berkas. Coba lagi.');
    }
  }

  void _removeExtra() {
    if (_isSubmitting) return;
    setState(() {
      _extra = null;
      _extraError = null;
    });
  }

  // ---------- EVENT: tombol "Simpan Perubahan" ----------
  Future<void> _simpan() async {
    FocusScope.of(context).unfocus(); // tutup keyboard

    // VALIDATION: aturan SAMA dengan form pengajuan (FR-06)
    final formValid = _formKey.currentState?.validate() ?? false;
    final cvError = LamaranValidators.cv(_cv);
    final extraError = LamaranValidators.dokumenTambahan(_extra);
    setState(() {
      _cvError = cvError;
      _extraError = extraError;
    });
    if (!formValid || cvError != null || extraError != null) {
      _snack('Periksa kembali isian yang masih salah.');
      return;
    }

    // STATE: masuk ke loading
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final hasil = await _repository.update(
        id: widget.lamaran.id,
        namaPelamar: _namaController.text.trim(),
        email: _emailController.text.trim(),
        noHp: _hpController.text.trim(),
        pesan: _pesanController.text.trim(),
        cv: _cv,
        dokumenTambahan: _extra,
        simulateError: _simulateError,
      );
      if (!mounted) return;
      // NAVIGATION/RESULT: tutup layar sambil MENGEMBALIKAN Lamaran yang baru
      Navigator.pop<Lamaran>(context, hasil);
    } on LamaranException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message); // aturan bisnis dilanggar
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ---------- Keluar tanpa menyimpan ----------
  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buang perubahan?'),
        content: const Text('Perubahan belum disimpan. Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Lanjut Mengedit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Buang'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _batal() async {
    if (_isSubmitting) return; // jangan keluar saat proses berjalan
    if (!_readOnly && _isDirty) {
      final buang = await _confirmDiscard();
      if (!buang || !mounted) return;
    }
    Navigator.pop<Lamaran>(context); // hasil null = tidak ada perubahan
  }

  // ====================== BUILD ======================
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _batal();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _readOnly ? _buildReadOnlyBody() : _buildEditBody(),
        bottomNavigationBar: _readOnly ? null : _buildEditBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final circle = Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _readOnly ? Icons.lock_outline : Icons.more_horiz,
        size: 16,
        color: Colors.white,
      ),
    );
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: _batal,
      ),
      title: Text('Ubah Lamaran',
          style: _jakarta(18, FontWeight.w600, AppColors.textPrimary)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _readOnly
              ? circle
              : PopupMenuButton<String>(
                  tooltip: 'Pilihan lainnya',
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'error') {
                      setState(() => _simulateError = !_simulateError);
                      _snack(_simulateError
                          ? 'Mode simulasi gagal menyimpan: AKTIF'
                          : 'Mode simulasi gagal menyimpan: nonaktif');
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'error',
                      child: Text(_simulateError
                          ? 'Matikan simulasi gagal menyimpan'
                          : 'Simulasi gagal menyimpan'),
                    ),
                  ],
                  child: circle,
                ),
        ),
      ],
    );
  }

  // ====================== MODE EDIT (status Diproses) ======================
  Widget _buildEditBody() {
    final l = widget.lamaran;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (_errorMessage != null) ...[
            ErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          // banner informasi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.segmentBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4069F2).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline,
                      size: 17, color: _noticeIcon),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lamaran hanya dapat diubah selama status masih Diproses.',
                        style: _inter(
                            14, FontWeight.w600, AppColors.textPrimary,
                            spacing: 0.14, height: 19),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Diajukan pada ${l.tanggalLabel}',
                        style: _inter(
                            12, FontWeight.w400, AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildJobCard(),
          const SizedBox(height: 16),
          _buildPersonalCard(),
          const SizedBox(height: 16),
          _buildCvCard(),
          const SizedBox(height: 16),
          _buildExtraCard(),
          const SizedBox(height: 16),
          _buildPesanCard(),
        ],
      ),
    );
  }

  Widget _buildJobCard() {
    final l = widget.lamaran;
    final initial = l.company.isEmpty ? '?' : l.company[0].toUpperCase();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(initial,
                    style: _jakarta(20, FontWeight.w700, Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.jobTitle,
                        style: _jakarta(
                            18, FontWeight.w600, AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(l.company,
                        style: _inter(
                            12, FontWeight.w400, AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: l.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Pill(
                text: l.jobType,
                bg: AppColors.badgeBlueBg,
                fg: AppColors.badgeBlueText,
              ),
              _Pill(
                text: l.jobLocation,
                bg: _fileIconBg,
                fg: _teal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _CardTitle('Informasi Pribadi'),
              Text('Wajib diisi',
                  style: _inter(11, FontWeight.w600, AppColors.textHint,
                      spacing: 0.22)),
            ],
          ),
          const SizedBox(height: 16),
          _field(
            label: 'Nama Lengkap',
            controller: _namaController,
            validator: LamaranValidators.nama,
            capitalization: TextCapitalization.words,
            action: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _field(
            label: 'Email',
            controller: _emailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            action: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _field(
            label: 'Nomor Telepon',
            controller: _hpController,
            validator: LamaranValidators.noHp,
            keyboardType: TextInputType.phone,
            action: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildCvCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _CardTitle('CV / Resume'),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 13, color: _teal),
                  const SizedBox(width: 4),
                  Text('Terlampir',
                      style: _inter(11, FontWeight.w600, _teal,
                          spacing: 0.22)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _FileItem(
            doc: _cv,
            iconColor: AppColors.primary,
            actions: [
              _SquareButton(
                icon: Icons.sync,
                tooltip: 'Ganti CV',
                onTap: _isSubmitting ? null : _pickCv,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_cvError != null)
            Text(_cvError!, style: _inter(12, FontWeight.w500, _red))
          else
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Format PDF atau DOCX, maksimal 5 MB.',
                    style: _inter(12, FontWeight.w400,
                        AppColors.textSecondary)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildExtraCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _CardTitle('Dokumen Tambahan'),
              Text('Opsional',
                  style: _inter(11, FontWeight.w600,
                      AppColors.textSecondary, spacing: 0.22)),
            ],
          ),
          const SizedBox(height: 8),
          if (_extra != null)
            _FileItem(
              doc: _extra!,
              iconColor: AppColors.badgeBlueText,
              actions: [
                _SquareButton(
                  icon: Icons.sync,
                  tooltip: 'Ganti dokumen',
                  onTap: _isSubmitting ? null : _pickExtra,
                ),
                _SquareButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Hapus dokumen',
                  onTap: _isSubmitting ? null : _removeExtra,
                ),
              ],
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isSubmitting ? null : _pickExtra,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.segmentBackground),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.upload_file,
                        size: 22, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text('Tambah dokumen (PDF/DOCX, maks. 5 MB)',
                        style: _inter(12, FontWeight.w600,
                            AppColors.primary)),
                  ],
                ),
              ),
            ),
          if (_extraError != null) ...[
            const SizedBox(height: 8),
            Text(_extraError!, style: _inter(12, FontWeight.w500, _red)),
          ],
        ],
      ),
    );
  }

  Widget _buildPesanCard() {
    final length = _pesanController.text.length;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _CardTitle('Pesan untuk Recruiter'),
              Text('Opsional',
                  style: _inter(11, FontWeight.w600,
                      AppColors.textSecondary, spacing: 0.22)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _pesanController,
            enabled: !_isSubmitting,
            maxLines: 5,
            minLines: 4,
            maxLength: _maxPesan,
            style: _inter(14, FontWeight.w400, AppColors.textPrimary,
                height: 20),
            decoration: _decoration().copyWith(counterText: ''),
            validator: LamaranValidators.pesan,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$length/$_maxPesan',
                style: _inter(12, FontWeight.w400, AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  // bilah bawah: tombol Simpan aktif hanya jika ada perubahan
  Widget _buildEditBar() {
    final dirty = _isDirty;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF2F9F9FF),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline,
                      size: 13, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Text(
                    dirty
                        ? 'Ada perubahan yang belum disimpan'
                        : 'Belum ada perubahan untuk disimpan',
                    style: _inter(12, FontWeight.w500,
                        AppColors.textSecondary, spacing: 0.12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  // null = tombol nonaktif (abu-abu) saat belum ada perubahan
                  onPressed: dirty && !_isSubmitting ? _simpan : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.textHint),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan',
                    style: _inter(14, FontWeight.w600,
                        dirty ? Colors.white : AppColors.textHint,
                        spacing: 0.14),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _fileIconBg,
                    disabledForegroundColor: AppColors.textHint,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: _isSubmitting ? null : _batal,
                  child: Text('Batal',
                      style: _inter(14, FontWeight.w600,
                          AppColors.textSecondary, spacing: 0.14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== MODE READ-ONLY (Diterima / Ditolak) ======================
  Widget _buildReadOnlyBody() {
    final l = widget.lamaran;
    final diterima = l.status == LamaranStatus.diterima;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // banner kuning: kenapa data dikunci
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _amberBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _amberIconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline,
                    size: 18, color: _amberText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lamaran tidak dapat diubah',
                      style: _jakarta(18, FontWeight.w700, _amberTitle),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      diterima
                          ? 'Lamaranmu sudah diterima oleh ${l.company}, '
                              'sehingga datanya dikunci. Kamu hanya dapat '
                              'melihatnya.'
                          : 'Lamaranmu sudah diputuskan oleh ${l.company}, '
                              'sehingga datanya dikunci. Kamu hanya dapat '
                              'melihatnya.',
                      style: _inter(12, FontWeight.w400, _amberText,
                          height: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildJobCard(),
        const SizedBox(height: 16),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _CardTitle('Informasi Pribadi'),
                  const _LockedChip(),
                ],
              ),
              const SizedBox(height: 16),
              _LockedField(label: 'Nama Lengkap', value: l.namaPelamar),
              const SizedBox(height: 14),
              _LockedField(label: 'Email', value: l.email),
              const SizedBox(height: 14),
              _LockedField(label: 'Nomor Telepon', value: l.noHp),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _CardTitle('CV / Resume'),
                  const _LockedChip(),
                ],
              ),
              const SizedBox(height: 12),
              _FileItem(
                doc: l.cv,
                iconColor: AppColors.primary,
                actions: [
                  _SquareButton(
                    icon: Icons.visibility_outlined,
                    tooltip: 'Lihat',
                    onTap: () =>
                        _snack('Pratinjau berkas belum tersedia di versi demo'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (l.dokumenTambahan != null) ...[
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _CardTitle('Dokumen Tambahan'),
                    const _LockedChip(),
                  ],
                ),
                const SizedBox(height: 12),
                _FileItem(
                  doc: l.dokumenTambahan!,
                  iconColor: AppColors.badgeBlueText,
                  actions: [
                    _SquareButton(
                      icon: Icons.visibility_outlined,
                      tooltip: 'Lihat',
                      onTap: () => _snack(
                          'Pratinjau berkas belum tersedia di versi demo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _CardTitle('Pesan untuk Recruiter'),
                  const Icon(Icons.lock_outline,
                      size: 15, color: AppColors.textHint),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l.pesan.trim().isEmpty ? '-' : l.pesan,
                  style: _inter(14, FontWeight.w400,
                      AppColors.textSecondary, height: 23),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x80DBE1FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.info_outline,
                    size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Jika ada kesalahan data pada lamaran yang sudah diputuskan, '
                  'silakan hubungi tim JobConnect atau pihak ${l.company}.',
                  style: _inter(12, FontWeight.w400,
                      const Color(0xFF00174B), height: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: _batal,
            icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
            label: Text('Lihat Status Lamaran',
                style: _inter(14, FontWeight.w600, Colors.white,
                    spacing: 0.14)),
            style: FilledButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // ====================== PEMBANTU ======================
  InputDecoration _decoration({String? hint}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: _inter(14, FontWeight.w400, AppColors.textHint),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(AppColors.divider),
      enabledBorder: border(AppColors.divider),
      disabledBorder: border(AppColors.divider),
      focusedBorder: border(AppColors.primary, 1.5),
      errorBorder: border(_red),
      focusedErrorBorder: border(_red, 1.5),
      errorStyle: _inter(12, FontWeight.w500, _red),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? action,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: _inter(14, FontWeight.w600, AppColors.textPrimary,
                spacing: 0.14),
            children: [
              TextSpan(
                  text: ' *', style: _inter(14, FontWeight.w600, _red)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: !_isSubmitting,
          keyboardType: keyboardType,
          textInputAction: action,
          textCapitalization: capitalization,
          style: _inter(14, FontWeight.w400, AppColors.textPrimary),
          decoration: _decoration(),
          validator: validator,
        ),
      ],
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

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: _jakarta(18, FontWeight.w600, AppColors.textPrimary));
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(text,
          style: _inter(11, FontWeight.w600, fg, spacing: 0.22)),
    );
  }
}

class _LockedChip extends StatelessWidget {
  const _LockedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline,
              size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('Terkunci',
              style: _inter(11, FontWeight.w600, AppColors.textSecondary,
                  spacing: 0.22)),
        ],
      ),
    );
  }
}

class _LockedField extends StatelessWidget {
  final String label;
  final String value;
  const _LockedField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: _inter(12, FontWeight.w500, AppColors.textSecondary,
                spacing: 0.12)),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: _inter(14, FontWeight.w500, AppColors.textSecondary),
                ),
              ),
              const Icon(Icons.lock_outline,
                  size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu satu berkas dengan deretan tombol aksi di kanan.
class _FileItem extends StatelessWidget {
  final CvDocument doc;
  final Color iconColor;
  final List<Widget> actions;

  const _FileItem({
    required this.doc,
    required this.iconColor,
    required this.actions,
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
              color: _fileIconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined,
                size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  overflow: TextOverflow.ellipsis,
                  style: _inter(14, FontWeight.w600, AppColors.textPrimary,
                      spacing: 0.14),
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.extension.toUpperCase()} • ${doc.sizeLabel}',
                  style:
                      _inter(12, FontWeight.w400, AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            actions[i],
          ],
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _SquareButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.badgeBlueBg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              size: 16,
              color: onTap == null
                  ? AppColors.textHint
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}