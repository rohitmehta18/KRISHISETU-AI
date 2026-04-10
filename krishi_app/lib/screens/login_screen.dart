import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      final result = await AuthService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, a, __) => DashboardScreen(username: result.name),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ));
    } on AuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Could not connect to server'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary(context);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(gradient: AppColors.bgGradient(context)),
          ),

          // Decorative orb
          Positioned(top: -80, right: -60,
            child: Container(width: 240, height: 240,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [primary.withOpacity(0.08), Colors.transparent])))),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textSub(context), size: 20),
                          ),
                          const Spacer(),
                          const ThemeToggleButton(),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),

                              Center(
                                child: Container(
                                  width: 76, height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppColors.darkGreen : Colors.white,
                                    boxShadow: [BoxShadow(
                                      color: primary.withOpacity(0.25),
                                      blurRadius: 28, spreadRadius: 2,
                                    )],
                                    border: Border.all(color: primary.withOpacity(0.35)),
                                  ),
                                  child: Icon(Icons.eco_rounded, color: primary, size: 36),
                                ),
                              ),

                              const SizedBox(height: 28),

                              Text('Welcome back', style: GoogleFonts.inter(
                                fontSize: 32, fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary(context), letterSpacing: -0.8,
                              )),
                              const SizedBox(height: 6),
                              Text('Sign in to your Krishi account', style: GoogleFonts.inter(
                                fontSize: 15, color: AppColors.textSub(context),
                              )),

                              const SizedBox(height: 32),

                              GlassCard(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: AppColors.textPrimary(context)),
                                      decoration: InputDecoration(
                                        labelText: 'Email / Phone',
                                        prefixIcon: const Icon(Icons.person_outline_rounded),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: false,
                                      ),
                                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                                    ),
                                    Divider(height: 1, color: primary.withOpacity(0.1)),
                                    TextFormField(
                                      controller: _passCtrl,
                                      obscureText: _obscure,
                                      style: TextStyle(color: AppColors.textPrimary(context)),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                            color: AppColors.textSub(context), size: 20,
                                          ),
                                          onPressed: () => setState(() => _obscure = !_obscure),
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: false,
                                      ),
                                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text('Forgot Password?',
                                    style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Error message
                              if (_error != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF5350).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEF5350).withOpacity(0.4)),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.error_outline_rounded, color: Color(0xFFEF5350), size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_error!,
                                      style: const TextStyle(color: Color(0xFFEF5350), fontSize: 13))),
                                  ]),
                                ),
                                const SizedBox(height: 16),
                              ],

                              GlowingButton(
                                label: _loading ? 'Logging in...' : 'Login',
                                icon: Icons.login_rounded,
                                onTap: _loading ? () {} : _login,
                              ),

                              const SizedBox(height: 28),

                              Center(child: Text("Don't have an account?  Sign up",
                                style: TextStyle(color: AppColors.textSub(context).withOpacity(0.7), fontSize: 13))),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
