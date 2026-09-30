import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_tab_switcher.dart';
import '../widgets/interest_chip_group.dart';
import '../widgets/job_type_selector.dart';
import '../widgets/login_header.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

/// Halaman Pendaftaran Akun — sesuai desain Figma "JobConnect - Pendaftaran Akun".
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  static const _interestOptions = [
    'UI/UX Design',
    'Web Dev',
    'Data & AI',
    'Digital Marketing',
    'Content Creator',
    'Graphic Design',
    'Finance',
  ];
  final Set<String> _selectedInterests = {'UI/UX Design', 'Web Dev'};

  static const _jobTypeOptions = [
    'Magang (Internship)',
    'Paruh Waktu (Part-Time)',
    'Freelance / Proyek',
    'Remote Work',
  ];
  final Set<String> _selectedJobTypes = {
    'Magang (Internship)',
    'Paruh Waktu (Part-Time)',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onRegisterPressed() {
    // TODO: hubungkan ke logika pendaftaran (belum termasuk tugas Praktikum 1).
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
          AppTextField(
            label: 'Nama Lengkap',
            hint: 'Nama lengkap sesuai KTM/KTP',
            icon: Icons.person_outline,
            controller: _nameController,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email Kampus / NIM',
            hint: 'mhs@kampus.ac.id / 12345678',
            icon: Icons.school_outlined,
            controller: _idController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Kata Sandi',
            hint: 'Minimal 8 karakter',
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
          AppTextField(
            label: 'Konfirmasi Kata Sandi',
            hint: 'Ulangi kata sandi',
            icon: Icons.verified_user_outlined,
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            suffix: IconButton(
              onPressed: () =>
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInterestSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildJobTypeSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildTermsRow(),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Daftar Akun',
            trailingIcon: Icons.arrow_forward,
            onPressed: _onRegisterPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildInterestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bidang Minat Mahasiswa', style: AppTextStyles.label),
            Text('Pilih yang sesuai', style: AppTextStyles.badge.copyWith(
              color: AppColors.textHint,
            )),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        InterestChipGroup(
          options: _interestOptions,
          selected: _selectedInterests,
          onToggle: (label) => setState(() {
            _selectedInterests.contains(label)
                ? _selectedInterests.remove(label)
                : _selectedInterests.add(label);
          }),
        ),
      ],
    );
  }

  Widget _buildJobTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jenis Pekerjaan yang Dicari', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        JobTypeSelector(
          options: _jobTypeOptions,
          selected: _selectedJobTypes,
          onToggle: (label) => setState(() {
            _selectedJobTypes.contains(label)
                ? _selectedJobTypes.remove(label)
                : _selectedJobTypes.add(label);
          }),
        ),
      ],
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: _agreedToTerms ? AppColors.primaryButton : Colors.white,
                borderRadius: BorderRadius.circular(2.5),
                border: _agreedToTerms
                    ? null
                    : Border.all(color: AppColors.checkboxBorder),
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
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
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
