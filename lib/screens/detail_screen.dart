import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../routes/app_routes.dart';

class DetailScreen extends StatefulWidget {
  final JobModel job;
  const DetailScreen({super.key, required this.job});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _catatan;

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    if (!mounted || hasil == null) return;

    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${job.company} • ${job.location}'),
          Text(job.salary, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(job.description),
          const Divider(height: 32),
          Text(
            _catatan == null ? 'Belum ada catatan.' : 'Catatan: $_catatan',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
          ),
        ],
      ),
    );
  }
}