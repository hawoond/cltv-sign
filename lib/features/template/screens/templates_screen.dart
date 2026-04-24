import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/services/mock_data_service.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String _selectedCategory = '전체';
  String _searchQuery = '';
  bool _showSearch = false;

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
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;
    final templates = _filteredTemplates;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(isWide),
          _buildSearchAndFilter(isWide),
          Expanded(
            child: _buildTemplateList(templates, isWide),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isWide) {
    return Container(
      height: 56,
      color: AppColors.surface,
      child: Row(
        children: [
          const SizedBox(width: 16),
          if (!isWide)
            Text('템플릿', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchQuery = '';
            }),
            tooltip: '검색',
          ),
          ElevatedButton.icon(
            onPressed: _showCreateTemplateDialog,
            icon: const Icon(Icons.add, size: 16),
            label: Text(isWide ? '템플릿 만들기' : '만들기'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 16 : 12,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isWide) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _buildSearchInput(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _buildCategoryFilter(),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: EditableText(
              controller: TextEditingController(text: _searchQuery),
              focusNode: FocusNode(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.primary,
              backgroundCursorColor: Colors.transparent,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _searchQuery = ''),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.clear, size: 14, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedCategory == cat ? AppColors.primaryLight : Colors.transparent,
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
      ),
    );
  }

  Widget _buildTemplateList(List<Map<String, dynamic>> templates, bool isWide) {
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

    return GridView.builder(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 1.6 : 2.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) => _buildTemplateCard(templates[index], isWide),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template, bool isWide) {
    final color = _getCategoryColor(template['category'] as String);
    return AppCard(
      onTap: () => _showTemplateDetailDialog(template),
      child: isWide ? _buildWideCard(template, color) : _buildNarrowCard(template, color),
    );
  }

  Widget _buildWideCard(Map<String, dynamic> template, Color color) {
    return Column(
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
              onPressed: () => _showTemplateDetailDialog(template),
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
        Expanded(
          child: Text(
            template['description'] as String,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
            Text('${template['signerCount']}명', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 8),
            const Icon(Icons.download_outlined, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 3),
            Text('${template['useCount']}회', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowCard(Map<String, dynamic> template, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.description_outlined, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (template['isDefault'] == true)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        '기본',
                        style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                template['description'] as String,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      template['category'] as String,
                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.people_outline, size: 11, color: AppColors.textTertiary),
                  const SizedBox(width: 2),
                  Text('${template['signerCount']}명', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                  const Icon(Icons.download_outlined, size: 11, color: AppColors.textTertiary),
                  const SizedBox(width: 2),
                  Text('${template['useCount']}회', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
          onPressed: () => _showTemplateDetailDialog(template),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _showTemplateDetailDialog(Map<String, dynamic> template) {
    final color = _getCategoryColor(template['category'] as String);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.description_outlined, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                template['description'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
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
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 템플릿 만들기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
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
