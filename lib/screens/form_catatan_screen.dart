import 'package:flutter/material.dart';

class FormCatatanScreen extends StatefulWidget {
  const FormCatatanScreen({super.key});

  @override
  State<FormCatatanScreen> createState() => _FormCatatanScreenState();
}

class _FormCatatanScreenState extends State<FormCatatanScreen> {
  final TextEditingController _catatanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan / Lamaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _catatanController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tuliskan catatan lamaran di sini...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Mengembalikan data catatan ke Halaman Detail (Poin h)
                Navigator.pop(context, _catatanController.text);
              },
              child: const Text('Simpan Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}