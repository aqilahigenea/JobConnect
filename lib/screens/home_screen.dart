import 'package:flutter/material.dart';

import '../data/job_repository.dart';
import '../models/job.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

// (1) status tampilan
enum ViewStatus { loading, success, error }

/// Warna & gaya teks dari Figma (khusus halaman Home).
class _C {
  _C._();
  static const bg = Color(0xFFF9F9FF);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF111C2D);
  static const textSec = Color(0xFF434655);
  static const muted = Color(0xFF737686);
  static const primary = Color(0xFF004AC6);
  static const chip = Color(0xFFF0F3FF);
  static const tagBlue = Color(0xFFE7EEFF);
  static const teal = Color(0xFF006058);
  static const tealBg = Color(0x9989F5E7);
  static const red = Color(0xFFBA1A1A);
}

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

const _heading = TextStyle(
  fontFamily: 'Plus Jakarta Sans',
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: _C.text,
  height: 24 / 18,
);

const _cardShadow = [
  BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 20,
    spreadRadius: -2,
    offset: Offset(0, 4),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _filters = ['Semua', 'Magang', 'Paruh Waktu', 'Freelance'];

  // (2) variabel state
  final _repository = JobRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Job> _jobs = [];
  String _errorMessage = '';
  String _selectedFilter = 'Semua';
  final bool _simulateError = false; // ubah ke true untuk menguji error state

  // (3) ambil data saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  // (4) mengambil data + menangani error
  Future<void> _loadJobs() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final jobs = await _repository.fetchJobs(simulateError: _simulateError);
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  List<Job> get _filteredJobs {
    if (_selectedFilter == 'Semua') return _jobs;
    return _jobs.where((j) => j.type == _selectedFilter).toList();
  }

  // (7) kirim Job yang dipilih ke layar Detail
  void _openDetail(Job job) {
    Navigator.pushNamed(
      context,
      AppRoutes.detail,
      arguments: job,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearch(),
            _buildChips(),
            Expanded(child: _buildContent()), // (5)
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  // (6) memilih tampilan: loading / error / sukses
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(message: 'Memuat lowongan...'),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadJobs),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    final jobs = _filteredJobs;
    if (jobs.isEmpty) {
      return EmptyView(
        icon: Icons.work_off_outlined,
        message: _jobs.isEmpty
            ? 'Belum ada lowongan.'
            : 'Belum ada lowongan untuk kategori "$_selectedFilter".',
      );
    }
    final preferred = ([...jobs]..sort((a, b) => b.match.compareTo(a.match)))
        .take(3)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        // --- Sesuai Preferensi ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('Sesuai Preferensi', style: _heading),
                        SizedBox(width: 4),
                        Icon(Icons.auto_awesome, size: 16, color: _C.primary),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dipilih berdasarkan minat dan preferensi kariermu.',
                      style: _inter(12, FontWeight.w400, _C.textSec,
                          height: 16 / 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text('Lihat Semua',
                        style: _inter(12, FontWeight.w600, _C.primary)),
                    const Icon(Icons.chevron_right,
                        size: 16, color: _C.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            itemCount: preferred.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, i) => _PreferenceCard(
              job: preferred[i],
              onTap: () => _openDetail(preferred[i]),
            ),
          ),
        ),
        // --- Lowongan Terbaru ---
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lowongan Terbaru', style: _heading),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE8FF),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '${jobs.length} Lowongan Baru',
                  style: _inter(11, FontWeight.w500, _C.primary, spacing: 0.22),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final job in jobs) ...[
                _JobCard(job: job, onTap: () => _openDetail(job)),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.tagBlue,
                  border: Border.all(color: const Color(0xFF2563EB), width: 2),
                ),
                alignment: Alignment.center,
                child:
                    Text('A', style: _inter(18, FontWeight.w600, _C.primary)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6BD8CB),
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Halo, Aqila 👋', style: _heading),
                Text(
                  'Temukan peluang kariermu hari ini',
                  style: _inter(12, FontWeight.w400, _C.textSec,
                      height: 16 / 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _C.chip,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_none,
                    size: 22, color: _C.text),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _C.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text('3',
                      style: _inter(10, FontWeight.w700, Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                style: _inter(14, FontWeight.w400, _C.text),
                decoration: InputDecoration(
                  hintText: 'Cari lowongan kerja...',
                  hintStyle: _inter(14, FontWeight.w400, _C.muted),
                  prefixIcon:
                      const Icon(Icons.search, size: 18, color: _C.muted),
                  filled: true,
                  fillColor: _C.chip,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _C.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 4),
          itemBuilder: (context, i) {
            final label = _filters[i];
            final selected = label == _selectedFilter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = label),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _C.primary : _C.chip,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  label,
                  style: _inter(12, FontWeight.w500,
                      selected ? Colors.white : _C.textSec, spacing: 0.12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Ikon + warna kotak ikon berdasarkan jenis lowongan.
(IconData, Color, Color) _styleFor(Job job) {
  return switch (job.type) {
    'Magang' => (Icons.school_outlined, _C.primary, const Color(0xFFDBE1FF)),
    'Paruh Waktu' => (
        Icons.storefront_outlined,
        _C.teal,
        const Color(0x266BD8CB)
      ),
    _ => (Icons.laptop_mac, const Color(0xFF1D4ED8), const Color(0xFFDCE1FF)),
  };
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Tag(this.label, {required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: _inter(11, FontWeight.w600, fg, spacing: 0.22)),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final int match;
  const _MatchBadge(this.match);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _C.tealBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: _C.teal),
          const SizedBox(width: 4),
          Text('$match% Cocok',
              style: _inter(11, FontWeight.w600, _C.teal, spacing: 0.22)),
        ],
      ),
    );
  }
}

/// Kartu horizontal "Sesuai Preferensi".
class _PreferenceCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  const _PreferenceCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = _styleFor(job);
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 22, color: fg),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.company,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _inter(12, FontWeight.w600, _C.text,
                                  spacing: 0.12)),
                          Text(job.location,
                              style: _inter(11, FontWeight.w400, _C.textSec,
                                  height: 20 / 11)),
                        ],
                      ),
                    ),
                    _MatchBadge(job.match),
                  ],
                ),
                Text(job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _heading),
                Row(
                  children: [
                    _Tag(job.type, bg: _C.tagBlue, fg: _C.primary),
                    const SizedBox(width: 4),
                    _Tag(job.postedAgo, bg: _C.chip, fg: _C.textSec),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ESTIMASI GAJI',
                        style: _inter(10, FontWeight.w600, _C.muted,
                            spacing: 0.5)),
                    Text(job.salary,
                        style: _inter(12, FontWeight.w700, _C.text,
                            spacing: 0.12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu vertikal "Lowongan Terbaru".
class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  const _JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = _styleFor(job);
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 22, color: fg),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _heading),
                          Text(job.company,
                              style: _inter(12, FontWeight.w400, _C.textSec,
                                  height: 16 / 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.bookmark_border,
                        size: 20, color: _C.muted),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _Tag(job.type, bg: _C.tagBlue, fg: _C.primary),
                    _Tag(job.location, bg: _C.chip, fg: _C.textSec),
                    _Tag('${job.match}% Cocok', bg: _C.tealBg, fg: _C.teal),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: _C.muted),
                    const SizedBox(width: 4),
                    Text(job.location,
                        style: _inter(12, FontWeight.w400, _C.textSec)),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule, size: 13, color: _C.muted),
                    const SizedBox(width: 4),
                    Text(job.postedAgo,
                        style: _inter(12, FontWeight.w400, _C.textSec)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.salary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _inter(12, FontWeight.w700, _C.text,
                                  spacing: 0.12)),
                          Text('Estimasi gaji',
                              style: _inter(11, FontWeight.w400, _C.muted,
                                  height: 20 / 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _C.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Lihat Detail',
                          style: _inter(11, FontWeight.w600, Colors.white,
                              spacing: 0.22)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigasi bawah (tampilan saja; pindah tab bukan bagian latihan ini).
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  static const _items = [
    (Icons.home_filled, 'Beranda'),
    (Icons.explore_outlined, 'Jelajah'),
    (Icons.description_outlined, 'Lamaran'),
    (Icons.tune, 'Preferensi'),
    (Icons.person_outline, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xE6F9F9FF),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_items[i].$1,
                        size: 22, color: i == 0 ? _C.primary : _C.textSec),
                    const SizedBox(height: 2),
                    Text(
                      _items[i].$2,
                      style: _inter(11, FontWeight.w600,
                          i == 0 ? _C.primary : _C.textSec, spacing: 0.22),
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