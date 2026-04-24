import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/document_provider.dart';
import '../../../data/models/document_model.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final docProvider = context.read<DocumentProvider>();
      if (auth.currentUser != null) {
        docProvider.loadDocuments(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    final docProvider = context.watch<DocumentProvider>();

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
            title: Text('문서함', style: Theme.of(context).textTheme.headlineSmall),
            actions: [
              ElevatedButton.icon(
                onPressed: () => context.go('/documents/new'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('서명 요청'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isWide ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabRow(docProvider),
                  const SizedBox(height: 16),
                  _buildDocumentList(docProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabRow(DocumentProvider docProvider) {
    final labels = [
      '전체 (${docProvider.documents.length})',
      '진행중 (${docProvider.pendingDocuments.length})',
      '완료 (${docProvider.completedDocuments.length})',
      '임시저장 (${docProvider.draftDocuments.length})',
    ];
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _tabBtn(labels[i], i),
        ],
      ],
    );
  }

  Widget _tabBtn(String label, int index) {
    final sel = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
            color: sel ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentList(DocumentProvider docProvider) {
    final docs = _selectedTab == 0
        ? docProvider.documents
        : _selectedTab == 1
            ? docProvider.pendingDocuments
            : _selectedTab == 2
                ? docProvider.completedDocuments
                : docProvider.draftDocuments;

    if (docs.isEmpty) {
      return EmptyState(
        icon: Icons.description_outlined,
        title: '문서가 없습니다',
        subtitle: '서명 요청을 시작해보세요.',
        action: ElevatedButton.icon(
          onPressed: () => context.go('/documents/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('서명 요청 시작'),
        ),
      );
    }

     final items = <Widget>[];
    for (int i = 0; i < docs.length; i++) {
      if (i > 0) items.add(const SizedBox(height: 8));
      items.add(_buildDocumentItem(docs[i], docProvider));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildDocumentItem(Document doc, DocumentProvider docProvider) {
    return GestureDetector(
      onTap: () => context.go('/documents/${doc.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 20),
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
                    if (doc.category != null)
                      Text(
                        doc.category!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.primary),
                      ),
                  ],
                ),
              ),
              StatusBadge(status: doc.status),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textTertiary),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  doc.participants.isEmpty
                      ? '서명자 미지정'
                      : doc.participants.map((p) => p.name).join(', '),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(doc.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (doc.participants.isNotEmpty && doc.status != DocumentStatus.draft) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ProgressBar(
                    value: doc.progress,
                    color: doc.status == DocumentStatus.completed
                        ? AppColors.secondary
                        : AppColors.primary,
                    height: 4,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${doc.signedCount}/${doc.totalCount}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
         ],
      ),
      ),
    );
  }
  void _handleDocumentAction(String action, Document doc, DocumentProvider docProvider) {
    switch (action) {
      case 'view':
        context.go('/documents/${doc.id}');
        break;
      case 'download':
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('문서를 다운로드합니다.')));
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('문서 삭제'),
            content: Text('"${doc.title}" 문서를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  docProvider.deleteDocument(doc.id);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                child: const Text('삭제'),
              ),
            ],
          ),
        );
        break;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return DateFormat('yyyy.MM.dd').format(date);
  }
}
