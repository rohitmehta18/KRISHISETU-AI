import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_colors.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary(context);
    return GestureDetector(
      onTap: () => KrishiApp.of(context).toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: primary.withOpacity(0.1),
          border: Border.all(color: primary.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isDark ? 'Light' : 'Dark',
              style: TextStyle(
                color: primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
