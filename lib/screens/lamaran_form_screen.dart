import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/lamaran_repository.dart';
import '../models/cv_document.dart';
import '../models/job.dart';
import '../services/cv_picker.dart';
import '../utils/lamaran_validators.dart';
import '../utils/validators.dart';
import '../widgets/state_views.dart';

// ---------- Warna & gaya dari desain Figma "Form Ajukan Lamaran" ----------
const _pageBg = Color(0xFFF8FAFC);
const _ink = Color(0xFF1E293B);
const _blue = Color(0xFF2563EB);
const _indigo = Color(0xFF4F46E5);
const _slate500 = Color(0xFF64748B);
const _slate400 = Color(0xFF94A3B8);
const _slate300 = Color(0xFFCBD5E1);
const _border = Color(0xFFE2E8F0);
const _divider = Color(0xFFF1F5F9);
const _red = Color(0xFFEF4444);
const _redBg = Color(0xFFFEF2F2);
const _redBorder = Color(0xFFFEE2E2);
const _green = Color(0xFF059669);
const _greenText = Color(0xFF047857);
const _greenBg = Color(0xFFECFDF5);
const _blueBg = Color(0xFFEFF6FF);

TextStyle _inter(double size, FontWeight w, Color c, {double? height}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: w,
      color: c,
      height: height == null ? null : height / size,
    );

TextStyle _jakarta(double size, FontWeight w, Color c) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: c);

/// FR-06 (Create): form pengajuan lamaran + upload CV.
///
/// Alur workflow:
///   Input/Event  -> pengguna mengisi form & menekan "Kirim Lamaran"
///   State        -> _isSubmitting, _errorMessage, CV terpilih, isi controller
///   Validation   -> validator tiap field + validasi CV (format & ukuran)
///   Feedback     -> pesan error di field, SnackBar, loading, ErrorBanner
///   Navigation   -> Navigator.pop(context, lamaran) : mengembalikan Lamaran
///                   ke DetailScreen
class LamaranFormScreen extends StatefulWidget {
  // Data yang DITERIMA dari DetailScreen (lewat arguments)
  final Job job;

  const LamaranFormScreen({super.key, required this.job});

  @override
  State<LamaranFormScreen> createState() => _LamaranFormScreenState();
}

class _LamaranFormScreenState extends State<LamaranFormScreen> {
  static const _maxPesan = 300;

  // (1) kunci Form + kunci field dokumen + controller
  final _formKey = GlobalKey<FormState>();
  final _cvKey = GlobalKey<FormFieldState<CvDocument>>();
  final _extraKey = GlobalKey<FormFieldState<CvDocument>>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();
  final _pesanController = TextEditingController();

  final _repository = LamaranRepository();

  // (2) variabel state
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _simulateError = false; // khusus demo: paksa pengiriman gagal

  CvDocument? get _cv => _cvKey.currentState?.value;
  CvDocument? get _extraDoc => _extraKey.currentState?.value;

  bool get _hasUnsavedInput =>
      _namaController.text.isNotEmpty ||
      _emailController.text.isNotEmpty ||
      _hpController.text.isNotEmpty ||
      _pesanController.text.isNotEmpty ||
      _cv != null ||
      _extraDoc != null;

  // (3) controller wajib dibuang
  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // (4) pilih dokumen -> simpan ke FormField agar ikut divalidasi
  Future<void> _pickDoc(
    GlobalKey<FormFieldState<CvDocument>> key,
    String title,
  ) async {
    if (_isSubmitting) return; // saat mengirim, jangan ganti berkas
    try {
      final doc = await CvPicker.pickCv(); // buka file chooser asli
      if (!mounted || doc == null) return; // null = user batal
      key.currentState?.didChange(doc);
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal membuka berkas. Coba lagi.');
    }
  }

  // (5) EVENT: tombol "Kirim Lamaran" ditekan
  Future<void> _submit() async {
    FocusScope.of(context).unfocus(); // tutup keyboard

    // VALIDATION: periksa semua field di dalam Form
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _snack('Periksa kembali isian yang masih salah.');
      return;
    }
    final cv = _cv;
    if (cv == null) return; // sudah dijamin tidak null oleh validator CV

    // STATE: masuk ke loading
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final lamaran = await _repository.submit(
        job: widget.job,
        namaPelamar: _namaController.text.trim(),
        email: _emailController.text.trim(),
        noHp: _hpController.text.trim(),
        pesan: _pesanController.text.trim(),
        cv: cv,
        dokumenTambahan: _extraDoc,
        simulateError: _simulateError,
      );
      // setelah await, pastikan layar masih ada sebelum memakai context
      if (!mounted) return;

      // NAVIGATION/RESULT: tutup form sambil MENGEMBALIKAN objek Lamaran
      Navigator.pop(context, lamaran);
    } on LamaranException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message); // error yang dikenali
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buang isian lamaran?'),
        content: const Text('Lamaran belum dikirim. Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _onMenuSelected(String value) {
    if (value == 'error') {
      setState(() => _simulateError = !_simulateError);
      _snack(_simulateError
          ? 'Mode simulasi gagal kirim: AKTIF'
          : 'Mode simulasi gagal kirim: nonaktif');
    }
  }

  // ====================== BUILD ======================

  @override
  Widget build(BuildContext context) {
    // PopScope: cegah keluar tidak sengaja saat form sudah terisi
    return PopScope<Object?>(
      canPop: !_hasUnsavedInput && !_isSubmitting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _isSubmitting) return; // saat mengirim, Back diabaikan
        final shouldLeave = await _confirmDiscard();
        if (shouldLeave && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  // rebuild tiap ada perubahan agar canPop selalu terbaru
                  onChanged: () => setState(() {}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildJobCard(),
                      const SizedBox(height: 20),
                      _buildDataPribadiCard(),
                      const SizedBox(height: 20),
                      _buildCvCard(),
                      const SizedBox(height: 20),
                      _buildExtraCard(),
                      const SizedBox(height: 20),
                      _buildPesanCard(),
                      const SizedBox(height: 20),
                      _buildAgreement(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ---------- Top app bar ----------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: _ink),
        // maybePop -> menghormati PopScope (dialog "Buang isian?")
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text('Ajukan Lamaran', style: _jakarta(17, FontWeight.w600, _ink)),
      actions: [
        // khusus demo: hapus menu ini jika tidak diperlukan
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 20, color: _slate400),
          onSelected: _onMenuSelected,
          itemBuilder: (context) => [
            CheckedPopupMenuItem<String>(
              value: 'error',
              checked: _simulateError,
              child: const Text('Simulasikan gagal kirim'),
            ),
          ],
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: _border),
      ),
    );
  }

  // ---------- Bottom action bar ----------
  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) ...[
                ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  // null = tombol nonaktif selama loading
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    disabledBackgroundColor: _blue.withValues(alpha: 0.6),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSubmitting ? 'Mengirim...' : 'Kirim Lamaran',
                        style: _inter(15, FontWeight.w600, Colors.white),
                      ),
                      const SizedBox(width: 8),
                      _isSubmitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, size: 12, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Kartu & komponen umum ----------
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Judul kartu: ikon + judul (+ tanda * wajib) + keterangan di kanan.
  Widget _cardTitle(
    IconData icon,
    String title, {
    bool required = false,
    String? trailing,
    Widget? trailingWidget,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _blue),
        const SizedBox(width: 6),
        Text(title, style: _jakarta(14, FontWeight.w600, _ink)),
        if (required)
          Text(' *', style: _jakarta(14, FontWeight.w600, _red)),
        const Spacer(),
        if (trailing != null)
          Text(trailing, style: _jakarta(12, FontWeight.w600, _slate500)),
        if (trailingWidget != null) trailingWidget,
      ],
    );
  }

  Widget _pill(IconData icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: _inter(12, FontWeight.w500, fg, height: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Ringkasan lowongan (data yang DITERIMA dari Detail) ----------
  Widget _buildJobCard() {
    final job = widget.job;
    final initial = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';
    return _card(
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
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_blue, _indigo],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  initial,
                  style: _jakarta(18, FontWeight.w700, Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _jakarta(16, FontWeight.w700, _ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _inter(14, FontWeight.w500, _blue, height: 20),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: _slate400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            job.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _inter(12, FontWeight.w400, _slate500,
                                height: 16),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _divider)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(Icons.payments_outlined, job.salary, _blueBg, _blue),
                _pill(Icons.work_outline, job.type, _greenBg, _greenText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Input teks ----------
  InputDecoration _decoration({
    required String hint,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12.5),
    TextStyle? hintStyle,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: hintStyle ?? _inter(14, FontWeight.w400, _slate400),
      isDense: true,
      filled: true,
      fillColor: _pageBg,
      contentPadding: padding,
      border: border(_border),
      enabledBorder: border(_border),
      disabledBorder: border(_border),
      focusedBorder: border(_blue),
      errorBorder: border(_red),
      focusedErrorBorder: border(_red),
      errorStyle: _inter(11, FontWeight.w400, _red),
      counterStyle: _inter(11, FontWeight.w400, _slate500),
    );
  }

  Widget _labeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: _inter(12, FontWeight.w600, _ink, height: 16),
            children: [
              TextSpan(text: ' *', style: _inter(12, FontWeight.w600, _red)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: !_isSubmitting,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: capitalization,
          style: _inter(14, FontWeight.w400, _ink, height: 17),
          decoration: _decoration(hint: hint),
          validator: validator,
        ),
      ],
    );
  }

  // ---------- Section: Data Pribadi ----------
  Widget _buildDataPribadiCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _divider)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 14, color: _blue),
                const SizedBox(width: 6),
                Text('Data Pribadi', style: _jakarta(14, FontWeight.w600, _ink)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            label: 'Nama Lengkap',
            controller: _namaController,
            hint: 'Nama sesuai KTM',
            validator: LamaranValidators.nama,
            textInputAction: TextInputAction.next,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _labeledField(
            label: 'Email',
            controller: _emailController,
            hint: 'nama@student.unand.ac.id',
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _labeledField(
            label: 'Nomor Telepon / WhatsApp',
            controller: _hpController,
            hint: '+62 812-3456-7890',
            validator: LamaranValidators.noHp,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  // ---------- Section: Upload CV / Resume ----------
  Widget _buildCvCard() {
    return _card(
      child: FormField<CvDocument>(
        key: _cvKey,
        validator: LamaranValidators.cv,
        builder: (state) {
          final doc = state.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cardTitle(
                Icons.description,
                'Upload CV / Resume',
                required: true,
                trailingWidget: _pill(
                  Icons.lock_outline,
                  'Aman',
                  _greenBg,
                  _green,
                ),
              ),
              const SizedBox(height: 12),
              if (doc == null)
                _UploadBox(
                  title: 'Ketuk untuk memilih CV (PDF atau DOCX)',
                  subtitle: 'Maks. 5 MB',
                  hasError: state.hasError,
                  onTap: _isSubmitting
                      ? null
                      : () => _pickDoc(_cvKey, 'Pilih berkas CV'),
                )
              else
                _buildFileCard(
                  doc: doc,
                  valid: LamaranValidators.cv(doc) == null,
                  onReplace: () =>
                      _pickDoc(_cvKey, 'Pilih berkas CV'),
                  onDelete: () {
                    if (!_isSubmitting) state.didChange(null);
                  },
                ),
              if (state.hasError) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    state.errorText!,
                    style: _inter(11, FontWeight.w400, _red),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 12, color: _slate400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Format PDF atau DOCX, maksimal 5 MB',
                        style: _inter(11, FontWeight.w400, _slate500,
                            height: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Kartu "File Uploaded" (dipakai CV dan dokumen tambahan).
  Widget _buildFileCard({
    required CvDocument doc,
    required bool valid,
    required VoidCallback onReplace,
    required VoidCallback onDelete,
  }) {
    final isPdf = doc.extension == 'pdf';
    final iconBg = isPdf ? _redBg : _blueBg;
    final iconBorder = isPdf ? _redBorder : const Color(0xFFDBEAFE);
    final iconColor = isPdf ? _red : _blue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _pageBg,
        border: Border.all(color: valid ? _border : _red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              border: Border.all(color: iconBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _inter(12, FontWeight.w600, _ink, height: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      doc.sizeLabel,
                      style: _inter(11, FontWeight.w400, _slate500, height: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: _inter(11, FontWeight.w400, _slate500, height: 16),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        valid ? 'Terunggah' : 'Tidak valid',
                        overflow: TextOverflow.ellipsis,
                        style: _inter(
                          11,
                          FontWeight.w500,
                          valid ? _green : _red,
                          height: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          _SquareIconButton(
            icon: Icons.sync,
            color: _slate500,
            tooltip: 'Ganti berkas',
            onTap: _isSubmitting ? null : onReplace,
          ),
          const SizedBox(width: 4),
          _SquareIconButton(
            icon: Icons.delete_outline,
            color: _slate400,
            tooltip: 'Hapus berkas',
            onTap: _isSubmitting ? null : onDelete,
          ),
        ],
      ),
    );
  }

  // ---------- Section: Dokumen Tambahan (Opsional) ----------
  Widget _buildExtraCard() {
    return _card(
      child: FormField<CvDocument>(
        key: _extraKey,
        validator: LamaranValidators.dokumenTambahan,
        builder: (state) {
          final doc = state.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 15, color: _slate500),
                  const SizedBox(width: 6),
                  Text(
                    'Dokumen Tambahan',
                    style: _jakarta(14, FontWeight.w600, _ink),
                  ),
                  const Spacer(),
                  Text(
                    'Opsional',
                    style: _jakarta(12, FontWeight.w600, _slate500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (doc == null)
                _UploadBox(
                  title: 'Unggah portofolio atau sertifikat',
                  subtitle: 'Maks. 5 MB',
                  hasError: state.hasError,
                  onTap: _isSubmitting
                      ? null
                      : () => _pickDoc(
                            _extraKey,
                            'Pilih dokumen tambahan',
                          ),
                )
              else
                _buildFileCard(
                  doc: doc,
                  valid: LamaranValidators.dokumenTambahan(doc) == null,
                  onReplace: () => _pickDoc(
                    _extraKey,
                    'Pilih dokumen tambahan',
                  ),
                  onDelete: () {
                    if (!_isSubmitting) state.didChange(null);
                  },
                ),
              if (state.hasError) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    state.errorText!,
                    style: _inter(11, FontWeight.w400, _red),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ---------- Section: Pesan untuk Recruiter ----------
  Widget _buildPesanCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 15, color: _slate500),
              const SizedBox(width: 6),
              Text(
                'Pesan untuk Recruiter',
                style: _jakarta(14, FontWeight.w600, _ink),
              ),
              const Spacer(),
              Text(
                'Opsional',
                style: _jakarta(12, FontWeight.w600, _slate500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _pesanController,
            enabled: !_isSubmitting,
            minLines: 3,
            maxLines: 4,
            maxLength: _maxPesan,
            style: _inter(14, FontWeight.w400, _ink, height: 18),
            decoration: _decoration(
              hint:
                  'Tulis pesan singkat untuk memperkenalkan diri atau motivasi melamar...',
              padding: const EdgeInsets.all(12),
              hintStyle: _inter(12, FontWeight.w400, _slate400, height: 16),
            ),
            validator: LamaranValidators.pesan,
          ),
        ],
      ),
    );
  }

  // ---------- Syarat & ketentuan ----------
  Widget _buildAgreement() {
    return FormField<bool>(
      initialValue: false,
      validator: LamaranValidators.setuju,
      builder: (state) {
        final checked = state.value ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _isSubmitting ? null : () => state.didChange(!checked),
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: checked ? _blue : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: checked
                            ? null
                            : Border.all(
                                color: state.hasError ? _red : _slate300,
                                width: 1.5,
                              ),
                      ),
                      child: checked
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dengan mengirim lamaran, saya menyatakan bahwa data '
                        'yang saya isi adalah benar dan bersedia dihubungi '
                        'oleh recruiter terkait proses seleksi.',
                        style: _inter(11, FontWeight.w400, _slate500,
                            height: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 28),
                child: Text(
                  state.errorText!,
                  style: _inter(11, FontWeight.w400, _red),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ====================== Widget pendukung ======================

/// Kotak upload dengan garis putus-putus ("Compact Upload Box").
class _UploadBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool hasError;
  final VoidCallback? onTap;

  const _UploadBox({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: hasError ? _red : _slate300,
          radius: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _pageBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: _divider,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 16,
                  color: _slate500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: _inter(12, FontWeight.w600, _ink, height: 16),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: _inter(11, FontWeight.w400, _slate500, height: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Tombol ikon 32x32 dengan sudut membulat (Ganti / Hapus berkas).
class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _SquareIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}