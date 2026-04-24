import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/providers/document_provider.dart';
import '../../../data/models/document_model.dart';
import '../widgets/signature_canvas.dart';
import '../widgets/sign_field_overlay.dart';

class SigningScreen extends StatefulWidget {
  final String documentId;
  const SigningScreen({super.key, required this.documentId});

  @override
  State<SigningScreen> createState() => _SigningScreenState();
}

class _SigningScreenState extends State<SigningScreen> {
  int _currentPage = 1;
  int _totalPages = 3;
  bool _isCompleting = false;
  bool _agreedToTerms = false;
  final List<_SignField> _signFields = [
    _SignField(id: 'sig1', type: SignFieldType.signature, page: 1, x: 0.1, y: 0.7, width: 0.4, height: 0.08, label: '서명'),
    _SignField(id: 'date1', type: SignFieldType.date, page: 1, x: 0.6, y: 0.7, width: 0.3, height: 0.04, label: '날짜'),
    _SignField(id: 'text1', type: SignFieldType.text, page: 2, x: 0.1, y: 0.3, width: 0.5, height: 0.04, label: '성명'),
    _SignField(id: 'sig2', type: SignFieldType.signature, page: 3, x: 0.1, y: 0.85, width: 0.4, height: 0.08, label: '최종 서명'),
  ];
  final Map<String, dynamic> _fieldValues = {};

  List<_SignField> get _currentPageFields =>
      _signFields.where((f) => f.page == _currentPage).toList();

  bool get _allRequiredFieldsFilled =>
      _signFields.every((f) => _fieldValues.containsKey(f.id));

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();
    final doc = docProvider.getDocumentById(widget.documentId);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF374151),
      appBar: AppBar(
        backgroundColor: AppColors.textPrimary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const AppLogo(size: 24, color: Colors.white),
            const SizedBox(width: 8),
            const Text('cltv-sign', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            if (doc != null) ...[
              const SizedBox(width: 16),
              const Text('|', style: TextStyle(color: Colors.white38)),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  doc.title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$_currentPage / $_totalPages 페이지',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
        automaticallyImplyLeading: false,
      ),
      body: isWide
          ? Row(
              children: [
                _buildSidePanel(doc),
                Expanded(child: _buildDocumentViewer()),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildDocumentViewer()),
                _buildMobileBottomPanel(doc),
              ],
            ),
    );
  }

  Widget _buildSidePanel(Document? doc) {
    return Container(
      width: 280,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('서명 진행', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${_fieldValues.length}/${_signFields.length} 항목 완료',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ProgressBar(
                  value: _signFields.isEmpty ? 0 : _fieldValues.length / _signFields.length,
                  color: AppColors.secondary,
                  height: 6,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text('서명 항목', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                ..._signFields.map((f) => _buildFieldListItem(f)),
                const SizedBox(height: 16),
                Text('페이지 이동', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                ...List.generate(_totalPages, (i) => _buildPageItem(i + 1)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCompleteButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldListItem(_SignField field) {
    final isFilled = _fieldValues.containsKey(field.id);
    final isCurrentPage = field.page == _currentPage;
    return GestureDetector(
      onTap: () => setState(() => _currentPage = field.page),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentPage ? AppColors.primaryLight : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentPage ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isFilled ? Icons.check_circle : _getFieldIcon(field.type),
              size: 16,
              color: isFilled ? AppColors.secondary : isCurrentPage ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isFilled ? AppColors.secondary : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${field.page}페이지',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!isFilled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '필수',
                  style: TextStyle(fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageItem(int page) {
    final isActive = page == _currentPage;
    return GestureDetector(
      onTap: () => setState(() => _currentPage = page),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Text(
              '$page 페이지',
              style: TextStyle(
                fontSize: 13,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentViewer() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildDocumentPage(),
                  ),
                ),
              ),
            ),
            _buildPageNavigation(),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = (constraints.maxWidth - 40).clamp(300.0, 800.0);
        final pageHeight = pageWidth * 1.414;

        return Container(
          width: pageWidth,
          height: pageHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildPageContent(pageWidth, pageHeight),
              ..._currentPageFields.map((f) => SignFieldOverlay(
                field: f.toSignField(),
                pageWidth: pageWidth,
                pageHeight: pageHeight,
                isFilled: _fieldValues.containsKey(f.id),
                onTap: () => _handleFieldTap(f),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageContent(double width, double height) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '업무 위탁 계약서',
              style: TextStyle(
                fontSize: width * 0.03,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: height * 0.04),
          if (_currentPage == 1) ...[
            _buildDocLine(width, '제1조 (목적)'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '본 계약은 "갑"이 "을"에게 위탁하는 업무의 범위, 조건 및 절차를 규정함을 목적으로 한다.'),
            SizedBox(height: height * 0.02),
            _buildDocLine(width, '제2조 (위탁 업무의 범위)'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '"갑"이 "을"에게 위탁하는 업무의 범위는 다음과 같다.'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '1. 소프트웨어 개발 및 유지보수\n2. 기술 지원 및 컨설팅\n3. 기타 "갑"이 지정하는 업무'),
            SizedBox(height: height * 0.02),
            _buildDocLine(width, '제3조 (계약 기간)'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '본 계약의 기간은 계약 체결일로부터 1년으로 한다.'),
          ] else if (_currentPage == 2) ...[
            _buildDocLine(width, '제4조 (위탁 수수료)'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '"갑"은 "을"에게 위탁 업무에 대한 수수료를 지급한다.'),
            SizedBox(height: height * 0.02),
            _buildDocLine(width, '제5조 (비밀 유지)'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '"을"은 본 계약의 이행 과정에서 알게 된 "갑"의 영업 비밀 및 기술 정보를 제3자에게 누설하거나 본 계약 이외의 목적으로 사용하여서는 아니 된다.'),
            SizedBox(height: height * 0.02),
            _buildDocLine(width, '제6조 (손해 배상)'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '당사자 일방이 본 계약을 위반하여 상대방에게 손해를 입힌 경우, 그 손해를 배상하여야 한다.'),
          ] else ...[
            _buildDocLine(width, '제7조 (계약의 해지)'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '당사자 일방은 상대방이 본 계약을 위반한 경우 서면으로 통지하고 계약을 해지할 수 있다.'),
            SizedBox(height: height * 0.02),
            _buildDocLine(width, '제8조 (분쟁 해결)'),
            SizedBox(height: height * 0.01),
            _buildDocParagraph(width, '본 계약과 관련하여 분쟁이 발생한 경우, 당사자 간의 협의로 해결하며, 협의가 이루어지지 않을 경우 관할 법원에 소를 제기할 수 있다.'),
            SizedBox(height: height * 0.04),
            Center(
              child: Text(
                '2024년 1월 1일',
                style: TextStyle(fontSize: width * 0.022, color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocLine(double width, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: width * 0.022,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDocParagraph(double width, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: width * 0.019,
        color: AppColors.textSecondary,
        height: 1.7,
      ),
    );
  }

  Widget _buildPageNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFF1F2937),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          ),
          const SizedBox(width: 8),
          Text(
            '$_currentPage / $_totalPages',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _currentPage < _totalPages ? () => setState(() => _currentPage++) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomPanel(Document? doc) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ProgressBar(
                  value: _signFields.isEmpty ? 0 : _fieldValues.length / _signFields.length,
                  color: AppColors.secondary,
                  height: 6,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_fieldValues.length}/${_signFields.length}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCompleteButton(),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _allRequiredFieldsFilled && !_isCompleting ? _showCompletionDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          disabledBackgroundColor: AppColors.border,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _isCompleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                _allRequiredFieldsFilled ? '서명 완료' : '${_signFields.length - _fieldValues.length}개 항목 남음',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
      ),
    );
  }

  void _handleFieldTap(_SignField field) {
    if (field.type == SignFieldType.signature) {
      _showSignatureDialog(field);
    } else if (field.type == SignFieldType.date) {
      setState(() {
        final now = DateTime.now();
        _fieldValues[field.id] = '${now.year}년 ${now.month}월 ${now.day}일';
      });
    } else if (field.type == SignFieldType.text) {
      _showTextInputDialog(field);
    } else if (field.type == SignFieldType.stamp) {
      setState(() => _fieldValues[field.id] = 'stamp');
    } else if (field.type == SignFieldType.initials) {
      _showSignatureDialog(field);
    }
  }

  void _showSignatureDialog(_SignField field) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('서명하기', style: Theme.of(context).textTheme.headlineSmall),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SignatureCanvas(
                onSignatureComplete: (signatureData) {
                  setState(() => _fieldValues[field.id] = signatureData);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTextInputDialog(_SignField field) {
    final controller = TextEditingController(
      text: _fieldValues[field.id]?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(field.label),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: '${field.label}을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _fieldValues[field.id] = controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('서명을 완료하시겠습니까?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서명 완료 후에는 수정이 불가능합니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              title: const Text(
                '전자서명법에 따라 본인이 직접 서명하였음을 확인합니다.',
                style: TextStyle(fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          StatefulBuilder(
            builder: (context, setDialogState) => ElevatedButton(
              onPressed: _agreedToTerms
                  ? () {
                      Navigator.pop(context);
                      _completeSign();
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: const Text('서명 완료'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSign() async {
    setState(() => _isCompleting = true);
    final docProvider = context.read<DocumentProvider>();
    await Future.delayed(const Duration(seconds: 2));
    await docProvider.submitSignature(
      documentId: widget.documentId,
      participantId: 'p-001',
      signatureData: 'sig_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (mounted) {
      setState(() => _isCompleting = false);
      context.go('/sign-complete/${widget.documentId}');
    }
  }

  IconData _getFieldIcon(SignFieldType type) {
    switch (type) {
      case SignFieldType.signature: return Icons.draw_outlined;
      case SignFieldType.initials: return Icons.text_fields;
      case SignFieldType.initial: return Icons.text_fields;
      case SignFieldType.date: return Icons.calendar_today_outlined;
      case SignFieldType.text: return Icons.edit_outlined;
      case SignFieldType.stamp: return Icons.circle_outlined;
      case SignFieldType.checkbox: return Icons.check_box_outline_blank;
    }
  }
}

class _SignField {
  final String id;
  final SignFieldType type;
  final int page;
  final double x;
  final double y;
  final double width;
  final double height;
  final String label;
  _SignField({
    required this.id,
    required this.type,
    required this.page,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
  });

  SignField toSignField() => SignField(
    id: id,
    type: type,
    x: x,
    y: y,
    width: width,
    height: height,
    pageIndex: page,
    participantId: 'current_user',
    label: label,
  );
}
