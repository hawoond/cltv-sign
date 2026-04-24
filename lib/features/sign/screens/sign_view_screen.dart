import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/document_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../widgets/signature_canvas_widget.dart';

class SignViewScreen extends StatefulWidget {
  final String token;
  const SignViewScreen({super.key, required this.token});

  @override
  State<SignViewScreen> createState() => _SignViewScreenState();
}

class _SignViewScreenState extends State<SignViewScreen> {
  int _currentStep = 0;
  final Map<String, String> _filledFields = {};
  bool _isSubmitting = false;
  bool _agreedToTerms = false;

  late Document _document;
  late List<_SignFieldItem> _fields;

  @override
  void initState() {
    super.initState();
    _document = MockDataService.getDemoDocuments().first;
    _fields = [
      _SignFieldItem(id: 'f1', type: SignFieldType.signature, label: '서명'),
      _SignFieldItem(id: 'f2', type: SignFieldType.date, label: '날짜'),
      _SignFieldItem(id: 'f3', type: SignFieldType.text, label: '직책'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const AppLogo(size: 28, showText: true),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  '보안 연결',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                SizedBox(width: 320, child: _buildSidebar()),
                const VerticalDivider(width: 1),
                Expanded(child: _buildDocumentView()),
              ],
            )
          : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(child: _buildDocumentView()),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDocumentInfo(),
                  const SizedBox(height: 20),
                  _buildFieldsList(),
                  const SizedBox(height: 20),
                  _buildTermsSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final total = _fields.length;
    final filled = _filledFields.length;
    final progress = total == 0 ? 0.0 : filled / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '서명 진행률',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '$filled / $total',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderLight,
              color: AppColors.secondary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('문서 정보', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _document.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '요청자: ${_document.ownerName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_document.message != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _document.message!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('서명 항목', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ..._fields.asMap().entries.map((entry) {
          final i = entry.key;
          final field = entry.value;
          final isFilled = _filledFields.containsKey(field.id);
          final isCurrent = i == _currentStep;

          return GestureDetector(
            onTap: () => _handleFieldTap(field),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primaryLight
                    : isFilled
                        ? AppColors.secondaryLight
                        : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary
                      : isFilled
                          ? AppColors.secondary
                          : AppColors.border,
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFilled ? AppColors.secondary : isCurrent ? AppColors.primary : AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFilled ? Icons.check : _getFieldIcon(field.type),
                      size: 14,
                      color: isFilled || isCurrent ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.label,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isCurrent ? AppColors.primary : isFilled ? AppColors.secondary : AppColors.textPrimary,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        Text(
                          isFilled ? '완료' : isCurrent ? '서명 필요' : '대기 중',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isFilled ? AppColors.secondary : isCurrent ? AppColors.primary : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isFilled && isCurrent)
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTermsSection() {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전자서명 동의',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '전자서명법에 따라 본 서명은 법적 효력을 가집니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final allFilled = _filledFields.length == _fields.length;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: allFilled && _agreedToTerms && !_isSubmitting ? _submitSignature : null,
            icon: _isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check_circle_outline, size: 18),
            label: Text(_isSubmitting ? '제출 중...' : '서명 완료'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showDeclineDialog(),
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('서명 거절'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final allFilled = _filledFields.length == _fields.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _showDeclineDialog,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
              child: const Text('거절'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: allFilled && _agreedToTerms && !_isSubmitting ? _submitSignature : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: const Text('서명 완료'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentView() {
    return Container(
      color: const Color(0xFF525659),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 595,
            constraints: const BoxConstraints(minHeight: 842),
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          _document.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildDocumentContent(),
                      const SizedBox(height: 60),
                      _buildSignatureArea(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('제1조 (목적)', '본 계약은 갑과 을 사이의 업무 위탁에 관한 사항을 정함을 목적으로 합니다.'),
        _buildSection('제2조 (위탁 업무)', '갑은 을에게 다음 각 호의 업무를 위탁합니다.\n1. 소프트웨어 개발 및 유지보수\n2. 기술 지원 서비스\n3. 기타 갑이 지정하는 업무'),
        _buildSection('제3조 (계약 기간)', '본 계약의 유효기간은 계약 체결일로부터 1년으로 하며, 계약 만료 30일 전까지 별도의 해지 통보가 없을 경우 동일한 조건으로 1년씩 자동 연장됩니다.'),
        _buildSection('제4조 (대가 및 지급)', '갑은 을에게 위탁 업무에 대한 대가로 매월 금 ○○○만원을 지급합니다.'),
        _buildSection('제5조 (비밀 유지)', '을은 본 계약의 수행 과정에서 취득한 갑의 영업 비밀 및 기술 정보를 제3자에게 누설하거나 본 계약 이외의 목적으로 사용하여서는 아니 됩니다.'),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildSignatureArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('갑 (위탁인)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildSignBox('갑', isOwner: true),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('을 (수탁인)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildSignBox('f1', isOwner: false),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignBox(String fieldId, {required bool isOwner}) {
    final isFilled = _filledFields.containsKey(fieldId);

    return GestureDetector(
      onTap: isOwner ? null : () => _handleFieldTap(_fields.firstWhere((f) => f.id == fieldId, orElse: () => _fields.first)),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isOwner ? AppColors.borderLight : isFilled ? AppColors.secondaryLight : AppColors.primaryLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isOwner ? AppColors.border : isFilled ? AppColors.secondary : AppColors.primary,
            width: isOwner ? 1 : 1.5,
          ),
        ),
        child: Center(
          child: isOwner
              ? Text('(서명)', style: TextStyle(color: AppColors.textTertiary, fontSize: 13))
              : isFilled
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                        SizedBox(width: 6),
                        Text('서명 완료', style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.draw_outlined, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('여기에 서명', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
        ),
      ),
    );
  }

  void _handleFieldTap(_SignFieldItem field) {
    setState(() => _currentStep = _fields.indexOf(field));

    if (field.type == SignFieldType.signature) {
      _showSignatureDialog(field);
    } else if (field.type == SignFieldType.date) {
      _fillDateField(field);
    } else {
      _showTextInputDialog(field);
    }
  }

  void _showSignatureDialog(_SignFieldItem field) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('서명하기', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Expanded(
                child: SignatureCanvasWidget(
                  onSignatureComplete: (data) {
                    Navigator.pop(context);
                    setState(() {
                      _filledFields[field.id] = data;
                      _advanceStep();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fillDateField(_SignFieldItem field) {
    final now = DateTime.now();
    final dateStr = '${now.year}년 ${now.month}월 ${now.day}일';
    setState(() {
      _filledFields[field.id] = dateStr;
      _advanceStep();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('날짜 입력: $dateStr'), duration: const Duration(seconds: 1)),
    );
  }

  void _showTextInputDialog(_SignFieldItem field) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(field.label),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: '${field.label}을 입력하세요'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                setState(() {
                  _filledFields[field.id] = controller.text;
                  _advanceStep();
                });
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _advanceStep() {
    for (int i = 0; i < _fields.length; i++) {
      if (!_filledFields.containsKey(_fields[i].id)) {
        setState(() => _currentStep = i);
        return;
      }
    }
  }

  Future<void> _submitSignature() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/sign/complete/${widget.token}');
    }
  }

  void _showDeclineDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('서명 거절'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('서명을 거절하시겠습니까?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: '거절 사유 (선택)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('거절'),
          ),
        ],
      ),
    );
  }

  IconData _getFieldIcon(SignFieldType type) {
    switch (type) {
      case SignFieldType.signature: return Icons.draw_outlined;
      case SignFieldType.initial: return Icons.text_fields;
      case SignFieldType.initials: return Icons.text_fields;
      case SignFieldType.date: return Icons.calendar_today_outlined;
      case SignFieldType.text: return Icons.edit_outlined;
      case SignFieldType.stamp: return Icons.circle_outlined;
      case SignFieldType.checkbox: return Icons.check_box_outline_blank;
    }
  }
}

class _SignFieldItem {
  final String id;
  final SignFieldType type;
  final String label;
  _SignFieldItem({required this.id, required this.type, required this.label});
}
