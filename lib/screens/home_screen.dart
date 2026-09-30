import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JobConnect - Beranda'),
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          // 1. Loading State
          if (provider.state == HomeState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Error State
          if (provider.state == HomeState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchJobs(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // 3. Empty State
          if (provider.state == HomeState.empty || provider.jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_off_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada lowongan pekerjaan tersedia.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchJobs(),
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            );
          }

          // 4. Loaded State (Menampilkan daftar pekerjaan)
          return ListView.builder(
            itemCount: provider.jobs.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final JobModel job = provider.jobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    job.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${job.company} • ${job.location}\n${job.salary}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Poin g: Navigasi Home -> Detail
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: job,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}