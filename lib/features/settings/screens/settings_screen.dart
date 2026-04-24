import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotification = true;
  bool _kakaoNotification = false;
  bool _signReminder = true;
  bool _completionAlert = true;
  bool _marketingEmail = false;
  int _reminderDays = 3;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final isWide = MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            automaticallyImplyLeading: false,
            toolbarHeight: 56,
            title: Text('설정', style: Theme.of(context).textTheme.titleLarge),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user != null) _buildProfileSection(user, isWide),
                      const SizedBox(height: 20),
                      _buildNotificationSection(),
                      const SizedBox(height: 20),
                      _buildPlanSection(),
                      const SizedBox(height: 20),
                      _buildSecuritySection(),
                      const SizedBox(height: 20),
                      _buildDangerZone(auth),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(user, bool isWide) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('프로필', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                    if (user.company != null)
                      Text(user.company!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _showEditProfileDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('편집'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('알림 설정', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildSwitchTile(
            '이메일 알림',
            '서명 요청 및 완료 시 이메일로 알림을 받습니다.',
            _emailNotification,
            (v) => setState(() => _emailNotification = v),
          ),
          _buildSwitchTile(
            '카카오톡 알림',
            '카카오톡으로 서명 요청 알림을 받습니다.',
            _kakaoNotification,
            (v) => setState(() => _kakaoNotification = v),
          ),
          _buildSwitchTile(
            '서명 독촉 알림',
            '서명 기한이 다가오면 자동으로 독촉 메일을 발송합니다.',
            _signReminder,
            (v) => setState(() => _signReminder = v),
          ),
          if (_signReminder)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  Text('독촉 기준', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _reminderDays,
                    items: [1, 2, 3, 5, 7].map((d) => DropdownMenuItem(
                      value: d,
                      child: Text('만료 $d일 전'),
                    )).toList(),
                    onChanged: (v) => setState(() => _reminderDays = v ?? 3),
                    isDense: true,
                  ),
                ],
              ),
            ),
          _buildSwitchTile(
            '완료 알림',
            '모든 서명이 완료되면 알림을 받습니다.',
            _completionAlert,
            (v) => setState(() => _completionAlert = v),
          ),
          _buildSwitchTile(
            '마케팅 이메일',
            '새로운 기능 및 이벤트 소식을 이메일로 받습니다.',
            _marketingEmail,
            (v) => setState(() => _marketingEmail = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('요금제', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Team 플랜',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildPlanFeature('무제한 서명 요청', true),
          _buildPlanFeature('팀 워크스페이스', true),
          _buildPlanFeature('문서 보관 무제한', true),
          _buildPlanFeature('API 연동', true),
          _buildPlanFeature('전담 지원', true),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('결제 내역'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('플랜 변경'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanFeature(String feature, bool included) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: included ? AppColors.secondary : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: included ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('보안', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: '비밀번호 변경',
            subtitle: '마지막 변경: 30일 전',
            onTap: _showChangePasswordDialog,
          ),
          _buildSettingsTile(
            icon: Icons.devices_outlined,
            title: '로그인 기기 관리',
            subtitle: '현재 1개 기기에서 로그인 중',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.history_outlined,
            title: '활동 로그',
            subtitle: '최근 계정 활동을 확인합니다.',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.api_outlined,
            title: 'API 키 관리',
            subtitle: 'API 연동을 위한 키를 관리합니다.',
            onTap: _showApiKeyDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }

  Widget _buildDangerZone(AuthProvider auth) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '위험 구역',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('로그아웃', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    Text('현재 기기에서 로그아웃합니다.', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  await auth.logout();
                  if (mounted) context.go('/');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                child: const Text('로그아웃'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('계정 삭제', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: AppColors.danger)),
                    Text('계정과 모든 데이터가 영구적으로 삭제됩니다.', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showDeleteAccountDialog,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                child: const Text('계정 삭제'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: '이름')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: '회사명')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필이 업데이트되었습니다.')));
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, decoration: const InputDecoration(labelText: '현재 비밀번호')),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: const InputDecoration(labelText: '새 비밀번호')),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: const InputDecoration(labelText: '새 비밀번호 확인')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호가 변경되었습니다.')));
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API 키'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API 키', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'cltv_sk_live_••••••••••••••••••••••••••••••••',
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 8),
            Text('API 키는 외부에 노출되지 않도록 주의하세요.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('새 API 키가 생성되었습니다.')));
            },
            child: const Text('새 키 발급'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text('정말로 계정을 삭제하시겠습니까?\n모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
