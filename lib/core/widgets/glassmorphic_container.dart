import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use surface color for the container background, different opacity for light/dark
    final containerColor = isDark ? Colors.white : theme.colorScheme.surface;
    final containerOpacity = isDark ? 0.10 : 0.45;

    // Use surface color for the border, different opacity for light/dark
    final borderColor = isDark ? Colors.white : theme.colorScheme.surface;
    final borderOpacity = isDark ? 0.2 : 0.8;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: containerColor.withAlpha((255 * containerOpacity).round()),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor.withAlpha((255 * borderOpacity).round()),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
