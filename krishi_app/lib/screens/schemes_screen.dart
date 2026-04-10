import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/theme_toggle_button.dart';

// ── Scheme model ──────────────────────────────────────────────────────────────
class _Scheme {
  final String id;
  final String title;
  final String tagline;
  final String ministry;
  final IconData icon;
  final Color color;
  final List<_SchemePoint> points;
  final String eligibility;
  final String howToApply;

  const _Scheme({
    required this.id,
    required this.title,
    required this.tagline,
    required this.ministry,
    required this.icon,
    required this.color,
    required this.points,
    required this.eligibility,
    required this.howToApply,
  });
}

class _SchemePoint {
  final IconData icon;
  final String text;
  const _SchemePoint(this.icon, this.text);
}

const _schemes = [
  _Scheme(
    id: 'kusum',
    title: 'PM-KUSUM Scheme',
    tagline: 'Solar pump subsidy for farmers',
    ministry: 'Ministry of New & Renewable Energy',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFFCA28),
    eligibility: 'All farmers with agricultural land. Priority to small & marginal farmers.',
    howToApply: 'Apply through your State Nodal Agency (SNA) or visit pmkusum.mnre.gov.in',
    points: [
      _SchemePoint(Icons.solar_power_rounded,    'Up to 60% subsidy on solar pumps'),
      _SchemePoint(Icons.bolt_rounded,           'Reduces electricity & diesel costs'),
      _SchemePoint(Icons.water_drop_rounded,     'Reliable irrigation even in power cuts'),
      _SchemePoint(Icons.currency_rupee_rounded, 'Extra income by selling surplus power to grid'),
      _SchemePoint(Icons.eco_rounded,            'Promotes clean & green farming'),
    ],
  ),
  _Scheme(
    id: 'smksy',
    title: 'SMKSY — Per Drop More Crop',
    tagline: 'Micro irrigation & water efficiency',
    ministry: 'Ministry of Agriculture & Farmers Welfare',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF29B6F6),
    eligibility: 'All farmers. Special focus on water-scarce regions and small landholders.',
    howToApply: 'Apply via your District Agriculture Officer or pmksy.gov.in portal.',
    points: [
      _SchemePoint(Icons.shower_outlined,        'Subsidy on drip & sprinkler systems'),
      _SchemePoint(Icons.savings_rounded,        'Up to 55% subsidy for small farmers'),
      _SchemePoint(Icons.grass_rounded,          'Increases crop yield per litre of water'),
      _SchemePoint(Icons.water_outlined,         'Reduces water wastage by up to 50%'),
      _SchemePoint(Icons.agriculture_rounded,    'Covers vegetables, fruits & field crops'),
    ],
  ),
  _Scheme(
    id: 'rkvy',
    title: 'Rashtriya Krishi Vikas Yojana',
    tagline: 'Financial support & infrastructure',
    ministry: 'Ministry of Agriculture & Farmers Welfare',
    icon: Icons.account_balance_outlined,
    color: Color(0xFF66BB6A),
    eligibility: 'Farmers, FPOs, cooperatives, and state governments for agriculture projects.',
    howToApply: 'Apply through your State Agriculture Department or rkvy.nic.in.',
    points: [
      _SchemePoint(Icons.construction_rounded,   'Funds for farm infrastructure development'),
      _SchemePoint(Icons.store_rounded,          'Support for cold storage & warehousing'),
      _SchemePoint(Icons.school_rounded,         'Farmer training & skill development'),
      _SchemePoint(Icons.trending_up_rounded,    'Boosts agricultural GDP at state level'),
      _SchemePoint(Icons.handshake_rounded,      'State-level flexible implementation'),
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(gradient: AppColors.bgGradient(context)),
          ),
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  primary.withOpacity(0.07), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Govt. Schemes',
                              style: GoogleFonts.inter(
                                  fontSize: 22, fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary(context),
                                  letterSpacing: -0.5)),
                          Text('Subsidies & benefits for farmers',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSub(context))),
                        ],
                      ),
                    ),
                    const ThemeToggleButton(),
                  ]),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
                    itemCount: _schemes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) => _SchemeTile(scheme: _schemes[i]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scheme tile ───────────────────────────────────────────────────────────────
class _SchemeTile extends StatelessWidget {
  final _Scheme scheme;
  const _SchemeTile({required this.scheme});

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SchemeDetailSheet(scheme: scheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: scheme.color.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.color.withOpacity(0.35)),
              ),
              child: Icon(scheme.icon, color: scheme.color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scheme.title,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context))),
                  const SizedBox(height: 4),
                  Text(scheme.tagline,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSub(context))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: scheme.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: scheme.color.withOpacity(0.3)),
                    ),
                    child: Text('View Details',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: scheme.color)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSub(context), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────
class _SchemeDetailSheet extends StatelessWidget {
  final _Scheme scheme;
  const _SchemeDetailSheet({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0D1F14) : Colors.white;
    final primary = AppColors.primary(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: scheme.color.withOpacity(0.2)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSub(context).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: scheme.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.color.withOpacity(0.4)),
                ),
                child: Icon(scheme.icon, color: scheme.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scheme.title,
                      style: GoogleFonts.inter(
                          fontSize: 17, fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context))),
                  Text(scheme.ministry,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSub(context))),
                ],
              )),
            ]),

            const SizedBox(height: 22),

            // Benefits
            Text('Key Benefits',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: primary)),
            const SizedBox(height: 12),
            ...scheme.points.map((pt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: scheme.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(pt.icon, color: scheme.color, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(pt.text,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary(context),
                                  height: 1.4)),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 8),

            // Eligibility
            _infoBox(
              context: context,
              icon: Icons.people_outline_rounded,
              title: 'Eligibility',
              body: scheme.eligibility,
              color: const Color(0xFF66BB6A),
            ),

            const SizedBox(height: 12),

            // How to apply
            _infoBox(
              context: context,
              icon: Icons.assignment_outlined,
              title: 'How to Apply',
              body: scheme.howToApply,
              color: const Color(0xFF29B6F6),
            ),

            const SizedBox(height: 24),

            // CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [scheme.color, scheme.color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: scheme.color.withOpacity(0.3),
                    blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Center(
                child: Text('Apply Now',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 4),
            Text(body,
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSub(context),
                    height: 1.5)),
          ],
        )),
      ]),
    );
  }
}
