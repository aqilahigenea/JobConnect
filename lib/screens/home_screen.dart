import 'package:flutter/material.dart';
import '../data/dummy_jobs.dart';
import '../models/job_model.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

// Enum untuk menandai status tampilan (Loading, Sukses, atau Error)
enum ViewStatus { loading, success, error }

// Halaman utama Beranda aplikasi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Status awal tampilan dan variabel penampung data
  ViewStatus _status = ViewStatus.loading;
  List<JobModel> _items = [];
  String _errorMessage = '';
  bool _simulateError = false; // Flag untuk simulasi tombol error
  String _selectedCategory = 'Semua';
  String _userEmail = '';

  // Map untuk menyimpan catatan berdasarkan ID lowongan {jobId: catatan}
  final Map<String, String> _jobNotes = {};

  // Daftar kategori filter pekerjaan
  final List<String> _categories = [
    'Semua',
    'Part-time',
    'Magang',
    'Freelance',
    'IT',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems(); // Memuat data saat pertama kali halaman dibuka
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Menangkap data email yang dikirim dari LoginScreen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String && args.isNotEmpty) {
      _userEmail = args;
    }
  }

  // Fungsi membuat nama sapaan (Fallback ke 'Yang disana' jika email kosong)
  String _getDisplayName() {
    if (_userEmail.isEmpty) return 'Yang disana';
    final username = _userEmail.split('@').first;
    if (username.isEmpty) return 'Yang disana';
    return username[0].toUpperCase() + username.substring(1);
  }

  // Fungsi simulasi pengambilan data lowongan kerja dari file dummy
  Future<void> _loadItems() async {
    setState(() => _status = ViewStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Delay simulasi loading

      if (_simulateError) {
        throw Exception('Gagal memuat data. Periksa koneksi internet.');
      }

      if (!mounted) return;
      setState(() {
        _items = List<JobModel>.from(dummyJobs ?? []);
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

  // Fungsi navigasi ke detail & sinkronisasi catatan kembali dari DetailScreen
  Future<void> _navigateToDetail(JobModel item) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.detail,
      arguments: {
        'job': item,
        'existingNote': _jobNotes[item.id] ?? '', // Mengirimkan catatan yang tersimpan di Home
      },
    );

    // Menerima data kembalian (catatan baru) dari DetailScreen
    if (result != null && result is Map<String, dynamic> && mounted) {
      final String? jobId = result['jobId'];
      final String? catatan = result['catatan'];

      if (jobId != null) {
        setState(() {
          if (catatan != null && catatan.isNotEmpty) {
            _jobNotes[jobId] = catatan; // Simpan/perbarui catatan pada ID lowongan
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.work_rounded, color: Color(0xFF2563EB), size: 28),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JobConnect',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Beranda',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Tombol simulasi status error untuk pengujian
          IconButton(
            icon: Icon(
              Icons.bug_report,
              color: _simulateError ? Colors.red : Colors.grey,
            ),
            tooltip: _simulateError ? 'Matikan Error' : 'Aktifkan Error',
            onPressed: () {
              setState(() {
                _simulateError = !_simulateError;
              });
              _loadItems();
            },
          ),
          // Tombol Logout kembali ke halaman Login
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF64748B)),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ],
      ),
      body: _buildContent(), // Memanggil tampilan berdasarkan status
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline_rounded), label: 'Lowongan'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Lamaran'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  // Switcher tampilan berdasarkan kondisi status (Loading / Error / Sukses)
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildList(),
    };
  }

  // Widget utama yang menampilkan daftar konten lowongan kerja
  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(message: 'Belum ada data lowongan.');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profil & Sapaan Pengguna
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF2563EB),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${_getDisplayName()}! 👋',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      _userEmail.isNotEmpty ? _userEmail : 'Mahasiswa Sistem Informasi • UI',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF334155)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Kolom Input Pencarian Lowongan
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari lowongan kerja...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal List pilihan Kategori (Filter Chip)
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Sub-header Jumlah Lowongan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lowongan Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_items.length} Lowongan',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List untuk Menampilkan Semua Kartu Lowongan Pekerjaan
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final hasNote = _jobNotes.containsKey(item.id);

              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _navigateToDetail(item), // Klik untuk buka detail
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.work_outline,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title ?? 'Tanpa Judul',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    item.company ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.bookmark_border,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: [
                            _buildTag('Magang', const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                            _buildTag('Desain & Media', const Color(0xFFF1F5F9), const Color(0xFF475569)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              item.location ?? '',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.salary ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _navigateToDetail(item),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Lamar Cepat',
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        // Menampilkan Catatan di Bawah Kartu Lowongan jika tersimpan di Home
                        if (hasNote) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFCD34D)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.note_alt_outlined, size: 16, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Catatan: ${_jobNotes[item.id]}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF78350F),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat tag/badge visual
  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textColor),
      ),
    );
  }
}