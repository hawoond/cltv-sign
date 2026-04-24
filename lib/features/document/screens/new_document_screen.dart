import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/document_provider.dart';
import '../../../data/models/document_model.dart';

class NewDocumentScreen extends StatefulWidget {
  const NewDocumentScreen({super.key});

  @override
  State<NewDocumentScreen> createState() => _NewDocumentScreenState();
}

class _NewDocumentScreenState extends State<NewDocumentScreen> {
  int _currentStep = 0;
  String? _selectedFileName;
  int? _selectedFileSize;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  final List<_ParticipantInput> _participants = [
    _ParticipantInput(),
  ];
  SendMethod _sendMethod = SendMethod.email;
  bool _isUploading = false;
  String? _message;

  final _categories = ['계약서', '동의서', '인사', '부동산', '기타'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final p in _participants) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('서명 요청 시작'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/documents'),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () => setState(() => _currentStep--),
              child: const Text('이전'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: _buildCurrentStep(),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['문서 준비', '서명자 설정', '발송 방식', '확인'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final isActive = e.key == _currentStep;
          final isCompleted = e.key < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.secondary : isActive ? AppColors.primary : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${e.key + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.textTertiary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (e.key < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted ? AppColors.secondary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      case 3: return _buildStep4();
      default: return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('문서를 준비해주세요', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('서명 받을 문서를 업로드하거나 템플릿을 선택하세요.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        _buildFileUploadArea(),
        const SizedBox(height: 24),
        AppTextField(
          label: '문서 제목',
          hint: '예: 2024년 업무 위탁 계약서',
          controller: _titleController,
          validator: (v) => v == null || v.isEmpty ? '문서 제목을 입력해주세요.' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: '설명 (선택)',
          hint: '문서에 대한 간단한 설명을 입력하세요.',
          controller: _descriptionController,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('카테고리', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) => ChoiceChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (_) => setState(() => _selectedCategory = cat),
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  color: _selectedCategory == cat ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: _selectedCategory == cat ? FontWeight.w600 : FontWeight.w400,
                ),
              )).toList(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTemplateSection(),
      ],
    );
  }

  Widget _buildFileUploadArea() {
    return GestureDetector(
      onTap: _pickFile,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        color: _selectedFileName != null ? AppColors.primary : AppColors.border,
        strokeWidth: 2,
        dashPattern: const [8, 4],
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: _selectedFileName != null ? AppColors.primaryLight : AppColors.borderLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedFileName != null
              ? Column(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName!,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFileSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(_selectedFileSize!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('파일 변경'),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '파일을 드래그하거나 클릭하여 업로드',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'PDF, DOCX, HWP, JPG, PNG 지원 · 최대 10MB',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.folder_open_outlined, size: 16),
                      label: const Text('파일 선택'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTemplateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('또는 템플릿으로 시작', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/templates'),
              child: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              '표준 근로계약서',
              'NDA 비밀유지계약서',
              '프리랜서 용역계약서',
              '개인정보 동의서',
            ].map((name) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFileName = '$name.pdf';
                    _titleController.text = name;
                  });
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('서명자를 설정해주세요', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('서명이 필요한 참여자 정보를 입력하세요.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        ..._participants.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildParticipantCard(e.key, e.value),
        )),
        OutlinedButton.icon(
          onPressed: () => setState(() => _participants.add(_ParticipantInput())),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('서명자 추가'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: '서명자에게 보낼 메시지 (선택)',
          hint: '서명 요청과 함께 전달할 메시지를 입력하세요.',
          maxLines: 4,
          onChanged: (v) => _message = v,
        ),
      ],
    );
  }

  Widget _buildParticipantCard(int index, _ParticipantInput participant) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('서명자 ${index + 1}', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              if (_participants.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.danger),
                  onPressed: () => setState(() => _participants.removeAt(index)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: '이름',
                  hint: '홍길동',
                  controller: participant.nameController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: '이메일',
                  hint: 'example@email.com',
                  controller: participant.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('발송 방식을 선택해주세요', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('서명자에게 서명 요청을 어떻게 전달할지 선택하세요.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        ...[
          _SendMethodOption(
            method: SendMethod.email,
            icon: Icons.email_outlined,
            title: '이메일',
            description: '서명자의 이메일로 서명 요청 링크를 발송합니다.',
            color: AppColors.primary,
          ),
          _SendMethodOption(
            method: SendMethod.kakao,
            icon: Icons.chat_bubble_outline,
            title: '카카오톡',
            description: '카카오톡 알림톡으로 서명 요청을 발송합니다.',
            color: const Color(0xFFFFE000),
            textColor: const Color(0xFF3A1D1D),
          ),
          _SendMethodOption(
            method: SendMethod.link,
            icon: Icons.link_outlined,
            title: '링크 서명',
            description: '전용 URL 또는 QR코드로 불특정 다수의 서명을 받습니다.',
            color: AppColors.secondary,
          ),
          _SendMethodOption(
            method: SendMethod.inPerson,
            icon: Icons.people_outline,
            title: '대면 서명',
            description: '같은 화면에서 당사자들이 직접 서명합니다.',
            color: AppColors.accent,
          ),
        ].map((opt) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSendMethodCard(opt),
        )),
      ],
    );
  }

  Widget _buildSendMethodCard(_SendMethodOption opt) {
    final isSelected = _sendMethod == opt.method;
    return GestureDetector(
      onTap: () => setState(() => _sendMethod = opt.method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: opt.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(opt.icon, color: opt.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opt.title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(opt.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Radio<SendMethod>(
              value: opt.method,
              groupValue: _sendMethod,
              onChanged: (v) => setState(() => _sendMethod = v!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('요청 내용을 확인해주세요', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('서명 요청을 발송하기 전에 내용을 확인하세요.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('문서 정보', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildInfoRow('문서 제목', _titleController.text.isEmpty ? '(미입력)' : _titleController.text),
              const SizedBox(height: 8),
              _buildInfoRow('파일명', _selectedFileName ?? '(파일 미선택)'),
              if (_selectedCategory != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow('카테고리', _selectedCategory!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('서명자 정보', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              ..._participants.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildInfoRow(
                  '서명자 ${e.key + 1}',
                  '${e.value.nameController.text.isEmpty ? "(이름 미입력)" : e.value.nameController.text} · ${e.value.emailController.text.isEmpty ? "(이메일 미입력)" : e.value.emailController.text}',
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('발송 방식', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildInfoRow('방식', _getSendMethodLabel(_sendMethod)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.accent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '서명 요청 발송 후에는 서명자 정보를 변경할 수 없습니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 3;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('이전'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isUploading ? null : () => _handleNext(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep ? AppColors.secondary : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isLastStep ? '서명 요청 발송' : '다음',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep == 0 && _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문서 제목을 입력해주세요.')),
      );
      return;
    }
    if (_currentStep == 1) {
      for (final p in _participants) {
        if (p.nameController.text.isEmpty || p.emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('모든 서명자 정보를 입력해주세요.')),
          );
          return;
        }
      }
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }
    await _submitRequest();
  }

  Future<void> _submitRequest() async {
    setState(() => _isUploading = true);
    final auth = context.read<AuthProvider>();
    final docProvider = context.read<DocumentProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final doc = await docProvider.createDocument(
      title: _titleController.text,
      ownerId: user.id,
      ownerName: user.name,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      fileName: _selectedFileName,
      fileSize: _selectedFileSize,
      category: _selectedCategory,
    );

    for (int i = 0; i < _participants.length; i++) {
      final p = _participants[i];
      await docProvider.addParticipant(
        doc.id,
        Participant(
          name: p.nameController.text,
          email: p.emailController.text,
          order: i + 1,
          sendMethod: _sendMethod,
        ),
      );
    }

    await docProvider.sendSignRequest(doc.id);

    if (mounted) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('서명 요청이 발송되었습니다.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      context.go('/documents/${doc.id}');
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'hwp', 'jpg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedFileName = file.name;
        _selectedFileSize = file.size;
        if (_titleController.text.isEmpty) {
          _titleController.text = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
        }
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getSendMethodLabel(SendMethod method) {
    switch (method) {
      case SendMethod.email: return '이메일';
      case SendMethod.kakao: return '카카오톡';
      case SendMethod.link: return '링크 서명';
      case SendMethod.inPerson: return '대면 서명';
      case SendMethod.qr: return 'QR코드';
      case SendMethod.bulk: return '대량 전송';
    }
  }
}

class _ParticipantInput {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  void dispose() {
    nameController.dispose();
    emailController.dispose();
  }
}

class _SendMethodOption {
  final SendMethod method;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color? textColor;
  _SendMethodOption({
    required this.method,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.textColor,
  });
}
