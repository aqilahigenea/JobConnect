import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/alt_auth_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_tab_switcher.dart';
import '../widgets/login_header.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    // TODO: hubungkan ke logika login (belum termasuk tugas Praktikum 1).
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LoginHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  AuthTabSwitcher(
                    labels: const ['Masuk', 'Daftar'],
                    selectedIndex: 0,
                    onChanged: (index) {
                      if (index == 1) _goToRegister();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildFormCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildRegisterLink(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'DIDUKUNG JARINGAN 120+ MITRA KAMPUS',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.ribbon,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D111C2D),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x0D111C2D),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNotice(),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email Mahasiswa / NIM',
            hint: 'contoh: nama@mahasiswa.ac.id atau NIM',
            icon: Icons.badge_outlined,
            controller: _idController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Kata Sandi',
            hint: 'Masukkan kata sandi akun',
            icon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffix: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildUtilityRow(),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Masuk',
            trailingIcon: Icons.arrow_forward,
            onPressed: _onLoginPressed,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDivider(),
          const SizedBox(height: AppSpacing.lg),
          AltAuthButton(
            label: 'Masuk dengan SSO Kampus',
            icon: const Icon(Icons.account_balance, size: 18, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          AltAuthButton(
            label: 'Google',
            icon: const _GoogleMark(),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Akses terverifikasi untuk mahasiswa & alumni baru.',
              style: AppTextStyles.notice,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                activeColor: AppColors.primaryButton,
                side: const BorderSide(color: AppColors.checkboxBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.5)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('Ingat Saya', style: AppTextStyles.checkboxLabel),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: Text('Lupa Kata Sandi?', style: AppTextStyles.link),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(height: 1, thickness: 1, color: AppColors.divider),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('atau masuk dengan', style: AppTextStyles.dividerText),
        ),
        const Expanded(
          child: Divider(height: 1, thickness: 1, color: AppColors.divider),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Belum punya akun? ', style: AppTextStyles.footer),
        GestureDetector(
          onTap: _goToRegister,
          child: Text('Daftar sekarang', style: AppTextStyles.footerLink),
        ),
      ],
    );
  }
}

/// Pengganti sementara logo Google. Ganti dengan Image.asset(...) hasil ekspor Figma.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
