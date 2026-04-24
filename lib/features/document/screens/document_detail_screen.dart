import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/providers/document_provider.dart';
import '../../../data/models/document_model.dart';

class DocumentDetailScreen extends StatelessWidget {
  final String documentId;
  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();
    final doc = docProvider.getDocumentById(documentId);

    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('문서 상세')),
        body: const EmptyState(
          icon: Icons.description_outlined,
          title: '문서를 찾을 수 없습니다',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(doc.title, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/documents'),
        ),
        actions: [
          if (doc.status == DocumentStatus.draft)
            ElevatedButton.icon(
              onPressed: () => context.go('/sign-request/${doc.id}'),
              icon: const Icon(Icons.send_outlined, size: 16),
              label: const Text('서명 요청'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _handleAction(context, 'download', doc, docProvider),
            tooltip: '더 보기',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocumentHeader(context, doc),
              const SizedBox(height: 20),
              _buildProgressSection(context, doc),
              const SizedBox(height: 20),
              _buildParticipantsSection(context, doc),
              const SizedBox(height: 20),
              _buildDocumentInfo(context, doc),
              if (doc.status == DocumentStatus.pending || doc.status == DocumentStatus.inProgress) ...[
                const SizedBox(height: 20),
                _buildSignLinkSection(context, doc),
              ],
              if (doc.status == DocumentStatus.completed) ...[
                const SizedBox(height: 20),
                _buildCompletionSection(context, doc),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentHeader(BuildContext context, Document doc) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title, style: Theme.of(context).textTheme.headlineSmall),
                if (doc.description != null) ...[
                  const SizedBox(height: 4),
                  Text(doc.description!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(status: doc.status),
                    if (doc.category != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          doc.category!,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, Document doc) {
    if (doc.participants.isEmpty) return const SizedBox();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('서명 진행 현황', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${doc.signedCount}/${doc.totalCount} 완료',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(
            value: doc.progress,
            color: doc.status == DocumentStatus.completed ? AppColors.secondary : AppColors.primary,
            height: 8,
          ),
          const SizedBox(height: 8),
          Text(
            doc.status == DocumentStatus.completed
                ? '모든 서명이 완료되었습니다.'
                : '${doc.totalCount - doc.signedCount}명의 서명이 남아있습니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context, Document doc) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('서명자 목록', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (doc.participants.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('서명자가 없습니다.', style: Theme.of(context).textTheme.bodyMedium),
              ),
            )
          else
            ...doc.participants.map((p) => _buildParticipantItem(context, p, doc)),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(BuildContext context, Participant p, Document doc) {
    final statusConfig = _getParticipantStatusConfig(p.status);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              p.name.isNotEmpty ? p.name[0] : '?',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: Theme.of(context).textTheme.titleSmall),
                Text(p.email, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusConfig.bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusConfig.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusConfig.textColor,
                  ),
                ),
              ),
              if (p.signedAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  DateFormat('M/d HH:mm').format(p.signedAt!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentInfo(BuildContext context, Document doc) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('문서 정보', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildInfoRow(context, '파일명', doc.fileName ?? '-'),
          _buildInfoRow(context, '페이지', '${doc.pageCount}페이지'),
          if (doc.fileSize != null)
            _buildInfoRow(context, '파일 크기', _formatFileSize(doc.fileSize!)),
          _buildInfoRow(context, '생성일', DateFormat('yyyy.MM.dd HH:mm').format(doc.createdAt)),
          if (doc.expiresAt != null)
            _buildInfoRow(context, '만료일', DateFormat('yyyy.MM.dd').format(doc.expiresAt!)),
          if (doc.completedAt != null)
            _buildInfoRow(context, '완료일', DateFormat('yyyy.MM.dd HH:mm').format(doc.completedAt!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSignLinkSection(BuildContext context, Document doc) {
    final signLink = 'https://cltv-sign.com/sign/${doc.id}';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('서명 링크', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    signLink,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: signLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('링크가 복사되었습니다.')),
                  );
                },
                tooltip: '링크 복사',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              data: signLink,
              version: QrVersions.auto,
              size: 160,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'QR코드를 스캔하여 서명하세요',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSection(BuildContext context, Document doc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.task_alt, color: AppColors.secondary, size: 40),
          const SizedBox(height: 12),
          Text(
            '계약이 완료되었습니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '모든 서명자가 서명을 완료했습니다.\n원본 문서와 감사추적인증서가 이메일로 발송되었습니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF065F46),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('문서 다운로드'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.verified_outlined, size: 16),
                label: const Text('인증서 다운로드'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action, Document doc, DocumentProvider docProvider) {
    switch (action) {
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('문서를 다운로드합니다.')));
        break;
      case 'cert':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('감사추적인증서를 다운로드합니다.')));
        break;
      case 'remind':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('서명 독촉 메일이 발송되었습니다.')));
        break;
      case 'cancel':
        docProvider.cancelDocument(doc.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('서명 요청이 취소되었습니다.')));
        break;
      case 'delete':
        docProvider.deleteDocument(doc.id);
        context.go('/documents');
        break;
    }
  }

  _ParticipantStatusConfig _getParticipantStatusConfig(ParticipantStatus status) {
    switch (status) {
      case ParticipantStatus.pending:
        return _ParticipantStatusConfig('서명 대기', AppColors.accentLight, const Color(0xFF92400E));
      case ParticipantStatus.viewed:
        return _ParticipantStatusConfig('열람함', AppColors.primaryLight, AppColors.primaryDark);
      case ParticipantStatus.signed:
        return _ParticipantStatusConfig('서명 완료', AppColors.secondaryLight, const Color(0xFF065F46));
      case ParticipantStatus.rejected:
        return _ParticipantStatusConfig('거절', AppColors.dangerLight, const Color(0xFF991B1B));
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _ParticipantStatusConfig {
  final String label;
  final Color bgColor;
  final Color textColor;
  _ParticipantStatusConfig(this.label, this.bgColor, this.textColor);
}
