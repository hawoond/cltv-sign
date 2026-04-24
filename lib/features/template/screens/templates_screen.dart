import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/services/mock_data_service.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '전체';
  String _searchQuery = '';

  final _categories = ['전체', '계약서', '동의서', '인사', '부동산', '기타'];

  List<Map<String, dynamic>> get _filteredTemplates {
    final templates = MockDataService.getTemplates();
    return templates.where((t) {
      final matchesCategory = _selectedCategory == '전체' || t['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          t['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final templates = _filteredTemplates;

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
                : Text('템플릿', style: Theme.of(context).textTheme.headlineSmall),
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showCreateTemplateDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('템플릿 만들기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildSearchBar(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _buildCategoryRow(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildTemplateGrid(templates, isWide),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _searchQuery.isEmpty ? '템플릿 검색' : _searchQuery,
              style: TextStyle(
                fontSize: 14,
                color: _searchQuery.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _searchQuery = ''),
              child: Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
            ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Row(
      children: _categories.map((cat) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedCategory == cat ? AppColors.primaryLight : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedCategory == cat ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 13,
                color: _selectedCategory == cat ? AppColors.primary : AppColors.textSecondary,
                fontWeight: _selectedCategory == cat ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTemplateGrid(List<Map<String, dynamic>> templates, bool isWide) {
    if (templates.isEmpty) {
      return EmptyState(
        icon: Icons.layers_outlined,
        title: '템플릿이 없습니다',
        subtitle: '새 템플릿을 만들어보세요.',
        action: ElevatedButton.icon(
          onPressed: _showCreateTemplateDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('템플릿 만들기'),
        ),
      );
    }

    if (isWide) {
      // 넓은 화면: 3열 그리드
      final rows = <Widget>[];
      for (int i = 0; i < templates.length; i += 3) {
        final rowItems = templates.sublist(i, i + 3 > templates.length ? templates.length : i + 3);
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...rowItems.map((t) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 12),
                child: SizedBox(height: 200, child: _buildTemplateCard(t)),
              ),
            )),
            if (rowItems.length < 3)
              ...List.generate(3 - rowItems.length, (_) => const Expanded(child: SizedBox())),
          ],
        ));
      }
      return Column(children: rows);
    } else {
      // 좁은 화면: 단일 열
      return Column(
        children: templates.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(height: 200, child: _buildTemplateCard(t)),
        )).toList(),
      );
    }
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final color = _getCategoryColor(template['category'] as String);
    return AppCard(
      onTap: () => _showTemplateDetailDialog(template),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.description_outlined, color: color, size: 20),
              ),
              const Spacer(),
              if (template['isDefault'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '기본',
                    style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 16, color: AppColors.textTertiary),
                onPressed: () => _handleTemplateAction('use', template),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            template['title'] as String,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            template['description'] as String,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  template['category'] as String,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              const Icon(Icons.people_outline, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 3),
              Text(
                '${template['signerCount']}명',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.download_outlined, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 3),
              Text(
                '${template['useCount']}회',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTemplateDetailDialog(Map<String, dynamic> template) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(template['title'] as String, style: Theme.of(context).textTheme.headlineSmall)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(template['description'] as String, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow('카테고리', template['category'] as String),
              _buildDetailRow('서명자 수', '${template['signerCount']}명'),
              _buildDetailRow('사용 횟수', '${template['useCount']}회'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/documents/new');
                      },
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: const Text('이 템플릿으로 요청'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _showCreateTemplateDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 템플릿 만들기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '템플릿 이름',
                hintText: '예: 표준 근로계약서',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/documents/new');
            },
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  void _handleTemplateAction(String action, Map<String, dynamic> template) {
    switch (action) {
      case 'use':
        context.go('/documents/new');
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('템플릿 편집 기능은 준비 중입니다.')));
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('템플릿이 복제되었습니다.')));
        break;
      case 'delete':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('템플릿이 삭제되었습니다.')));
        break;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '계약서': return AppColors.primary;
      case '동의서': return AppColors.secondary;
      case '인사': return AppColors.accent;
      case '부동산': return const Color(0xFF8B5CF6);
      default: return AppColors.textSecondary;
    }
  }
}
