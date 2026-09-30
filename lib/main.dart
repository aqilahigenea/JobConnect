import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'theme/app_colors.dart';

void main() => runApp(const JobConnectApp());

class JobConnectApp extends StatelessWidget {
  const JobConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryButton),
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
