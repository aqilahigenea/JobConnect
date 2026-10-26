import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/lamaran_repository.dart';
import '../models/lamaran.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';

/// FR-07 (Read): daftar semua lamaran beserta statusnya.
/// Alur: buka layar -> loading -> tampil daftar / kosong / error.
class LamaranListScreen extends StatefulWidget {
  const LamaranListScreen({super.key});

  @override
  State<LamaranListScreen> createState() => _LamaranListScreenState();
}

class _LamaranListScreenState extends State<LamaranListScreen> {
  final _repository = LamaranRepository();

  // ---------- STATE ----------
  bool _isLoading = true; // sedang mengambil data?
  String? _errorMessage; // null = tidak ada error
  List<Lamaran> _lamaranList = []; // data hasil fetch
  bool _simulateError = false; // khusus demo: paksa gagal memuat

  @override
  void initState() {
    super.initState();
    _muat(); // begitu layar dibuka, langsung ambil data
  }

  /// Ambil data dari repository, lalu ubah state sesuai hasilnya.
  Future<void> _muat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final hasil = await _repository.fetchAll(simulateError: _simulateError);
      if (!mounted) return; // layar sudah ditutup user
      setState(() => _lamaranList = hasil);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false); // loading selalu berhenti
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// KIRIM objek Lamaran ke layar detail, lalu TUNGGU hasil yang dikembalikan.
  /// Hasil berupa String? : null = tidak ada perubahan,
  /// teks = ada perubahan (diedit/ditarik) -> muat ulang daftar + tampilkan pesan.
  Future<void> _bukaDetail(Lamaran lamaran) async {
    final pesan = await Navigator.pushNamed<String>(
      context,
      AppRoutes.lamaranDetail,
      arguments: lamaran,
    );
    if (!mounted || pesan == null) return;
    await _muat();
    if (!mounted) return;
    _snack(pesan);
  }

  void _onMenuSelected(String value) {
    if (value == 'error') {
      setState(() => _simulateError = !_simulateError);
      _snack(_simulateError
          ? 'Mode simulasi gagal memuat: AKTIF'
          : 'Mode simulasi gagal memuat: nonaktif');
    } else if (value == 'muat') {
      _muat();
    }
  }

  // ====================== BUILD ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Lamaran Saya',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'muat', child: Text('Muat ulang')),
              PopupMenuItem(
                value: 'error',
                child: Text(_simulateError
                    ? 'Matikan simulasi gagal memuat'
                    : 'Simulasi gagal memuat'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// UI mengikuti state: loading -> error -> kosong -> daftar.
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: 'Memuat lamaran...');
    }
    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _muat);
    }
    if (_lamaranList.isEmpty) {
      return Column(
        children: [
          const Expanded(
            child: EmptyView(
              message:
                  'Belum ada lamaran.\nCari lowongan dan ajukan lamaran pertamamu!',
              icon: Icons.description_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cari Lowongan'),
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _lamaranList.length + 1, // +1 untuk teks jumlah di atas
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${_lamaranList.length} lamaran',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        final lamaran = _lamaranList[index - 1];
        return _LamaranCard(
          lamaran: lamaran,
          onTap: () => _bukaDetail(lamaran),
        );
      },
    );
  }
}

/// Satu kartu lamaran di daftar.
class _LamaranCard extends StatelessWidget {
  final Lamaran lamaran;
  final VoidCallback onTap;

  const _LamaranCard({required this.lamaran, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 0.5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // baris atas: judul + status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      lamaran.jobTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: lamaran.status),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                lamaran.company,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // baris info: jenis + lokasi
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _InfoChip(icon: Icons.work_outline, text: lamaran.jobType),
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    text: lamaran.jobLocation,
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.divider),
              // baris bawah: tanggal + panah
              Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Dikirim ${lamaran.tanggalLabel}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      size: 20, color: AppColors.textHint),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}