import 'package:flutter/material.dart';

import '../models/job.dart';
import '../utils/validators.dart';

// Warna dari desain Figma
const _ink = Color(0xFF111C2D);
const _muted = Color(0xFF434655);
const _hint = Color(0xFF737686);
const _blue = Color(0xFF004AC6);
const _blueBtn = Color(0xFF2563EB);
const _teal = Color(0xFF006058);
const _tealLight = Color(0xFF89F5E7);
const _tile = Color(0xFFF0F3FF);
const _chip = Color(0xFFE7EEFF);
const _chipStrong = Color(0xFFDEE8FF);
const _red = Color(0xFFBA1A1A);

TextStyle _inter(double size, FontWeight w, Color c,
        {double? height, double? spacing}) =>
    TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: w,
      color: c,
      height: height,
      letterSpacing: spacing,
    );

TextStyle _jakarta(double size, Color c, {double? spacing}) => TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: c,
      letterSpacing: spacing,
    );

class CatatanFormScreen extends StatefulWidget {
  final Job job;
  const CatatanFormScreen({super.key, required this.job});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  static const _maxCatatan = 500;

  final _formKey = GlobalKey<FormState>();
  final _linkController =
      TextEditingController(text: 'https://behance.net/aqilarahmania');
  final _catatanController = TextEditingController();

  bool _cvTerlampir = true; // simulasi berkas CV

  @override
  void dispose() {
    _linkController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  bool get _linkValid =>
      _linkController.text.trim().isNotEmpty &&
      _validateLink(_linkController.text) == null;

  String? _validateLink(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null; // opsional
    final uri = Uri.tryParse(text);
    final ok = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
    return ok ? null : 'Tautan harus diawali http:// atau https://';
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (!_cvTerlampir) {
      _snack('Lampirkan CV terlebih dahulu');
      return;
    }
    // Tutup form sambil MEMBAWA teks catatan ke layar Detail
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            // ketuk area gelap = tutup form (tanpa mengirim apa pun)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: c.maxHeight * 0.92,
                  maxWidth: 560,
                ),
                child: _buildSheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheet() {
    return Material(
      color: Colors.white,
      elevation: 12,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E3FB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTips(),
                    const SizedBox(height: 16),
                    _buildProfile(),
                    const SizedBox(height: 16),
                    _buildUpload(),
                    const SizedBox(height: 16),
                    _buildPortfolio(),
                    const SizedBox(height: 16),
                    _buildCatatan(),
                    const SizedBox(height: 16),
                    _buildAgreement(),
                  ],
                ),
              ),
            ),
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text('Ajukan Lamaran',
                          overflow: TextOverflow.ellipsis,
                          style: _jakarta(20, _ink, spacing: -0.2)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _chipStrong,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('Lamaran Cepat',
                          style: _inter(11, FontWeight.w600, _blue,
                              spacing: 0.22)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.business_center_outlined,
                        size: 13, color: _blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.job.title} • ${widget.job.company}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _inter(12, FontWeight.w400, _muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration:
                  const BoxDecoration(color: _chip, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: _muted),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tips ----------
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _tile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration:
                const BoxDecoration(color: _blueBtn, shape: BoxShape.circle),
            child: const Icon(Icons.bolt, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tips: profil lengkap, CV terbaru, dan catatan singkat membuat lamaranmu lebih cepat dilirik perekrut.',
              style: _inter(12, FontWeight.w400, _muted, height: 16 / 12),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Profil pelamar ----------
  Widget _buildProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PROFIL PELAMAR',
                  style: _inter(12, FontWeight.w500, _muted, spacing: 0.6)),
              InkWell(
                onTap: () => _snack('Ubah profil'),
                child: Row(
                  children: [
                    Text('Ubah',
                        style: _inter(11, FontWeight.w600, _blue,
                            spacing: 0.22)),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, size: 11, color: _blue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD8E3FB),
                      shape: BoxShape.circle,
                    ),
                    child: Text('A', style: _jakarta(22, _blue)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: _teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Aqila Rahmania', style: _jakarta(18, _ink)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBE1FF),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text('Profil Lengkap',
                              style: _inter(
                                  11, FontWeight.w600, const Color(0xFF00174B),
                                  spacing: 0.22)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _profileLine(Icons.mail_outline,
                        'aqila.rahmania@student.unand.ac.id'),
                    const SizedBox(height: 2),
                    _profileLine(Icons.school_outlined, 'Universitas Andalas'),
                    const SizedBox(height: 2),
                    _profileLine(Icons.place_outlined, 'Padang'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: _hint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _inter(12, FontWeight.w400, _muted, height: 16 / 12)),
        ),
      ],
    );
  }

  // ---------- Upload berkas ----------
  Widget _buildUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Berkas CV & Portofolio',
                  style: _inter(14, FontWeight.w600, _ink, spacing: 0.14)),
            ),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    size: 12, color: _teal),
                const SizedBox(width: 2),
                Text('Wajib dilampirkan',
                    style: _inter(11, FontWeight.w600, _teal, spacing: 0.22)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_cvTerlampir) _buildFileCard(),
        if (_cvTerlampir) const SizedBox(height: 8),
        _buildDropZone(),
      ],
    );
  }

  Widget _buildFileCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _chipStrong,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined,
                size: 20, color: _blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text('CV_Aqila_Rahmania.pdf',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _inter(12, FontWeight.w600, _ink,
                              spacing: 0.12)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tealLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('Terunggah',
                          style: _inter(
                              11, FontWeight.w600, const Color(0xFF00201D),
                              spacing: 0.22)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('PDF • 1,2 MB • Diunggah 2 hari lalu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _inter(12, FontWeight.w400, _muted)),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Lihat berkas',
            onPressed: () => _snack('Pratinjau berkas'),
            icon:
                const Icon(Icons.visibility_outlined, size: 18, color: _muted),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Hapus berkas',
            onPressed: () => setState(() => _cvTerlampir = false),
            icon: const Icon(Icons.delete_outline, size: 18, color: _red),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Simulasi: belum memakai file picker
        setState(() => _cvTerlampir = true);
        _snack('Berkas dipilih (simulasi)');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _tile,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD8E3FB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload_outlined,
                  size: 20, color: _blue),
            ),
            const SizedBox(height: 4),
            Text('Tambah dokumen pendukung',
                textAlign: TextAlign.center,
                style: _inter(12, FontWeight.w500, _ink, spacing: 0.12)),
            Text('PDF atau DOCX, maksimal 5 MB',
                textAlign: TextAlign.center,
                style: _inter(12, FontWeight.w400, _muted)),
          ],
        ),
      ),
    );
  }

  // ---------- Tautan portofolio ----------
  Widget _buildPortfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tautan Portofolio',
                style: _inter(12, FontWeight.w500, _ink, spacing: 0.12)),
            Text('Opsional',
                style: _inter(12, FontWeight.w400, _muted, spacing: 0.12)),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _linkController,
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
          validator: _validateLink,
          style: _inter(14, FontWeight.w400, _ink, height: 20 / 14),
          decoration: InputDecoration(
            hintText: 'https://behance.net/namamu',
            hintStyle: _inter(14, FontWeight.w400, _hint),
            filled: true,
            fillColor: _tile,
            prefixIcon: const Icon(Icons.link, size: 18, color: _blue),
            suffixIcon: _linkValid
                ? const Icon(Icons.check_circle, size: 17, color: _teal)
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _blue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Catatan untuk perekrut ----------
  Widget _buildCatatan() {
    final length = _catatanController.text.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Catatan untuk Perekrut',
                style: _inter(14, FontWeight.w600, _ink, spacing: 0.14)),
            Text('Wajib', style: _inter(12, FontWeight.w400, _muted)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _tile,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _catatanController,
                maxLines: 4,
                minLines: 3,
                maxLength: _maxCatatan,
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    Validators.minLength(value, 5, fieldName: 'Catatan'),
                style: _inter(14, FontWeight.w400, _ink, height: 20 / 14),
                decoration: InputDecoration(
                  hintText:
                      'Ceritakan singkat kenapa kamu tertarik dan cocok untuk posisi ini...',
                  hintStyle:
                      _inter(14, FontWeight.w400, _hint, height: 20 / 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 12, color: _teal),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text('Sebutkan alasan melamar',
                              overflow: TextOverflow.ellipsis,
                              style: _inter(11, FontWeight.w600, _teal,
                                  spacing: 0.22)),
                        ),
                      ],
                    ),
                  ),
                  Text('$length/$_maxCatatan',
                      style: _inter(11, FontWeight.w600, _muted, spacing: 0.22)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Pernyataan ----------
  Widget _buildAgreement() {
    return FormField<bool>(
      initialValue: false,
      validator: (v) =>
          v == true ? null : 'Centang pernyataan ini untuk melanjutkan',
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => state.didChange(!(state.value ?? false)),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _tile,
                borderRadius: BorderRadius.circular(12),
                border: state.hasError ? Border.all(color: _red) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: state.value ?? false,
                      activeColor: _blue,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (v) => state.didChange(v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Saya menyatakan bahwa data yang saya kirim adalah benar dan bersedia dihubungi oleh perekrut terkait proses seleksi.',
                        style: _inter(12, FontWeight.w400, _ink,
                            height: 16 / 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text(state.errorText!,
                  style: _inter(12, FontWeight.w400, _red)),
            ),
        ],
      ),
    );
  }

  // ---------- Tombol kirim ----------
  Widget _buildActionBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _blueBtn,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send, size: 14),
                  iconAlignment: IconAlignment.end,
                  label: Text('Kirim Lamaran',
                      style: _inter(14, FontWeight.w600, Colors.white,
                          spacing: 0.14)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 11, color: _teal),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Datamu aman dan hanya dibagikan kepada perekrut yang bersangkutan.',
                      textAlign: TextAlign.center,
                      style: _inter(11, FontWeight.w600, _muted,
                          height: 14 / 11, spacing: 0.22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}