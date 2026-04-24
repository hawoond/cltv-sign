import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';

class SignCompleteScreen extends StatefulWidget {
  final String documentId;
  const SignCompleteScreen({super.key, required this.documentId});

  @override
  State<SignCompleteScreen> createState() => _SignCompleteScreenState();
}

class _SignCompleteScreenState extends State<SignCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const AppLogo(size: 28, showText: true),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        size: 52,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '서명이 완료되었습니다!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '서명이 성공적으로 완료되었습니다.\n계약서 원본과 감사추적인증서가 이메일로 발송됩니다.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildCompletionCard(),
                  const SizedBox(height: 24),
                  _buildAuditTrailCard(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('서명 정보', style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoRow('문서', '업무위탁계약서.pdf'),
          _buildInfoRow('서명 완료', DateFormat('yyyy년 M월 d일 HH:mm').format(DateTime.now())),
          _buildInfoRow('서명 방식', '전자서명 (직접 서명)'),
          _buildInfoRow('문서 ID', widget.documentId.substring(0, 8).toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildAuditTrailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('감사추적인증서', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '법적 효력이 있는 감사추적인증서가 자동으로 생성되었습니다. 서명자의 IP, 기기 정보, 서명 시각이 기록됩니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCertBadge(Icons.access_time, DateFormat('HH:mm').format(DateTime.now())),
              const SizedBox(width: 12),
              _buildCertBadge(Icons.lock_outline, 'SHA-256 암호화'),
              const SizedBox(width: 12),
              _buildCertBadge(Icons.gavel_outlined, '전자서명법'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.primaryDark),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('계약서 다운로드'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.verified_outlined, size: 18),
            label: const Text('감사추적인증서 다운로드'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('홈으로 돌아가기'),
        ),
      ],
    );
  }
}
