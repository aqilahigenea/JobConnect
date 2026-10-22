import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../utils/validators.dart';

// Halaman detail pekerjaan untuk menampilkan deskripsi & fitur catatan inline
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Key pengontrol validasi form catatan
  final _formKey = GlobalKey<FormState>();
  // Controller untuk membaca dan mengisi teks catatan
  final _catatanController = TextEditingController();
  
  bool _isEditing = false; // Flag untuk berpindah mode tampilan/edit form inline
  String? _catatanTersimpan; // Variabel penampung teks catatan tersimpan
  bool _isInitialized = false; // Flag penanda agar inisialisasi data hanya berjalan 1x

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Mengambil argumen data lowongan yang dikirim dari HomeScreen
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _catatanTersimpan = args['existingNote'];
      } else if (args is JobModel) {
        // Jika HomeScreen mengirim objek JobModel secara langsung
        _catatanTersimpan = null;
      }
      
      // Isi controller jika sudah ada catatan sebelumnya
      if (_catatanTersimpan != null && _catatanTersimpan!.isNotEmpty) {
        _catatanController.text = _catatanTersimpan!;
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    // Membersihkan controller dari memori saat halaman ditutup
    _catatanController.dispose();
    super.dispose();
  }

  // Fungsi memproses simpan catatan setelah input divalidasi
  void _simpanCatatan() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _catatanTersimpan = _catatanController.text.trim();
        _isEditing = false; // Tutup mode input form
      });

      // Umpan balik berupa SnackBar saat catatan berhasil disimpan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil disimpan!'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Fungsi mengembalikan data catatan dan ID lowongan ke HomeScreen saat tombol back ditekan
  void _kembaliKeHome(JobModel job) {
    Navigator.pop(context, {
      'jobId': job.id,
      'catatan': _catatanTersimpan ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    // Membaca argumen yang dikirim dari HomeScreen
    final args = ModalRoute.of(context)?.settings.arguments;
    JobModel? job;

    if (args is Map<String, dynamic>) {
      job = args['job'] as JobModel?;
    } else if (args is JobModel) {
      job = args;
    }

    // Tampilan penanganan jika data lowongan tidak ada
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Lowongan')),
        body: const Center(child: Text('Data lowongan tidak ditemukan.')),
      );
    }

    // PopScope mencegat event gesture back di HP agar tetap menjalankan _kembaliKeHome
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _kembaliKeHome(job!);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => _kembaliKeHome(job!), // Navigasi tombol back di AppBar
          ),
          title: Text(
            job.title ?? 'Detail Lowongan',
            style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rincian informasi pekerjaan
              Text(
                job.title ?? '',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),

              //diatas
              const SizedBox(height: 6),
              Text(
                '${job.company} • ${job.location}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Text(
                job.salary ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
              const SizedBox(height: 24),

              // Tampilan Box Catatan Tersimpan (Tampil jika sudah ada catatan & tidak sedang mode edit)
              if (_catatanTersimpan != null && _catatanTersimpan!.isNotEmpty && !_isEditing) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 229, 236, 8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color.fromARGB(255, 20, 21, 20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note, size: 18, color: Color(0xFFD97706)),
                          SizedBox(width: 6),
                          Text(
                            'Catatan Anda:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _catatanTersimpan!,
                        style: const TextStyle(color: Color(0xFF78350F), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Form Input Inline (Hanya tampil jika mode edit aktif)
              if (_isEditing) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tulis Catatan Lowongan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _catatanController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Masukkan catatan mengenai lowongan ini...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        // Validasi minimal 5 karakter dari validator.dart
                        validator: (value) => Validators.minLength(value, 10),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _simpanCatatan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Simpan Catatan', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _catatanController.text = _catatanTersimpan ?? '';
                              });
                            },
                            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tombol Pemicu untuk Membuka Form Tulis/Ubah Catatan Inline
              if (!_isEditing)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: Text(_catatanTersimpan == null || _catatanTersimpan!.isEmpty ? 'Tulis Catatan' : 'Ubah Catatan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}