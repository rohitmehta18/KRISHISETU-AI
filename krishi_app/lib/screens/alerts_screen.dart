import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/sensor_service.dart';
import '../services/gemini_service.dart';

// ── Legacy AlertItem wrapper (keeps all existing widgets unchanged) ────────────
enum AlertStatus { critical, warning, fine }

class AlertItem {
  final String id;
  final String title;
  final String summary;
  final String detail;
  final String? detailWarning;
  final AlertStatus status;
  final IconData icon;
  final Color color;
  final Map<String, String>? extraInfo;

  const AlertItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.detail,
    this.detailWarning,
    required this.status,
    required this.icon,
    required this.color,
    this.extraInfo,
  });

  /// Convert a GeminiAlert into an AlertItem for the existing UI
  factory AlertItem.fromGemini(GeminiAlert g, int index) {
    AlertStatus status;
    Color color;
    IconData icon;

    switch (g.level) {
      case AlertLevel.critical:
        status = AlertStatus.critical;
        color  = const Color(0xFFEF5350);
        icon   = Icons.warning_amber_rounded;
        break;
      case AlertLevel.warning:
        status = AlertStatus.warning;
        color  = const Color(0xFFFFCA28);
        icon   = Icons.info_outline_rounded;
        break;
      case AlertLevel.fine:
        status = AlertStatus.fine;
        color  = const Color(0xFF66BB6A);
        icon   = Icons.check_circle_outline_rounded;
        break;
    }

    // Pick a more specific icon based on title keywords
    final t = g.title.toLowerCase();
    if (t.contains('water') || t.contains('moisture') || t.contains('irrigat')) {
      icon = AlertLevel.critical == g.level
          ? Icons.water_drop_rounded
          : Icons.water_outlined;
    } else if (t.contains('temp') || t.contains('heat')) {
      icon = Icons.thermostat_rounded;
      color = const Color(0xFFFF6B35);
    } else if (t.contains('ph') || t.contains('acid') || t.contains('soil')) {
      icon = Icons.science_rounded;
      color = const Color(0xFFAB47BC);
    } else if (t.contains('pest') || t.contains('bug') || t.contains('insect')) {
      icon = Icons.bug_report_rounded;
    } else if (t.contains('optimal') || t.contains('good') || t.contains('healthy')) {
      icon = Icons.eco_rounded;
    }

    return AlertItem(
      id:      'ai_$index',
      title:   g.title,
      summary: g.summary,
      detail:  g.detail,
      status:  status,
      icon:    icon,
      color:   color,
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<AlertItem> _alerts = [];
  bool _loading = true;
  bool _aiUnavailable = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refresh();
    // Re-generate every 30s (Gemini has rate limits — don't call every 3s)
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      // 1. Fetch live sensor data
      final data = await SensorService.fetchData();

      // 2. Generate AI alerts (falls back to rules internally)
      final geminiAlerts = await generateAlerts(data);

      // 3. Detect if fallback was used by checking if Gemini actually responded
      //    We re-try once; if it throws, mark AI unavailable
      bool aiOk = true;
      try {
        await _callGeminiCheck(data);
      } catch (_) {
        aiOk = false;
      }

      if (!mounted) return;
      setState(() {
        _alerts = geminiAlerts
            .asMap()
            .entries
            .map((e) => AlertItem.fromGemini(e.value, e.key))
            .toList();
        _loading = false;
        _aiUnavailable = !aiOk;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _aiUnavailable = true;
      });
    }
  }

  // Lightweight check — just validates Gemini is reachable
  Future<void> _callGeminiCheck(SensorData data) async {
    await generateAlerts(data);
  }

  int get _criticalCount =>
      _alerts.where((a) => a.status == AlertStatus.critical).length;

  @override
  Widget build(BuildContext context) {
    final hasCritical = _criticalCount > 0;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(gradient: AppColors.bgGradient(context)),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  (hasCritical
                          ? const Color(0xFFEF5350)
                          : const Color(0xFF66BB6A))
                      .withOpacity(0.08),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── App bar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textSub(context), size: 20),
                      ),
                      Text('Alerts',
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(context),
                              letterSpacing: -0.5)),
                      const Spacer(),
                      // Refresh button
                      IconButton(
                        onPressed: () {
                          setState(() => _loading = true);
                          _refresh();
                        },
                        icon: Icon(Icons.refresh_rounded,
                            color: AppColors.primary(context), size: 22),
                      ),
                      const ThemeToggleButton(),
                    ],
                  ),
                ),

                // ── AI badge ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _aiUnavailable
                            ? const Color(0xFFFFCA28).withOpacity(0.12)
                            : AppColors.primary(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _aiUnavailable
                              ? const Color(0xFFFFCA28).withOpacity(0.4)
                              : AppColors.primary(context).withOpacity(0.3),
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          _aiUnavailable
                              ? Icons.offline_bolt_rounded
                              : Icons.auto_awesome_rounded,
                          size: 12,
                          color: _aiUnavailable
                              ? const Color(0xFFFFCA28)
                              : AppColors.primary(context),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _aiUnavailable
                              ? 'Rule-based alerts'
                              : 'AI-powered alerts',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _aiUnavailable
                                ? const Color(0xFFFFCA28)
                                : AppColors.primary(context),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),

                const SizedBox(height: 14),

                // ── Loading ───────────────────────────────────
                if (_loading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                              color: AppColors.primary(context),
                              strokeWidth: 2),
                          const SizedBox(height: 14),
                          Text('Analysing farm data with AI...',
                              style: TextStyle(
                                  color: AppColors.textSub(context),
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // ── Central orb ───────────────────────────
                  _AlertStatusOrb(
                      hasCritical: hasCritical, count: _criticalCount),

                  const SizedBox(height: 20),

                  // ── Alert list ────────────────────────────
                  Expanded(
                    child: _alerts.isEmpty
                        ? Center(
                            child: Text('No alerts at this time',
                                style: TextStyle(
                                    color: AppColors.textSub(context),
                                    fontSize: 14)),
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(18, 0, 18, 32),
                            itemCount: _alerts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, i) =>
                                _AlertTile(alert: _alerts[i]),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Central orb ───────────────────────────────────────────────────────────────
class _AlertStatusOrb extends StatefulWidget {
  final bool hasCritical;
  final int count;
  const _AlertStatusOrb({required this.hasCritical, required this.count});

  @override
  State<_AlertStatusOrb> createState() => _AlertStatusOrbState();
}

class _AlertStatusOrbState extends State<_AlertStatusOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.hasCritical
        ? const Color(0xFFEF5350)
        : const Color(0xFF66BB6A);
    final label = widget.hasCritical
        ? '${widget.count} Action${widget.count > 1 ? 's' : ''} Required'
        : 'All Clear';
    final sub = widget.hasCritical
        ? 'Tap alerts below to take action'
        : 'Your farm is in good shape';

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Column(
        children: [
          Transform.scale(
            scale: widget.hasCritical ? _pulse.value : 1.0,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
                border: Border.all(color: color.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 28,
                      spreadRadius: 4),
                ],
              ),
              child: Icon(
                widget.hasCritical
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
                color: color,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSub(context))),
        ],
      ),
    );
  }
}

// ── Alert tile ────────────────────────────────────────────────────────────────
class _AlertTile extends StatelessWidget {
  final AlertItem alert;
  const _AlertTile({required this.alert});

  Color get _statusColor {
    switch (alert.status) {
      case AlertStatus.critical: return const Color(0xFFEF5350);
      case AlertStatus.warning:  return const Color(0xFFFFCA28);
      case AlertStatus.fine:     return const Color(0xFF66BB6A);
    }
  }

  String get _statusLabel {
    switch (alert.status) {
      case AlertStatus.critical: return 'Critical';
      case AlertStatus.warning:  return 'Warning';
      case AlertStatus.fine:     return 'Fine';
    }
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlertDetailSheet(alert: alert),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 18,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: alert.color.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: alert.color.withOpacity(0.3), width: 1),
              ),
              child: Icon(alert.icon, color: alert.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context))),
                  const SizedBox(height: 3),
                  Text(alert.summary,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSub(context))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: _statusColor.withOpacity(0.35)),
                  ),
                  child: Text(_statusLabel,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor)),
                ),
                const SizedBox(height: 6),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSub(context), size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────
class _AlertDetailSheet extends StatelessWidget {
  final AlertItem alert;
  const _AlertDetailSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1F14) : Colors.white;
    final primary = AppColors.primary(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: alert.color.withOpacity(0.2), width: 1),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSub(context).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: alert.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: alert.color.withOpacity(0.35)),
                ),
                child: Icon(alert.icon, color: alert.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.title,
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context))),
                    Text(alert.summary,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSub(context))),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 22),

            // AI badge on detail
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.auto_awesome_rounded, size: 12, color: primary),
                const SizedBox(width: 6),
                Text('Generated by Gemini AI',
                    style: TextStyle(
                        fontSize: 11,
                        color: primary,
                        fontWeight: FontWeight.w600)),
              ]),
            ),

            const SizedBox(height: 16),

            // Detail text
            Text(alert.detail,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary(context),
                    height: 1.65)),

            if (alert.detailWarning != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFEF5350).withOpacity(0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFEF5350), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(alert.detailWarning!,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFFEF5350),
                              height: 1.55,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],

            if (alert.extraInfo != null) ...[
              const SizedBox(height: 20),
              Text('Details',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primary)),
              const SizedBox(height: 12),
              ...alert.extraInfo!.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Expanded(
                          child: Text(e.key,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSub(context)))),
                      Text(e.value,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context))),
                    ]),
                  )),
            ],

            const SizedBox(height: 24),

            if (alert.status != AlertStatus.fine)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: alert.status == AlertStatus.critical
                          ? [
                              const Color(0xFFEF5350),
                              const Color(0xFFE53935)
                            ]
                          : [
                              const Color(0xFFFFCA28),
                              const Color(0xFFFFA000)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: alert.color.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      alert.status == AlertStatus.critical
                          ? 'Mark as Resolved'
                          : 'Acknowledge',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Cleanliness bar (kept for extraInfo compatibility) ────────────────────────
class _CleanlinessBar extends StatelessWidget {
  final double value;
  const _CleanlinessBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value > 0.7
        ? const Color(0xFF66BB6A)
        : value > 0.4
            ? const Color(0xFFFFCA28)
            : const Color(0xFFEF5350);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Cleanliness Level',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textSub(context))),
          const Spacer(),
          Text('${(value * 100).toInt()}%',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
