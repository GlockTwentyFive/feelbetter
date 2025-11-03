import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmotionIcon extends StatelessWidget {
  const EmotionIcon({super.key, required this.icon, this.paletteKey = 'teal', this.size = 28});

  final IconData icon;
  final String paletteKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final palette = tokens.emotion(paletteKey);
    final padding = (size * 0.24).clamp(6.0, 12.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.background,
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(icon, size: size, color: palette.text),
      ),
    );
  }
}
