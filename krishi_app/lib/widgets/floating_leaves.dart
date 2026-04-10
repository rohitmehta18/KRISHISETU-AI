import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingLeaves extends StatefulWidget {
  const FloatingLeaves({super.key});
  @override
  State<FloatingLeaves> createState() => _FloatingLeavesState();
}

class _FloatingLeavesState extends State<FloatingLeaves> with TickerProviderStateMixin {
  final List<_LeafData> _leaves = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 14; i++) {
      _leaves.add(_LeafData(random: _random, vsync: this));
    }
  }

  @override
  void dispose() {
    for (final l in _leaves) l.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: _leaves.map((leaf) => AnimatedBuilder(
        animation: leaf.controller,
        builder: (_, __) {
          final size = MediaQuery.of(context).size;
          final x = leaf.startX * size.width + sin(leaf.controller.value * 2 * pi) * 28;
          final y = size.height - (leaf.controller.value * (size.height + 100)) + leaf.startY;
          return Positioned(
            left: x, top: y,
            child: Transform.rotate(
              angle: leaf.controller.value * 2 * pi * leaf.rotSpeed,
              child: Opacity(
                opacity: (0.12 + leaf.opacity * 0.22).clamp(0.0, 1.0),
                child: _LeafShape(size: leaf.size, isDark: isDark),
              ),
            ),
          );
        },
      )).toList(),
    );
  }
}

class _LeafData {
  late AnimationController controller;
  final double startX, startY, size, opacity, rotSpeed;
  _LeafData({required Random random, required TickerProvider vsync})
      : startX = random.nextDouble(),
        startY = random.nextDouble() * 200 - 100,
        size = 8 + random.nextDouble() * 16,
        opacity = random.nextDouble(),
        rotSpeed = 0.4 + random.nextDouble() * 1.5 {
    controller = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: 9 + random.nextInt(10)),
    )..repeat();
    controller.forward(from: random.nextDouble());
  }
  void dispose() => controller.dispose();
}

class _LeafShape extends StatelessWidget {
  final double size;
  final bool isDark;
  const _LeafShape({required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(size, size * 1.5),
    painter: _LeafPainter(isDark: isDark),
  );
}

class _LeafPainter extends CustomPainter {
  final bool isDark;
  const _LeafPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final color = isDark ? AppColors.neonGreen : AppColors.primaryLight;
    final paint = Paint()..color = color.withOpacity(0.8)..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(size.width, size.height / 2, size.width / 2, size.height)
      ..quadraticBezierTo(0, size.height / 2, size.width / 2, 0);
    canvas.drawPath(path, paint);
    final vein = Paint()
      ..color = (isDark ? Colors.black : Colors.white).withOpacity(0.3)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.1),
      Offset(size.width / 2, size.height * 0.9),
      vein,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => old.isDark != isDark;
}
