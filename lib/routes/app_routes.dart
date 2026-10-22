import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';

// Kelas utama untuk mengelola semua rute/pindah halaman di aplikasi
class AppRoutes {
  // Nama-nama rute halaman (constants)
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';

  // Fungsi untuk menentukan halaman mana yang dibuka berdasarkan nama rutenya
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Menampilkan halaman Login
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      // Menampilkan halaman Beranda
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      // Menampilkan halaman Detail Lowongan
      case detail:
        final args = settings.arguments;
        // Memastikan data yang dikirim valid (bisa berupa Map atau JobModel)
        if (args is Map<String, dynamic> || args is JobModel) {
          return MaterialPageRoute<dynamic>(
            builder: (_) => const DetailScreen(),
            settings: settings,
          );
        }
        // Jika data tidak valid, tampilkan halaman 404 (Not Found)
        return MaterialPageRoute<void>(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );

      // Jika rute tidak terdaftar di switch, tampilkan halaman 404
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }

  // Fungsi cadangan jika terjadi error rute tidak dikenal dari main.dart
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const NotFoundScreen(),
      settings: settings,
    );
  }
}