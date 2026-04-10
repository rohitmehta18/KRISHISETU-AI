import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/glowing_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.65, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _mainCtrl.forward();
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _navigate(Widget screen) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, a, __) => screen,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 500),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final primary = AppColors.primary(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(gradient: AppColors.bgGradient(context)),
          ),

          // ── Farmer illustration background (SVG-style painted) ──
          Positioned.fill(child: _FarmerScenePainter(isDark: isDark)),

          // ── Radial glow orb ──────────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_glowAnim, _pulseAnim]),
            builder: (_, __) => Positioned(
              top: size.height * 0.18,
              left: size.width / 2 - 160,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(0.10 * _glowAnim.value * _pulseAnim.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Floating leaves ──────────────────────────────────
          const FloatingLeaves(),

          // ── Top bar ──────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.eco_rounded, color: primary, size: 22),
                    const SizedBox(width: 8),
                    Text('Krishi', style: GoogleFonts.inter(
                      color: primary, fontSize: 17, fontWeight: FontWeight.w800,
                    )),
                  ]),
                  const ThemeToggleButton(),
                ],
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.12),

                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: primary.withOpacity(0.1),
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: primary)),
                          const SizedBox(width: 8),
                          Text('Smart Farming Platform', style: TextStyle(
                            color: primary, fontSize: 12, fontWeight: FontWeight.w600,
                          )),
                        ]),
                      ),

                      const SizedBox(height: 24),

                      // App name with glow
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (_, __) => ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF39FF14), const Color(0xFF00C853)]
                                : [const Color(0xFF1B7A3E), const Color(0xFF2ECC71)],
                          ).createShader(bounds),
                          child: Text('Krishi App',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Smart Farming for\nEvery Farmer',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: AppColors.textSub(context),
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Feature pills
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _FeaturePill(icon: Icons.wb_sunny_outlined, label: 'Weather AI', isDark: isDark),
                          _FeaturePill(icon: Icons.water_drop_outlined, label: 'Irrigation', isDark: isDark),
                          _FeaturePill(icon: Icons.bar_chart_rounded, label: 'Crop Analytics', isDark: isDark),
                          _FeaturePill(icon: Icons.notifications_outlined, label: 'Smart Alerts', isDark: isDark),
                        ],
                      ),

                      const Spacer(),

                      // Buttons
                      GlowingButton(
                        label: 'Get Started',
                        icon: Icons.arrow_forward_rounded,
                        onTap: () => _navigate(const SignupScreen()),
                      ),

                      const SizedBox(height: 14),

                      GlowingButton(
                        label: 'Login to Account',
                        outlined: true,
                        onTap: () => _navigate(const LoginScreen()),
                      ),

                      const SizedBox(height: 28),

                      // Trust line
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.verified_rounded, color: primary.withOpacity(0.5), size: 14),
                        const SizedBox(width: 6),
                        Text('Trusted by 50,000+ farmers across India',
                          style: TextStyle(
                            color: AppColors.textSub(context).withOpacity(0.6),
                            fontSize: 12, letterSpacing: 0.3,
                          ),
                        ),
                      ]),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature pill chip ────────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _FeaturePill({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: primary.withOpacity(0.08),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: primary, size: 14),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(
          color: AppColors.textSub(context),
          fontSize: 12, fontWeight: FontWeight.w500,
        )),
      ]),
    );
  }
}

// ── Farmer scene background painter ─────────────────────────────────────────
class _FarmerScenePainter extends StatelessWidget {
  final bool isDark;
  const _FarmerScenePainter({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScenePainter(isDark: isDark),
      child: const SizedBox.expand(),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final bool isDark;
  const _ScenePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final green = isDark ? const Color(0xFF39FF14) : const Color(0xFF1B7A3E);
    final accent = isDark ? const Color(0xFF00C853) : const Color(0xFF2ECC71);

    // ── Rolling hills at bottom ──────────────────────────────
    final hillPaint = Paint()
      ..color = green.withOpacity(isDark ? 0.06 : 0.09)
      ..style = PaintingStyle.fill;

    final hill1 = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.60, size.width * 0.5, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.76, size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill1, hillPaint);

    final hill2 = Paint()..color = green.withOpacity(isDark ? 0.04 : 0.06)..style = PaintingStyle.fill;
    final hillPath2 = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.74, size.width * 0.6, size.height * 0.80)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.84, size.width, size.height * 0.78)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath2, hill2);

    // ── Crop rows (horizontal lines suggesting fields) ───────
    final cropPaint = Paint()
      ..color = accent.withOpacity(isDark ? 0.05 : 0.07)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final y = size.height * (0.68 + i * 0.04);
      final path = Path()
        ..moveTo(size.width * 0.05, y)
        ..lineTo(size.width * 0.95, y);
      canvas.drawPath(path, cropPaint);
    }

    // ── Stylised farmer silhouette (bottom right) ────────────
    _drawFarmerSilhouette(canvas, size, green.withOpacity(isDark ? 0.07 : 0.10));

    // ── Sun / moon orb (top left) ────────────────────────────
    final orbPaint = Paint()
      ..color = green.withOpacity(isDark ? 0.05 : 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.14), 60, orbPaint);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.14), 40,
        Paint()..color = green.withOpacity(isDark ? 0.04 : 0.06)..style = PaintingStyle.fill);

    // ── Decorative grid dots (top right) ─────────────────────
    final dotPaint = Paint()..color = green.withOpacity(isDark ? 0.08 : 0.10)..style = PaintingStyle.fill;
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        canvas.drawCircle(
          Offset(size.width * 0.78 + c * 18.0, size.height * 0.08 + r * 18.0),
          2, dotPaint,
        );
      }
    }
  }

  void _drawFarmerSilhouette(Canvas canvas, Size size, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final cx = size.width * 0.82;
    final cy = size.height * 0.70;

    // Head
    canvas.drawCircle(Offset(cx, cy - 52), 14, paint);

    // Hat (wide brim)
    final hat = Path()
      ..moveTo(cx - 22, cy - 52)
      ..lineTo(cx + 22, cy - 52)
      ..lineTo(cx + 14, cy - 66)
      ..lineTo(cx - 14, cy - 66)
      ..close();
    canvas.drawPath(hat, paint);

    // Body
    final body = Path()
      ..moveTo(cx - 12, cy - 38)
      ..lineTo(cx + 12, cy - 38)
      ..lineTo(cx + 10, cy)
      ..lineTo(cx - 10, cy)
      ..close();
    canvas.drawPath(body, paint);

    // Left arm (holding tool)
    final lArm = Path()
      ..moveTo(cx - 12, cy - 30)
      ..lineTo(cx - 28, cy - 10)
      ..lineTo(cx - 24, cy - 8)
      ..lineTo(cx - 8, cy - 28)
      ..close();
    canvas.drawPath(lArm, paint);

    // Tool (hoe)
    canvas.drawRect(Rect.fromLTWH(cx - 32, cy - 14, 3, 30), paint);
    canvas.drawRect(Rect.fromLTWH(cx - 40, cy - 14, 18, 4), paint);

    // Legs
    canvas.drawRect(Rect.fromLTWH(cx - 10, cy, 8, 28), paint);
    canvas.drawRect(Rect.fromLTWH(cx + 2, cy, 8, 28), paint);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.isDark != isDark;
}
