import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../models/job.dart';

// Warna dari desain Figma
const _bg = Color(0xFFF9F9FF);
const _ink = Color(0xFF111C2D);
const _muted = Color(0xFF434655);
const _blue = Color(0xFF004AC6);
const _blueDark = Color(0xFF1D4ED8);
const _teal = Color(0xFF006058);
const _tealLight = Color(0xFF89F5E7);
const _tile = Color(0xFFF0F3FF);
const _chip = Color(0xFFE7EEFF);

class DetailScreen extends StatefulWidget {
  final Job item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Job get item => widget.item;

  // Penyimpanan sementara di memori: id lowongan -> catatan
  static final Map<String, String> _tersimpan = {};

  String? _catatan;

  @override
  void initState() {
    super.initState();
    // Ambil catatan yang pernah disimpan untuk lowongan ini
    _catatan = _tersimpan[widget.item.id];
  }

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
      arguments: item,
    );
    if (!mounted || hasil == null) return; // null = pengguna batal
    _tersimpan[item.id] = hasil;
    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lamaran dan catatan berhasil disimpan')),
    );
  }
  
  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // Bagian catatan yang tampil di halaman Detail
  Widget _buildCatatan() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, size: 20, color: _blue),
              SizedBox(width: 8),
              _SectionTitle('Catatan Saya'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _catatan ?? 'Belum ada catatan.',
            style: const TextStyle(fontSize: 14, height: 1.5, color: _muted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _bukaFormCatatan,
              icon: const Icon(Icons.edit_note),
              label: const Text('Tulis Catatan'),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        foregroundColor: _ink,
        title: const Text(
          'Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'Simpan lowongan',
            onPressed: () => _snack(context, 'Lowongan disimpan'),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Bagikan',
            onPressed: () => _snack(context, 'Bagikan lowongan'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildHero(),
          const SizedBox(height: 16),
          if (item.benefits.isNotEmpty) ...[
            _buildBenefits(),
            const SizedBox(height: 16),
          ],
          _buildDescription(),
          const SizedBox(height: 16),
          if (item.requirements.isNotEmpty) ...[
            _buildRequirements(),
            const SizedBox(height: 16),
          ],
          _buildLocation(context),
          const SizedBox(height: 16),
          _buildLocation(context),
          const SizedBox(height: 16),
          _buildCatatan(),
          const SizedBox(height: 16),
          _buildContact(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ---------- Hero ----------
  Widget _buildHero() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _tile,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.company.isNotEmpty ? item.company[0] : '?',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _blue,
                      ),
                    ),
                  ),
                  if (item.isVerified)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: _teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 11, color: Colors.white),
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
                        Text(
                          item.company,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                        if (item.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _tealLight,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified,
                                    size: 11, color: Color(0xFF00201D)),
                                SizedBox(width: 4),
                                Text(
                                  'Terverifikasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00201D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 13, color: _muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: _muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.team,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _blueDark,
            ),
          ),
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < item.tags.length; i++)
                  _TagChip(label: item.tags[i], highlight: i == 0),
              ],
            ),
          ],
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.55,
            children: [
              _MetaTile(
                icon: Icons.payments_outlined,
                iconColor: _blue,
                label: 'Uang Saku',
                value: item.allowance,
                valueColor: _teal,
              ),
              _MetaTile(
                icon: Icons.schedule,
                iconColor: _blueDark,
                label: 'Durasi',
                value: item.duration,
              ),
              _MetaTile(
                icon: Icons.work_outline,
                iconColor: _muted,
                label: 'Tipe Kerja',
                value: item.workType,
              ),
              _MetaTile(
                icon: Icons.event_outlined,
                iconColor: _muted,
                label: 'Batas Lamar',
                value: item.deadline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Kompensasi & Manfaat ----------
  Widget _buildBenefits() {
    const colors = [_teal, _blue, _blueDark, Color(0xFF007B71)];
    const icons = [
      Icons.account_balance_wallet_outlined,
      Icons.school_outlined,
      Icons.workspace_premium_outlined,
      Icons.trending_up,
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard, size: 18, color: _teal),
              const SizedBox(width: 8),
              const Expanded(child: _SectionTitle('Kompensasi & Manfaat')),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Dibayar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < item.benefits.length; i++) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _tile,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icons[i % icons.length],
                      size: 18, color: colors[i % colors.length]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.benefits[i].title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.benefits[i].description,
                          style: const TextStyle(fontSize: 12, color: _muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i != item.benefits.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // ---------- Deskripsi Pekerjaan ----------
  Widget _buildDescription() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, size: 18, color: _blue),
              SizedBox(width: 8),
              _SectionTitle('Deskripsi Pekerjaan'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: const TextStyle(fontSize: 14, height: 1.6, color: _muted),
          ),
          if (item.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (var i = 0; i < item.responsibilities.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: _chip,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.responsibilities[i],
                        style: const TextStyle(
                            fontSize: 14, height: 1.4, color: _ink),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ---------- Persyaratan ----------
  Widget _buildRequirements() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 18, color: _blue),
              SizedBox(width: 8),
              _SectionTitle('Persyaratan Kualifikasi'),
            ],
          ),
          const SizedBox(height: 12),
          for (final req in item.requirements)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle, size: 17, color: _teal),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      req,
                      style: const TextStyle(
                          fontSize: 14, height: 1.4, color: _ink),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Lokasi ----------
  Widget _buildLocation(BuildContext context) {
    return _Card(
      border: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: _blue),
              const SizedBox(width: 8),
              const Expanded(child: _SectionTitle('Lokasi Tempat Kerja')),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _chip,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: _blue.withValues(alpha: 0.1)),
                ),
                child: Text(
                  item.workType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _tile,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4DC3C6D7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.apartment,
                          size: 14, color: _blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.locationName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    item.address,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Pratinjau peta (placeholder, tanpa gambar eksternal)
          Container(
            height: 144,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x66C3C6D7)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDCE6FB), Color(0xFFEAF1FF)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.location_on,
                      size: 16, color: Colors.white),
                ),
                Positioned(
                  left: 9,
                  bottom: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _bg.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text(
                          'Lokasi kantor',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () => _snack(context, 'Buka di Google Maps'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                backgroundColor: _blue.withValues(alpha: 0.05),
                side: BorderSide(color: _blue.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.map_outlined, size: 14),
              label: const Text(
                'Buka di Google Maps',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kontak ----------
  Widget _buildContact() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent, size: 18, color: _blue),
              SizedBox(width: 8),
              _SectionTitle('Kontak & Narahubung'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _tile,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFD8E3FB),
                  child: Icon(Icons.person, color: _blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.contactName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.contactEmail,
                        style:
                            const TextStyle(fontSize: 12, color: _blueDark),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.mail_outline, size: 17, color: _muted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 4),
              const Icon(Icons.phone_outlined, size: 13, color: _teal),
              const SizedBox(width: 8),
              Text(
                item.contactPhone,
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Bottom bar ----------
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg.withValues(alpha: 0.95),
        boxShadow: const [
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Material(
                color: _chip,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _snack(context, 'Tanya recruiter'),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.chat_bubble_outline,
                        size: 18, color: _ink),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => _snack(context, 'Lamaran dikirim'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.send, size: 14),
                    iconAlignment: IconAlignment.end,
                    label: const Text(
                      'Lamar Sekarang',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Widget kecil pendukung =================

class _Card extends StatelessWidget {
  final Widget child;
  final bool border;
  const _Card({required this.child, this.border = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: border ? Border.all(color: const Color(0xFFE2E8F0)) : null,
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
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool highlight;
  const _TagChip({required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _chip,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.22,
          color: highlight ? _blue : _muted,
        ),
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _MetaTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor = _ink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _tile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _chip,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}