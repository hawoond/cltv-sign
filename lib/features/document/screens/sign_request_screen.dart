import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/providers/document_provider.dart';
import '../../../data/models/document_model.dart';

class SignRequestScreen extends StatefulWidget {
  final String documentId;
  const SignRequestScreen({super.key, required this.documentId});

  @override
  State<SignRequestScreen> createState() => _SignRequestScreenState();
}

class _SignRequestScreenState extends State<SignRequestScreen> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();
    final doc = docProvider.getDocumentById(widget.documentId);

    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('서명 요청')),
        body: const EmptyState(icon: Icons.description_outlined, title: '문서를 찾을 수 없습니다'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('서명 요청 발송'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/documents/${doc.id}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('문서 정보', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.title, style: Theme.of(context).textTheme.titleSmall),
                              if (doc.fileName != null)
                                Text(doc.fileName!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('서명자 목록', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (doc.participants.isEmpty)
                      Text('서명자가 없습니다.', style: Theme.of(context).textTheme.bodyMedium)
                    else
                      ...doc.participants.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                p.name.isNotEmpty ? p.name[0] : '?',
                                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: Theme.of(context).textTheme.titleSmall),
                                  Text(p.email, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getSendMethodLabel(p.sendMethod),
                                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : () => _sendRequest(docProvider, doc),
                  icon: _isSending
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_outlined, size: 18),
                  label: Text(_isSending ? '발송 중...' : '서명 요청 발송'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendRequest(DocumentProvider docProvider, Document doc) async {
    setState(() => _isSending = true);
    await docProvider.sendSignRequest(doc.id);
    if (mounted) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서명 요청이 발송되었습니다.'), backgroundColor: AppColors.secondary),
      );
      context.go('/documents/${doc.id}');
    }
  }

  String _getSendMethodLabel(SendMethod method) {
    switch (method) {
      case SendMethod.email: return '이메일';
      case SendMethod.kakao: return '카카오톡';
      case SendMethod.link: return '링크';
      case SendMethod.inPerson: return '대면';
      case SendMethod.qr: return 'QR';
      case SendMethod.bulk: return '대량';
    }
  }
}
