import 'package:flutter/material.dart';
import '../data/dummy_jobs.dart';
import '../models/job_model.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

enum ViewStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ViewStatus _status = ViewStatus.loading;
  List<JobModel> _items = [];
  String _errorMessage = '';
  bool _simulateError = false; 

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _status = ViewStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (_simulateError) {
        throw Exception('Gagal memuat data. Periksa koneksi internet.');
      }

      if (!mounted) return;
      setState(() {
        _items = List.from(dummyJobs);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JobConnect - Home'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bug_report,
              color: _simulateError ? Colors.red : Colors.grey,
            ),
            tooltip: _simulateError ? 'Matikan Simulasi Error' : 'Aktifkan Simulasi Error',
            onPressed: () {
              setState(() {
                _simulateError = !_simulateError;
              });
              _loadItems();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(message: 'Belum ada data lowongan.');
    }

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.company} • ${item.location}\n${item.salary}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.detail,
              arguments: item,
            ),
          ),
        );
      },
    );
  }
}