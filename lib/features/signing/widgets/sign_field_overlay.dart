import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/document_model.dart';

class SignFieldOverlay extends StatelessWidget {
  final SignField field;
  final double pageWidth;
  final double pageHeight;
  final bool isFilled;
  final VoidCallback onTap;

  const SignFieldOverlay({
    super.key,
    required this.field,
    required this.pageWidth,
    required this.pageHeight,
    required this.isFilled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final left = field.x / pageWidth * pageWidth;
    final top = field.y / pageHeight * pageHeight;
    final width = field.width;
    final height = field.height;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFilled
                ? AppColors.secondaryLight.withValues(alpha: 0.6)
                : AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isFilled ? AppColors.secondary : AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isFilled
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          field.type == SignFieldType.signature ? '서명 완료' : (field.label ?? '완료'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getFieldIcon(field.type),
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          field.label ?? _getFieldLabel(field.type),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
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

  String _getFieldLabel(SignFieldType type) {
    switch (type) {
      case SignFieldType.signature: return '서명';
      case SignFieldType.initial: return '이니셜';
      case SignFieldType.initials: return '이니셜';
      case SignFieldType.date: return '날짜';
      case SignFieldType.text: return '텍스트';
      case SignFieldType.stamp: return '도장';
      case SignFieldType.checkbox: return '체크박스';
    }
  }
}
