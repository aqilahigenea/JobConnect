import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/lamaran.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/lamaran_detail_screen.dart';
import '../screens/lamaran_edit_screen.dart';
import '../screens/lamaran_form_screen.dart';
import '../screens/lamaran_list_screen.dart';
import '../screens/lamaran_sukses_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';
  static const String lamaranForm = '/lamaran-form'; // FR-06
  static const String lamaranSukses = '/lamaran-sukses'; // FR-06 (feedback)
  static const String lamaranList = '/lamaran-list'; // FR-07
  static const String lamaranDetail = '/lamaran-detail'; // FR-07
  static const String lamaranEdit = '/lamaran-edit'; // FR-08

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case detail:
        final args = settings.arguments;
        if (args is Job) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        return null; // data salah/kosong -> halaman 404
      case catatanForm:
        final formArgs = settings.arguments;
        if (formArgs is Job) {
          return PageRouteBuilder<String>(
            settings: settings,
            opaque: false,
            barrierDismissible: true,
            barrierLabel: 'Tutup',
            barrierColor: const Color(0x80263143),
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) =>
                CatatanFormScreen(job: formArgs),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        }
        return null; // data salah/kosong -> halaman 404
      case lamaranForm:
        // Argument WAJIB berupa Job -> cek tipenya dulu
        final lamaranArgs = settings.arguments;
        if (lamaranArgs is Job) {
          // <Lamaran> = tipe data yang akan DIKEMBALIKAN screen ini saat pop
          return MaterialPageRoute<Lamaran>(
            builder: (_) => LamaranFormScreen(job: lamaranArgs),
            settings: settings,
          );
        }
        // Tipe error route disamakan (<Lamaran>) agar tidak terjadi type error
        return _errorRoute<Lamaran>(
          settings,
          'Data lowongan tidak dikirim ke form lamaran.',
        );
      case lamaranSukses:
        // Argument WAJIB berupa Lamaran -> cek tipenya dulu
        final suksesArgs = settings.arguments;
        if (suksesArgs is Lamaran) {
          // <bool> = true jika pengguna menekan "Lihat Status Lamaran"
          return MaterialPageRoute<bool>(
            builder: (_) => LamaranSuksesScreen(lamaran: suksesArgs),
            settings: settings,
          );
        }
        return null; // data salah/kosong -> halaman 404
      case lamaranList:
        return MaterialPageRoute<void>(
          builder: (_) => const LamaranListScreen(),
          settings: settings,
        );
      case lamaranDetail:
        // Argument WAJIB berupa Lamaran -> cek tipenya dulu
        final detailArgs = settings.arguments;
        if (detailArgs is Lamaran) {
          // <String> = tipe data yang DIKEMBALIKAN saat pop (pesan untuk daftar)
          return MaterialPageRoute<String>(
            builder: (_) => LamaranDetailScreen(lamaran: detailArgs),
            settings: settings,
          );
        }
        return _errorRoute<String>(
          settings,
          'Data lamaran tidak dikirim ke halaman detail.',
        );
      case lamaranEdit:
        // Argument WAJIB berupa Lamaran -> cek tipenya dulu
        final editArgs = settings.arguments;
        if (editArgs is Lamaran) {
          // <Lamaran> = tipe data yang DIKEMBALIKAN saat pop (lamaran hasil edit)
          return MaterialPageRoute<Lamaran>(
            builder: (_) => LamaranEditScreen(lamaran: editArgs),
            settings: settings,
          );
        }
        return _errorRoute<Lamaran>(
          settings,
          'Data lamaran tidak dikirim ke halaman edit.',
        );
      default:
        return null; // route tidak terdaftar -> halaman 404
    }
  }

  static Route<T> _errorRoute<T>(RouteSettings settings, String message) {
    return MaterialPageRoute<T>(
      builder: (_) => NotFoundScreen(routeName: settings.name, message: message),
      settings: settings,
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}