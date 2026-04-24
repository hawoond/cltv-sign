import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showText = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: logoColor,
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Center(
            child: Icon(
              Icons.draw_rounded,
              color: Colors.white,
              size: size * 0.55,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'cltv-sign',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w700,
              color: logoColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
