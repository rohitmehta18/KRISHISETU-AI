import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlowingButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final double? width;
  final IconData? icon;

  const GlowingButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.width,
    this.icon,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.94,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary(context);

    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) { _controller.forward(); widget.onTap(); },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          width: widget.width ?? double.infinity,
          height: 58,
          decoration: widget.outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primary, width: 1.5),
                  color: primary.withOpacity(0.06),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: AppColors.buttonGradient(context),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(isDark ? 0.45 : 0.35),
                      blurRadius: 24,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: widget.outlined
                        ? primary
                        : (isDark ? Colors.black : Colors.white),
                    size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.outlined
                      ? primary
                      : (isDark ? Colors.black : Colors.white),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
