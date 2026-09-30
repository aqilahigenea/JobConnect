import 'package:flutter/material.dart';
import '../models/job_model.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _catatanPribadi;

  @override
  Widget build(BuildContext context) {
    // Menangkap data JobModel yang dikirim dari Home (Poin g)
    final job = ModalRoute.of(context)!.settings.arguments as JobModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${job.company} - ${job.location}', style: const TextStyle(fontSize: 16)),
            Text('Gaji: ${job.salary}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const Text('Deskripsi Pekerjaan:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(job.description),
            const SizedBox(height: 24),
            
            // Menampilkan catatan jika sudah diisi dari Form Catatan
            if (_catatanPribadi != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Catatan Kamu:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_catatanPribadi!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tombol ke Form Catatan (Poin h)
            ElevatedButton.icon(
              onPressed: () async {
                // Navigasi ke Form dan menunggu data balikan (Poin h)
                final result = await Navigator.pushNamed(context, '/form-catatan');
                if (result != null && result is String) {
                  setState(() {
                    _catatanPribadi = result; // Menerima data
                  });
                }
              },
              icon: const Icon(Icons.note_add),
              label: Text(_catatanPribadi == null ? 'Tambah Catatan' : 'Edit Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}