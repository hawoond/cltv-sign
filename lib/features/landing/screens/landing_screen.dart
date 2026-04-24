import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_logo.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: AppColors.shadow,
            toolbarHeight: 64,
            title: Row(
              children: [
                const AppLogo(size: 32),
                const SizedBox(width: 10),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('서비스 소개'),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.pricing),
                child: const Text('요금 안내'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('로그인'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.register),
                child: const Text('무료로 시작하기'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(child: _buildHeroSection()),
          SliverToBoxAdapter(child: _buildStatsSection()),
          SliverToBoxAdapter(child: _buildFeaturesSection()),
          SliverToBoxAdapter(child: _buildFlowSection()),
          SliverToBoxAdapter(child: _buildPricingSection()),
          SliverToBoxAdapter(child: _buildCtaSection()),
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final isWide = MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 100 : 60,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F7FF), Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 5, child: _buildHeroText()),
                const SizedBox(width: 60),
                Expanded(flex: 5, child: _buildHeroVisual()),
              ],
            )
          : Column(
              children: [
                _buildHeroText(),
                const SizedBox(height: 40),
                _buildHeroVisual(),
              ],
            ),
    );
  }

  Widget _buildHeroText() {
    final isWide = MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                '법적 효력 보장 · 전자서명법 준수',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '서명이 필요한\n모든 곳에',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: isWide ? 52 : 36,
            height: 1.15,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'cltv-sign',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: isWide ? 52 : 36,
            height: 1.15,
            letterSpacing: -1.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '문서 업로드부터 서명 요청, 계약 완료까지\n빠르고 안전하게 전자서명을 진행하세요.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.register),
              icon: const Icon(Icons.rocket_launch_outlined, size: 18),
              label: const Text('1개월 무료 시작'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.login),
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: const Text('데모 체험하기'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _buildTrustBadge(Icons.lock_outline, '256비트 암호화'),
            const SizedBox(width: 20),
            _buildTrustBadge(Icons.gavel_outlined, '전자서명법 준수'),
            const SizedBox(width: 20),
            _buildTrustBadge(Icons.verified_user_outlined, 'ISO 27001'),
          ],
        ),
      ],
    );
  }

  Widget _buildTrustBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroVisual() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMd,
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFF5F57), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF28C840), shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'cltv-sign.com/sign/abc123',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDocPreview(),
                const SizedBox(height: 16),
                _buildSignatureArea(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      disabledBackgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      '서명 완료',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 20),
              const SizedBox(width: 8),
              Text('업무위탁계약서.pdf', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('서명 대기', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < 3; i++) ...[
            Container(
              height: 8,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
          Container(
            height: 8,
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureArea() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.draw_outlined, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              '여기에 서명하세요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: AppColors.primary,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 40,
        runSpacing: 32,
        children: [
          _buildStat('33만+', '기업·기관 회원'),
          _buildStat('1,000만+', '이용자'),
          _buildStat('5,000만+', '서명 완료'),
          _buildStat('99.9%', '서비스 가동률'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      _FeatureItem(
        icon: Icons.upload_file_outlined,
        title: '간편한 문서 업로드',
        description: 'PDF, DOCX, HWP 등 다양한 형식의 문서를 드래그앤드롭으로 업로드하세요.',
        color: AppColors.primary,
      ),
      _FeatureItem(
        icon: Icons.draw_outlined,
        title: '서명 필드 배치',
        description: '문서의 원하는 위치에 서명, 텍스트, 날짜, 도장 필드를 자유롭게 배치하세요.',
        color: AppColors.secondary,
      ),
      _FeatureItem(
        icon: Icons.send_outlined,
        title: '다양한 서명 요청 방식',
        description: '이메일, 카카오톡, QR코드, 링크 등 상황에 맞는 방식으로 서명을 요청하세요.',
        color: AppColors.accent,
      ),
      _FeatureItem(
        icon: Icons.track_changes_outlined,
        title: '실시간 진행 현황',
        description: '서명 진행 상황을 실시간으로 확인하고 알림을 받으세요.',
        color: const Color(0xFF8B5CF6),
      ),
      _FeatureItem(
        icon: Icons.verified_outlined,
        title: '감사추적인증서',
        description: '계약 완료 시 감사추적인증서가 자동으로 발급되어 법적 효력을 보장합니다.',
        color: const Color(0xFFEC4899),
      ),
      _FeatureItem(
        icon: Icons.layers_outlined,
        title: '템플릿 관리',
        description: '자주 사용하는 계약서를 템플릿으로 저장하고 재사용하세요.',
        color: const Color(0xFF14B8A6),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            '계약의 시작부터 끝까지',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'cltv-sign으로',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '전자서명에 필요한 모든 기능을 하나의 플랫폼에서 이용하세요.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 900 ? 3 : constraints.maxWidth >= 600 ? 2 : 1;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: features.map((f) => SizedBox(
                width: (constraints.maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount,
                child: _buildFeatureCard(f),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: feature.color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(feature.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowSection() {
    final steps = [
      _FlowStep(number: '01', title: '문서 업로드', description: '서명 받을 문서를 업로드하고 서명자 정보를 입력합니다.', icon: Icons.upload_file),
      _FlowStep(number: '02', title: '서명 위치 지정', description: '문서에서 서명이 필요한 위치에 서명 필드를 배치합니다.', icon: Icons.edit_location_alt),
      _FlowStep(number: '03', title: '서명 요청 발송', description: '이메일, 카카오톡 등으로 서명 요청을 발송합니다.', icon: Icons.send),
      _FlowStep(number: '04', title: '서명 완료', description: '서명자가 서명을 완료하면 계약서와 인증서가 자동 발급됩니다.', icon: Icons.task_alt),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: AppColors.background,
      child: Column(
        children: [
          Text(
            '4단계로 완성하는 전자서명',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            if (isWide) {
              return Row(
                children: steps.asMap().entries.map((e) {
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildFlowStep(e.value)),
                        if (e.key < steps.length - 1)
                          const Icon(Icons.arrow_forward, color: AppColors.border, size: 24),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
            return Column(
              children: steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildFlowStep(s),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFlowStep(_FlowStep step) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            step.number,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            step.title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            '합리적인 요금제',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '필요에 맞는 플랜을 선택하세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final plans = [
              _PlanItem(name: '무료', price: '0원', period: '영구 무료', features: ['월 5건 서명 요청', '기본 서명 방식', '문서 보관 30일', '이메일 지원'], isPopular: false, color: AppColors.textSecondary),
              _PlanItem(name: 'Personal', price: '9,900원', period: '/월', features: ['월 30건 서명 요청', '모든 서명 방식', '문서 보관 1년', '카카오톡 발송', '우선 지원'], isPopular: true, color: AppColors.primary),
              _PlanItem(name: 'Team', price: '29,900원', period: '/월', features: ['무제한 서명 요청', '팀 워크스페이스', '문서 보관 무제한', '대량 전송', 'API 연동', '전담 지원'], isPopular: false, color: AppColors.secondary),
            ];
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: plans.map((p) => SizedBox(
                width: isWide ? 280 : double.infinity,
                child: _buildPlanCard(p),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlanCard(_PlanItem plan) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: plan.isPopular ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular ? AppColors.primary : AppColors.border,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: plan.isPopular ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '가장 인기',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          Text(
            plan.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: plan.isPopular ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.price,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: plan.isPopular ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  plan.period,
                  style: TextStyle(
                    fontSize: 14,
                    color: plan.isPopular ? Colors.white.withOpacity(0.8) : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...plan.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: plan.isPopular ? Colors.white.withOpacity(0.9) : AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  f,
                  style: TextStyle(
                    fontSize: 13,
                    color: plan.isPopular ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.register),
              style: ElevatedButton.styleFrom(
                backgroundColor: plan.isPopular ? Colors.white : AppColors.primary,
                foregroundColor: plan.isPopular ? AppColors.primary : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('시작하기', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            '지금 바로 시작하세요',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '1개월 무료 체험으로 cltv-sign의 모든 기능을 경험해보세요.\n신용카드 없이 즉시 시작 가능합니다.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.register),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            child: const Text('무료로 시작하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 28, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'cltv-sign',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '서명이 필요한 모든 곳에',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2024 cltv-sign. All rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('이용약관', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('개인정보처리방침', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  _FeatureItem({required this.icon, required this.title, required this.description, required this.color});
}

class _FlowStep {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  _FlowStep({required this.number, required this.title, required this.description, required this.icon});
}

class _PlanItem {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final Color color;
  _PlanItem({required this.name, required this.price, required this.period, required this.features, required this.isPopular, required this.color});
}
