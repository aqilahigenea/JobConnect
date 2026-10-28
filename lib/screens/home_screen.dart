import 'dart:async';
import 'package:flutter/material.dart';

import '../data/job_repository.dart';
import '../data/lowongan_dilihat_repository.dart';
import '../data/notifikasi_repository.dart';
import '../data/user_session.dart';
import '../models/job.dart';
import '../models/notifikasi.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

// (1) Status tampilan
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

  // Variabel state
  final _repository = JobRepository();
  final _searchController = TextEditingController();
  ViewStatus _status = ViewStatus.loading;
  List<Job> _jobs = [];
  String _errorMessage = '';
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final bool _simulateError = false;
  StreamSubscription<NotifikasiItem>? _notifSub;
  NotifikasiItem? _activeBannerNotif;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _notifSub = NotifikasiRepository().onNotifikasiBaru.listen((notif) {
      if (!mounted) return;
      setState(() {
        _activeBannerNotif = notif;
      });
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && _activeBannerNotif?.id == notif.id) {
          setState(() {
            _activeBannerNotif = null;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Mengambil data + menangani error
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

      // FR-05: Evaluasi pengingat batas akhir untuk lowongan yang pernah dilihat pengguna
      NotifikasiRepository().periksaPengingatBatasAkhir(
        userId: UserSession().currentUserId,
        semuaLowongan: jobs,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  List<Job> get _filteredJobs {
    return _repository.filterJobs(
      source: _jobs,
      query: _searchQuery,
      typeFilter: _selectedFilter,
    );
  }

  void _openDetail(Job job) {
    Navigator.pushNamed(
      context,
      AppRoutes.detail,
      arguments: job,
    );
  }

  void _openProfile() {
    Navigator.pushNamed(context, AppRoutes.profil);
  }

  /// FR-05: Mengetuk notifikasi membuka halaman detail lowongan tersebut.
  void _openNotifikasiTarget(NotifikasiItem notif) {
    NotifikasiRepository().tandaiDibaca(notif.id);
    if (_activeBannerNotif?.id == notif.id) {
      setState(() => _activeBannerNotif = null);
    }

    if (notif.jenis == JenisNotifikasi.pengingatBatasAkhir) {
      final job = _repository.findById(notif.idTujuan);
      if (job != null) {
        _openDetail(job);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_activeBannerNotif != null) _buildInAppNotificationBanner(),
            _buildSearch(),
            _buildChips(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        onProfileTap: _openProfile,
      ),
    );
  }

  // Memilih tampilan: loading / error / sukses
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(message: 'Memuat lowongan...'),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadJobs),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    final jobs = _filteredJobs;
    final isSearching = _searchQuery.trim().isNotEmpty;

    if (jobs.isEmpty) {
      if (isSearching) {
        return RefreshIndicator(
          onRefresh: _loadJobs,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: _C.chip,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_off_rounded,
                          size: 32, color: _C.muted),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada lowongan ditemukan',
                      style: _heading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tidak ada hasil yang cocok dengan "$_searchQuery"${_selectedFilter != 'Semua' ? ' pada filter $_selectedFilter' : ''}.\nCoba gunakan kata kunci atau filter lain.',
                      style: _inter(12, FontWeight.w400, _C.textSec,
                          height: 16 / 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = 'Semua';
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16, color: _C.primary),
                      label: Text('Reset Pencarian',
                          style: _inter(12, FontWeight.w600, _C.primary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _loadJobs,
        child: ListView(
          children: [
            SizedBox(
              height: 320,
              child: EmptyView(
                icon: Icons.work_off_outlined,
                message: _jobs.isEmpty
                    ? 'Belum ada lowongan.'
                    : 'Belum ada lowongan untuk kategori "$_selectedFilter".',
              ),
            ),
          ],
        ),
      );
    }

    if (isSearching) {
      return RefreshIndicator(
        onRefresh: _loadJobs,
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hasil Telusuri', style: _heading),
                        const SizedBox(height: 2),
                        Text(
                          'Hasil untuk "$_searchQuery"${_selectedFilter != 'Semua' ? ' ($_selectedFilter)' : ''}',
                          style: _inter(12, FontWeight.w400, _C.textSec,
                              height: 16 / 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEE8FF),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '${jobs.length} Ditemukan',
                      style:
                          _inter(11, FontWeight.w500, _C.primary, spacing: 0.22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
        ),
      );
    }

    final preferred = ([...jobs]..sort((a, b) => b.match.compareTo(a.match)))
        .take(3)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView(
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
                  onPressed: () => setState(() => _selectedFilter = 'Semua'),
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
            height: 210,
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
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: _openProfile,
            borderRadius: BorderRadius.circular(24),
            child: Stack(
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
                  child: Text(
                    UserSession().displayInitial,
                    style: _inter(18, FontWeight.w600, _C.primary),
                  ),
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
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _openProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo, ${UserSession().displayName} 👋',
                      style: _heading),
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
          ),
          ValueListenableBuilder<List<NotifikasiItem>>(
            valueListenable: NotifikasiRepository().notifikasiNotifier,
            builder: (context, _, __) {
              final unreadCount = NotifikasiRepository()
                  .getUnreadCount(UserSession().currentUserId);
              return InkWell(
                onTap: () => _showNotificationSheet(context),
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: unreadCount > 0
                            ? const Color(0xFFDEE8FF)
                            : _C.chip,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        unreadCount > 0
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        size: 22,
                        color: unreadCount > 0 ? _C.primary : _C.text,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          constraints: const BoxConstraints(
                              minWidth: 18, minHeight: 18),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _C.red,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: _C.surface, width: 2),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: _inter(10, FontWeight.w700, Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget In-App Notification Banner (FR-05)
  Widget _buildInAppNotificationBanner() {
    final notif = _activeBannerNotif;
    if (notif == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FDD6B20),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.alarm,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => _openNotifikasiTarget(notif),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.judul,
                          style: _inter(
                              13, FontWeight.w700, const Color(0xFFC05621)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDD6B20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '< 24 Jam',
                          style: _inter(9, FontWeight.w700, Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.pesan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        _inter(11, FontWeight.w400, const Color(0xFF7B341E)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Ketuk untuk melihat detail lowongan →',
                        style: _inter(11, FontWeight.w600, _C.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _activeBannerNotif = null),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: Color(0xFF9C4221)),
            ),
          ),
        ],
      ),
    );
  }

  // Modal Notification Center (FR-05, FR-10, FR-15)
  void _showNotificationSheet(BuildContext context) {
    final userId = UserSession().currentUserId;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final notifs = NotifikasiRepository().getNotifikasi(userId);
            final unread = NotifikasiRepository().getUnreadCount(userId);

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _C.chip,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Notifikasi', style: _heading),
                            if (unread > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _C.red,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '$unread Baru',
                                  style: _inter(
                                      10, FontWeight.w700, Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (notifs.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              NotifikasiRepository().tandaiSemuaDibaca(userId);
                              setSheetState(() {});
                              setState(() {});
                            },
                            child: Text(
                              'Tandai dibaca',
                              style: _inter(12, FontWeight.w600, _C.primary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: _C.chip),

                  // Daftar notifikasi
                  Expanded(
                    child: notifs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: const BoxDecoration(
                                      color: _C.chip,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none_outlined,
                                      size: 32,
                                      color: _C.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum Ada Notifikasi',
                                    style: _heading,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Notifikasi pengingat batas akhir lowongan (FR-05) dan pembaruan akan muncul di sini.',
                                    textAlign: TextAlign.center,
                                    style:
                                        _inter(12, FontWeight.w400, _C.textSec),
                                  ),
                                  const SizedBox(height: 20),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Simulasi pengingat batas akhir FR-05
                                      final sampleJob = _jobs.isNotEmpty
                                          ? _jobs.firstWhere(
                                              (j) => j.id == '4',
                                              orElse: () => _jobs.first,
                                            )
                                          : null;
                                      if (sampleJob != null) {
                                        NotifikasiRepository()
                                            .simulasiPengingatBatasAkhir(
                                          userId: userId,
                                          job: sampleJob,
                                          sisaJam: 18,
                                        );
                                        setSheetState(() {});
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.flash_on, size: 16),
                                    label: const Text(
                                        'Simulasi Pengingat (FR-05)'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            itemCount: notifs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final item = notifs[i];
                              return _buildNotificationCard(item, () {
                                Navigator.pop(ctx);
                                _openNotifikasiTarget(item);
                              });
                            },
                          ),
                  ),

                  // Bottom action bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    decoration: const BoxDecoration(
                      color: _C.chip,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: _C.muted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'FR-05: Mengetuk notifikasi langsung membuka halaman detail lowongan.',
                            style: _inter(11, FontWeight.w400, _C.textSec),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(NotifikasiItem item, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: item.isRead ? _C.surface : const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead ? _C.chip : const Color(0xFFBFDBFE),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.jenis == JenisNotifikasi.pengingatBatasAkhir
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.jenis == JenisNotifikasi.pengingatBatasAkhir
                        ? Icons.alarm
                        : Icons.work_outline,
                    color: item.jenis == JenisNotifikasi.pengingatBatasAkhir
                        ? const Color(0xFFE65100)
                        : _C.primary,
                    size: 20,
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
                              item.judul,
                              style: _inter(
                                13,
                                item.isRead ? FontWeight.w600 : FontWeight.w700,
                                _C.text,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: _C.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.pesan,
                        style: _inter(12, FontWeight.w400, _C.textSec),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Buka detail lowongan →',
                            style: _inter(11, FontWeight.w600, _C.primary),
                          ),
                          Text(
                            '${item.waktu.hour.toString().padLeft(2, '0')}:${item.waktu.minute.toString().padLeft(2, '0')}',
                            style: _inter(10, FontWeight.w400, _C.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Search Bar (FR-01: Fitur Telusuri Lowongan)
  Widget _buildSearch() {
    final hasQuery = _searchQuery.isNotEmpty;
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          textInputAction: TextInputAction.search,
          style: _inter(14, FontWeight.w400, _C.text),
          decoration: InputDecoration(
            hintText: 'Cari lowongan kerja...',
            hintStyle: _inter(14, FontWeight.w400, _C.muted),
            prefixIcon:
                const Icon(Icons.search, size: 20, color: _C.muted),
            suffixIcon: hasQuery
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: _C.muted),
                    tooltip: 'Hapus pencarian',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: _C.chip,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              borderSide: const BorderSide(color: _C.primary, width: 1.5),
            ),
          ),
        ),
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
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _Tag(job.type, bg: _C.tagBlue, fg: _C.primary),
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

/// Navigasi bawah (3 menu).
class _BottomNav extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const _BottomNav({
    this.onProfileTap,
  });

  static const _items = [
    (Icons.home_filled, 'Beranda'),
    (Icons.description_outlined, 'Lamaran'),
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
                InkWell(
                  onTap: () {
                    switch (i) {
                      case 1:
                        Navigator.pushNamed(context, AppRoutes.lamaranList);
                      case 2:
                        onProfileTap?.call();
                      default:
                        break;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_items[i].$1,
                            size: 22,
                            color: i == 0 ? _C.primary : _C.textSec),
                        const SizedBox(height: 2),
                        Text(
                          _items[i].$2,
                          style: _inter(11, FontWeight.w600,
                              i == 0 ? _C.primary : _C.textSec,
                              spacing: 0.22),
                        ),
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
}