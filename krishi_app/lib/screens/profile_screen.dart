import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/auth_service.dart';
import '../services/session.dart';
import 'home_screen.dart';
import 'change_password_screen.dart';
import 'schemes_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await AuthService.fetchProfile();
      if (!mounted) return;
      setState(() { _profile = p; _loading = false; });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Could not load profile'; _loading = false; });
    }
  }

  void _logout() {
    AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const HomeScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, a, __) => screen,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 350),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(gradient: AppColors.bgGradient(context)),
          ),
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  primary.withOpacity(0.07), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── App bar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textSub(context), size: 20),
                    ),
                    Text('My Profile',
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context),
                            letterSpacing: -0.5)),
                    const Spacer(),
                    const ThemeToggleButton(),
                  ]),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: _loading
                      ? Center(child: CircularProgressIndicator(
                          color: primary, strokeWidth: 2))
                      : _error != null
                          ? _ErrorView(message: _error!, onRetry: _load)
                          : _buildBody(context, isDark, primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, Color primary) {
    final p = _profile!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
      children: [
        // ── Avatar + name ─────────────────────────────────
        Center(
          child: Column(children: [
            Container(
              width: 84, height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkGreen : Colors.white,
                border: Border.all(color: primary.withOpacity(0.4), width: 2),
                boxShadow: [BoxShadow(
                    color: primary.withOpacity(0.2), blurRadius: 20)],
              ),
              child: Icon(Icons.person_rounded, color: primary, size: 40),
            ),
            const SizedBox(height: 12),
            Text(p.name,
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context))),
            const SizedBox(height: 4),
            Text(p.email,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSub(context))),
          ]),
        ),

        const SizedBox(height: 24),

        // ── Personal info ─────────────────────────────────
        _sectionLabel('Personal Info', context),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(children: [
            _infoRow(Icons.cake_outlined,       'Age',      p.age != null ? '${p.age} years' : '—', context),
            _divider(primary),
            _infoRow(Icons.location_on_outlined,'Region',   p.region ?? '—', context),
            _divider(primary),
            _infoRow(Icons.language_outlined,   'Language', p.language ?? '—', context),
          ]),
        ),

        const SizedBox(height: 20),

        // ── Farm details ──────────────────────────────────
        _sectionLabel('Farm Details', context),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(children: [
            _infoRow(Icons.people_outline_rounded, 'Farmer Type',   p.farmerType ?? '—', context),
            _divider(primary),
            _infoRow(Icons.landscape_outlined,     'Land Size',
                p.landSize != null ? '${p.landSize} acres' : '—', context),
            _divider(primary),
            _infoRow(Icons.eco_outlined,           'Farming Type',  p.farmingType ?? '—', context),
            _divider(primary),
            _infoRow(Icons.water_outlined,         'Water Source',  p.waterSource ?? '—', context),
            _divider(primary),
            _infoRow(Icons.shower_outlined,        'Irrigation',    p.irrigationType ?? '—', context),
            _divider(primary),
            _infoRow(Icons.science_outlined,       'Uses Pesticides',
                p.usesPesticides ? 'Yes' : 'No', context),
          ]),
        ),

        // ── Crops ─────────────────────────────────────────
        if (p.crops.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionLabel('Crops Grown', context),
          const SizedBox(height: 10),
          GlassCard(
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: p.crops.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withOpacity(0.3)),
                ),
                child: Text(c, style: TextStyle(
                    fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // ── Actions ───────────────────────────────────────
        _sectionLabel('Account', context),
        const SizedBox(height: 10),

        _ActionTile(
          icon: Icons.account_balance_outlined,
          label: 'Government Schemes',
          sub: 'Subsidies & benefits for farmers',
          color: const Color(0xFF29B6F6),
          onTap: () => _navigate(const SchemesScreen()),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.lock_outline_rounded,
          label: 'Change Password',
          sub: 'Update your account password',
          color: const Color(0xFFFFCA28),
          onTap: () => _navigate(const ChangePasswordScreen()),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.logout_rounded,
          label: 'Logout',
          sub: 'Sign out of your account',
          color: const Color(0xFFEF5350),
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _sectionLabel(String label, BuildContext context) => Text(label,
      style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppColors.textSub(context), letterSpacing: 0.3));

  Widget _divider(Color primary) =>
      Divider(height: 18, color: primary.withOpacity(0.08));

  Widget _infoRow(IconData icon, String label, String value, BuildContext ctx) =>
      Row(children: [
        Icon(icon, size: 16, color: AppColors.primary(ctx)),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(fontSize: 13, color: AppColors.textSub(ctx))),
        const Spacer(),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(ctx))),
      ]);
}

// ── Action tile ───────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon, required this.label, required this.sub,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context))),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(
                  fontSize: 11, color: AppColors.textSub(context))),
            ],
          )),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textSub(context), size: 18),
        ]),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF5350), size: 44),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  color: Color(0xFFEF5350), fontSize: 14)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFEF5350).withOpacity(0.5)),
                color: const Color(0xFFEF5350).withOpacity(0.1),
              ),
              child: const Text('Retry',
                  style: TextStyle(
                      color: Color(0xFFEF5350),
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      );
}
