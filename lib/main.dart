import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/job_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/form_catatan_screen.dart';
import 'theme/app_colors.dart';

void main() => runApp(const JobConnectApp());

class JobConnectApp extends StatelessWidget {
  const JobConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobProvider(),
      child: MaterialApp(
        title: 'JobConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryButton),
          scaffoldBackgroundColor: AppColors.background,
        ),
        // Menggunakan Named Routes (poin f)
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/detail': (context) => const DetailScreen(),
          '/form-catatan': (context) => const FormCatatanScreen(),
        },
      ),
    );
  }
}