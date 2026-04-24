import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/document_provider.dart';
import '../../../data/models/document_model.dart';
import '../../../data/services/mock_data_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final docProvider = context.read<DocumentProvider>();
      if (auth.currentUser != null) {
        docProvider.loadDocuments(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final docProvider = context.watch<DocumentProvider>();
    final user = auth.currentUser;
    final stats = MockDataService.getDashboardStats(user?.id ?? '');
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
            toolbarHeight: 64,
            title: isWide
                ? null
                : Text('대시보드', style: Theme.of(context).textTheme.headlineSmall),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                tooltip: '알림',
              ),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isWide ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(user?.name ?? ''),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  _buildStatsGrid(stats),
                  const SizedBox(height: 32),
                  _buildUsageProgress(stats),
                  const SizedBox(height: 32),
                  _buildRecentDocuments(docProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? '좋은 아침이에요' : hour < 18 ? '안녕하세요' : '안녕하세요';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $name님 👋',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrentDate(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/documents/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('서명 요청'),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(icon: Icons.upload_file_outlined, label: '문서 업로드', color: AppColors.primary, onTap: () => context.go('/documents/new')),
      _QuickAction(icon: Icons.send_outlined, label: '서명 요청', color: AppColors.secondary, onTap: () => context.go('/documents/new')),
      _QuickAction(icon: Icons.layers_outlined, label: '템플릿', color: AppColors.accent, onTap: () => context.go(AppRoutes.templates)),
      _QuickAction(icon: Icons.link_outlined, label: '링크 서명', color: const Color(0xFF8B5CF6), onTap: () {}),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('빠른 시작', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildQuickActionCard(a),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(_QuickAction action) {
    return AppCard(
      onTap: action.onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(action.icon, color: action.color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final statItems = [
      _StatItem('전체 문서', '${stats['totalDocuments']}건', Icons.description_outlined, AppColors.primary, '+12%'),
      _StatItem('진행중', '${stats['pendingDocuments']}건', Icons.pending_outlined, AppColors.accent, '+3건'),
      _StatItem('완료', '${stats['completedDocuments']}건', Icons.task_alt_outlined, AppColors.secondary, '+5건'),
      _StatItem('이번달 서명', '${stats['thisMonthSignatures']}건', Icons.draw_outlined, const Color(0xFF8B5CF6), '+8%'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('현황 요약', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (isWide)
          Row(
            children: statItems.map((s) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: StatCard(
                  label: s.label,
                  value: s.value,
                  icon: s.icon,
                  color: s.color,
                  trend: s.trend,
                ),
              ),
            )).toList(),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: statItems.map((s) => StatCard(
              label: s.label,
              value: s.value,
              icon: s.icon,
              color: s.color,
              trend: s.trend,
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildUsageProgress(Map<String, dynamic> stats) {
    final usage = stats['monthlyUsage'] as int;
    final limit = stats['monthlyLimit'] as int;
    final progress = usage / limit;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이번달 사용량', style: Theme.of(context).textTheme.titleMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Team 플랜',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '서명 요청 $usage / $limit건',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(progress * 100).toInt()}% 사용',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: progress > 0.8 ? AppColors.danger : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(
            value: progress,
            color: progress > 0.8 ? AppColors.danger : AppColors.primary,
            height: 8,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                '매월 1일 초기화됩니다.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                child: const Text('플랜 업그레이드', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocuments(DocumentProvider docProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '최근 문서',
          trailing: TextButton(
            onPressed: () => context.go(AppRoutes.documents),
            child: const Text('전체 보기'),
          ),
        ),
        const SizedBox(height: 12),
        if (docProvider.isLoading)
          const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ))
        else if (docProvider.recentDocuments.isEmpty)
          EmptyState(
            icon: Icons.description_outlined,
            title: '문서가 없습니다',
            subtitle: '첫 번째 서명 요청을 시작해보세요.',
            action: ElevatedButton.icon(
              onPressed: () => context.go('/documents/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('서명 요청 시작'),
            ),
          )
        else
          Column(
            children: docProvider.recentDocuments.map((doc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDocumentCard(doc),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildDocumentCard(Document doc) {
    return AppCard(
      onTap: () => context.go('/documents/${doc.id}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${doc.participants.length}명 서명자',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    const Text('·', style: TextStyle(color: AppColors.textTertiary)),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(doc.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (doc.participants.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ProgressBar(
                    value: doc.progress,
                    height: 4,
                    color: doc.status == DocumentStatus.completed
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusBadge(status: doc.status, compact: true),
        ],
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${now.year}년 ${now.month}월 ${now.day}일 (${weekdays[now.weekday % 7]})';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return DateFormat('M월 d일').format(date);
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  _StatItem(this.label, this.value, this.icon, this.color, this.trend);
}
