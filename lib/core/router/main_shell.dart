import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/document_provider.dart';
import '../../core/widgets/app_logo.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: '대시보드', route: AppRoutes.dashboard),
    _NavItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: '문서함', route: AppRoutes.documents),
    _NavItem(icon: Icons.layers_outlined, activeIcon: Icons.layers, label: '템플릿', route: AppRoutes.templates),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: '설정', route: AppRoutes.settings),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].route);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].route)) {
        if (_selectedIndex != i) setState(() => _selectedIndex = i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      bottomNavigationBar: isWide ? null : _buildBottomNav(),
      floatingActionButton: isWide ? null : _buildFab(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return widget.child;
  }

  Widget _buildSidebar() {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    return Container(
      width: AppConstants.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
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
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/documents/new'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('서명 요청'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                for (int i = 0; i < _navItems.length; i++)
                  _buildSidebarItem(_navItems[i], i),
              ],
            ),
          ),
          const Divider(height: 1),
          if (user != null)
            InkWell(
              onTap: () => context.go(AppRoutes.settings),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.planLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 18, color: AppColors.textTertiary),
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) context.go(AppRoutes.landing);
                      },
                      tooltip: '로그아웃',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_NavItem item, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onNavTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      items: _navItems.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        activeIcon: Icon(item.activeIcon),
        label: item.label,
      )).toList(),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => context.go('/documents/new'),
      tooltip: '서명 요청',
      child: const Icon(Icons.add),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
