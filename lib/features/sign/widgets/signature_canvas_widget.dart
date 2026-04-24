import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SignatureCanvasWidget extends StatefulWidget {
  final Function(String) onSignatureComplete;
  const SignatureCanvasWidget({super.key, required this.onSignatureComplete});

  @override
  State<SignatureCanvasWidget> createState() => _SignatureCanvasWidgetState();
}

class _SignatureCanvasWidgetState extends State<SignatureCanvasWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasSignature = false;
  int _selectedTab = 0;
  final _textController = TextEditingController();
  String _selectedFont = 'style1';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildTabButton(0, '직접 서명'),
            const SizedBox(width: 8),
            _buildTabButton(1, '텍스트'),
            const SizedBox(width: 8),
            _buildTabButton(2, '이미지'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _selectedTab == 0
              ? _buildDrawTab()
              : _selectedTab == 1
                  ? _buildTextTab()
                  : _buildImageTab(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearSignature,
                child: const Text('초기화'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _hasSignature ? _confirmSignature : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                child: const Text('서명 적용', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hasSignature ? AppColors.primary.withOpacity(0.4) : AppColors.border,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onPanStart: (d) {
                  setState(() {
                    _currentStroke = [d.localPosition];
                    _hasSignature = true;
                  });
                },
                onPanUpdate: (d) {
                  setState(() => _currentStroke.add(d.localPosition));
                },
                onPanEnd: (_) {
                  setState(() {
                    if (_currentStroke.isNotEmpty) {
                      _strokes.add(List.from(_currentStroke));
                    }
                    _currentStroke = [];
                  });
                },
                child: CustomPaint(
                  painter: _SignaturePainter(strokes: _strokes, currentStroke: _currentStroke),
                  child: _strokes.isEmpty && _currentStroke.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.draw_outlined, size: 32, color: AppColors.textTertiary.withOpacity(0.5)),
                              const SizedBox(height: 8),
                              Text(
                                '여기에 서명하세요',
                                style: TextStyle(color: AppColors.textTertiary.withOpacity(0.7), fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text('마우스 또는 터치로 서명하세요', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildTextTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          onChanged: (v) => setState(() => _hasSignature = v.isNotEmpty),
          decoration: const InputDecoration(
            hintText: '이름을 입력하세요',
            prefixIcon: Icon(Icons.person_outline, size: 18),
          ),
        ),
        const SizedBox(height: 16),
        Text('서명 스타일', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFontOption('style1', FontStyle.italic, FontWeight.w400),
            const SizedBox(width: 8),
            _buildFontOption('style2', FontStyle.normal, FontWeight.w400),
            const SizedBox(width: 8),
            _buildFontOption('style3', FontStyle.normal, FontWeight.w700),
          ],
        ),
      ],
    );
  }

  Widget _buildFontOption(String id, FontStyle fontStyle, FontWeight fontWeight) {
    final isSelected = _selectedFont == id;
    final preview = _textController.text.isEmpty ? '홍길동' : _textController.text;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFont = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              preview,
              style: TextStyle(
                fontSize: 16,
                fontStyle: fontStyle,
                fontWeight: fontWeight,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageTab() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_outlined, size: 32, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text('서명 이미지를 업로드하세요', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('PNG, JPG 지원', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _hasSignature = true),
              icon: const Icon(Icons.folder_open_outlined, size: 16),
              label: const Text('파일 선택'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSignature() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _textController.clear();
      _hasSignature = false;
    });
  }

  void _confirmSignature() {
    widget.onSignatureComplete('sig_${DateTime.now().millisecondsSinceEpoch}');
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _SignaturePainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> stroke, Paint paint) {
    if (stroke.length < 2) return;
    final path = Path();
    path.moveTo(stroke[0].dx, stroke[0].dy);
    for (int i = 1; i < stroke.length - 1; i++) {
      final mid = Offset(
        (stroke[i].dx + stroke[i + 1].dx) / 2,
        (stroke[i].dy + stroke[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(stroke[i].dx, stroke[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(stroke.last.dx, stroke.last.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
