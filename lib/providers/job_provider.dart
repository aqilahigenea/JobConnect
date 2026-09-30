import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../data/dummy_jobs.dart';

// Enums untuk menangani state sesuai poin e (Loading, Empty, Error)
enum HomeState { loading, empty, error, loaded }

class JobProvider extends ChangeNotifier {
List<JobModel> _jobs = [];
  HomeState _state = HomeState.loading;
  String _errorMessage = '';

  List<JobModel> get jobs => _jobs;
  HomeState get state => _state;
  String get errorMessage => _errorMessage;

  JobProvider() {
    fetchJobs();
  }

  // Fungsi simulasi mengambil data dari dummy
  Future<void> fetchJobs() async {
    _state = HomeState.loading;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulasi jeda loading

    try {
      // Ambil data dari dummy_jobs.dart
      _jobs = List.from(dummyJobs);

      if (_jobs.isEmpty) {
        _state = HomeState.empty;
      } else {
        _state = HomeState.loaded;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data pekerjaan: $e';
      _state = HomeState.error;
    }

    notifyListeners();
  }

  // Fungsi untuk menambah catatan/lamaran baru
  void addJob(JobModel job) {
    _jobs.add(job);
    _state = HomeState.loaded;
    notifyListeners();
  }
}