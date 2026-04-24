import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms || !_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이용약관 및 개인정보처리방침에 동의해주세요.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
    );
    if (success && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.landing),
        ),
        title: const AppLogo(size: 28, showText: true),
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '무료로 시작하기',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1개월 무료 체험 · 신용카드 불필요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: '이름',
                    hint: '홍길동',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline, size: 18),
                    validator: (v) => v == null || v.isEmpty ? '이름을 입력해주세요.' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: '이메일',
                    hint: 'example@company.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '이메일을 입력해주세요.';
                      if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: '회사명 (선택)',
                    hint: '(주)클티브',
                    controller: _companyController,
                    prefixIcon: const Icon(Icons.business_outlined, size: 18),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: '비밀번호',
                    hint: '8자 이상 입력하세요',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '비밀번호를 입력해주세요.';
                      if (v.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: '비밀번호 확인',
                    hint: '비밀번호를 다시 입력하세요',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '비밀번호를 다시 입력해주세요.';
                      if (v != _passwordController.text) return '비밀번호가 일치하지 않습니다.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildAgreementSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('회원가입', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('이미 계정이 있으신가요? ', style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: const Text('로그인'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: _agreeTerms && _agreePrivacy,
            onChanged: (v) => setState(() {
              _agreeTerms = v ?? false;
              _agreePrivacy = v ?? false;
            }),
            title: const Text('전체 동의', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const Divider(),
          CheckboxListTile(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
            title: Row(
              children: [
                const Text('(필수) ', style: TextStyle(color: AppColors.danger, fontSize: 13)),
                const Text('이용약관 동의', style: TextStyle(fontSize: 13)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                  child: const Text('보기', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          CheckboxListTile(
            value: _agreePrivacy,
            onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
            title: Row(
              children: [
                const Text('(필수) ', style: TextStyle(color: AppColors.danger, fontSize: 13)),
                const Text('개인정보처리방침 동의', style: TextStyle(fontSize: 13)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                  child: const Text('보기', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
    );
  }
}
