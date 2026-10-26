import 'package:flutter/material.dart';

import '../data/user_session.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_tab_switcher.dart';
import '../widgets/login_header.dart';
import '../widgets/primary_button.dart';

/// Halaman Pendaftaran Akun — Form bersih dengan validasi error langsung di bawah field,
/// format email @gmail.com, serta keyboard input yang lancar dan responsif.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _submitted = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _termsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  String? _checkName(String value) {
    if (value.trim().isEmpty) return 'Nama lengkap wajib diisi';
    return null;
  }

  String? _checkEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email wajib diisi';

    final gmailRegex = RegExp(
      r'^[\w\.-]+@gmail\.com$',
      caseSensitive: false,
    );
    if (!gmailRegex.hasMatch(trimmed)) {
      return 'Format email harus menggunakan @gmail.com';
    }
    return null;
  }

  String? _checkPassword(String value) {
    if (value.isEmpty) return 'Kata sandi wajib diisi';
    if (value.length < 8) return 'Kata sandi minimal 8 karakter';
    return null;
  }

  String? _checkConfirmPassword(String value) {
    if (value.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
    if (value != _passwordController.text) {
      return 'Konfirmasi kata sandi tidak cocok';
    }
    return null;
  }

  void _onFieldChanged(String field) {
    if (!_submitted) {
      // Rebuild hanya untuk menampilkan/menyembunyikan tombol clear (X)
      setState(() {});
      return;
    }

    setState(() {
      switch (field) {
        case 'name':
          _nameError = _checkName(_nameController.text);
          break;
        case 'email':
          _emailError = _checkEmail(_emailController.text);
          break;
        case 'password':
          _passwordError = _checkPassword(_passwordController.text);
          if (_confirmPasswordController.text.isNotEmpty) {
            _confirmPasswordError =
                _checkConfirmPassword(_confirmPasswordController.text);
          }
          break;
        case 'confirm':
          _confirmPasswordError =
              _checkConfirmPassword(_confirmPasswordController.text);
          break;
      }
    });
  }

  void _onRegisterPressed() {
    setState(() {
      _submitted = true;
      _nameError = _checkName(_nameController.text);
      _emailError = _checkEmail(_emailController.text);
      _passwordError = _checkPassword(_passwordController.text);
      _confirmPasswordError =
          _checkConfirmPassword(_confirmPasswordController.text);
      _termsError = !_agreedToTerms;
    });

    final hasError = _nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null ||
        _termsError;

    if (hasError) return;

    // Simpan informasi pendaftaran ke UserSession
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    UserSession().registerUser(name: name, email: email);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Silakan masuk ke akunmu.'),
          backgroundColor: AppColors.primary,
        ),
      );

    Navigator.pushReplacementNamed(context, AppRoutes.login);
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
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LoginHeader(showCategoryChips: false),
                  const SizedBox(height: AppSpacing.xl),
                  AuthTabSwitcher(
                    labels: const ['Masuk', 'Daftar'],
                    selectedIndex: 1,
                    onChanged: (index) {
                      if (index == 0) _goToLogin();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildFormCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildLoginLink(),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
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
          // 1. Nama Lengkap
          AppTextField(
            label: 'Nama Lengkap',
            hint: 'Nama lengkap',
            icon: Icons.person_outline,
            controller: _nameController,
            keyboardType: TextInputType.name,
            errorText: _nameError,
            onChanged: (_) => _onFieldChanged('name'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Email (@gmail.com)
          AppTextField(
            label: 'Email',
            hint: '@gmail.com',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: (_) => _onFieldChanged('email'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. Kata Sandi
          AppTextField(
            label: 'Kata Sandi',
            hint: 'Minimal 8 karakter',
            icon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: _obscurePassword,
            errorText: _passwordError,
            onChanged: (_) => _onFieldChanged('password'),
            suffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_passwordController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear,
                        size: 18, color: AppColors.textSecondary),
                    tooltip: 'Hapus kata sandi',
                    onPressed: () {
                      _passwordController.clear();
                      _onFieldChanged('password');
                    },
                  ),
                IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 4. Konfirmasi Kata Sandi
          AppTextField(
            label: 'Konfirmasi Kata Sandi',
            hint: 'Ulangi kata sandi',
            icon: Icons.verified_user_outlined,
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            errorText: _confirmPasswordError,
            onChanged: (_) => _onFieldChanged('confirm'),
            suffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_confirmPasswordController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear,
                        size: 18, color: AppColors.textSecondary),
                    tooltip: 'Hapus konfirmasi kata sandi',
                    onPressed: () {
                      _confirmPasswordController.clear();
                      _onFieldChanged('confirm');
                    },
                  ),
                IconButton(
                  onPressed: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 5. Syarat & Ketentuan
          _buildTermsRow(),
          if (_termsError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'Kamu harus menyetujui Syarat & Ketentuan',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          // 6. Tombol Daftar Akun
          PrimaryButton(
            label: 'Daftar Akun',
            trailingIcon: Icons.arrow_forward,
            onPressed: _onRegisterPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: GestureDetector(
            onTap: () => setState(() {
              _agreedToTerms = !_agreedToTerms;
              if (_agreedToTerms) _termsError = false;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _agreedToTerms ? AppColors.primaryButton : Colors.white,
                borderRadius: BorderRadius.circular(2.5),
                border: _agreedToTerms
                    ? null
                    : Border.all(
                        color: _termsError
                            ? AppColors.error
                            : AppColors.checkboxBorder,
                      ),
              ),
              child: _agreedToTerms
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _agreedToTerms = !_agreedToTerms;
              if (_agreedToTerms) _termsError = false;
            }),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.notice,
                children: [
                  const TextSpan(text: 'Saya menyetujui '),
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: AppTextStyles.notice.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' serta '),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: AppTextStyles.notice.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' JobConnect'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Sudah punya akun? ', style: AppTextStyles.footer),
        GestureDetector(
          onTap: _goToLogin,
          child: Text('Masuk di sini', style: AppTextStyles.footerLink),
        ),
      ],
    );
  }
}
