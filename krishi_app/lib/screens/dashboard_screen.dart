import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/weather_card.dart';
import '../widgets/crop_recommendation_card.dart';
import '../widgets/crop_health_card.dart';
import '../services/sensor_service.dart';
import '../services/session.dart';
import '../services/auth_service.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, this.username = 'Farmer'});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── Pump animation ────────────────────────────────────────────────────────
  late AnimationController _pumpCtrl;
  late Animation<double> _pumpPulse;

  // ── Sensor state ──────────────────────────────────────────────────────────
  SensorData? _data;
  bool _loading = true;
  bool _offline = false;
  bool _pumpLocked = false; // blocks poll from overwriting relay after toggle
  Timer? _refreshTimer;
  Timer? _pumpLockTimer;

  // ── User profile state ────────────────────────────────────────────────────
  String _userRegion = 'Unknown';
  bool _profileLoading = true;

  @override
  void initState() {
    super.initState();
    _pumpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pumpPulse = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pumpCtrl, curve: Curves.easeInOut));

    _fetchData();
    _fetchUserProfile();
    // Auto-refresh every 3 seconds
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _fetchData());
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profile = await AuthService.fetchProfile();
      if (!mounted) return;
      setState(() {
        _userRegion = profile.region ?? 'Unknown';
        _profileLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('[Dashboard] Error fetching profile: $e');
      if (!mounted) return;
      setState(() {
        _profileLoading = false;
        _userRegion = 'Unknown';
      });
    }
  }

  @override
  void dispose() {
    _pumpCtrl.dispose();
    _refreshTimer?.cancel();
    _pumpLockTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final data = await SensorService.fetchData();
      if (!mounted) return;
      setState(() {
        // If pump is locked (recently toggled), preserve the local relay state
        _data = _pumpLocked && _data != null
            ? SensorData(
                temperature: data.temperature,
                humidity:    data.humidity,
                soilPercent: data.soilPercent,
                ldrRaw:      data.ldrRaw,
                ph:          data.ph,
                waterLevel:  data.waterLevel,
                relay:       _data!.relay, // keep local value
                autoMode:    data.autoMode,
              )
            : data;
        _loading = false;
        _offline = false;
      });
    } on DeviceOfflineException {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _offline = true;
      });
    }
  }

  Future<void> _togglePump() async {
    if (_data == null) return;
    final turnOn = !_data!.relay;

    // Lock the relay field for 6 seconds so polls don't snap it back
    _pumpLocked = true;
    _pumpLockTimer?.cancel();
    _pumpLockTimer = Timer(const Duration(seconds: 6), () {
      _pumpLocked = false;
    });

    // Optimistic UI update immediately
    setState(() {
      _data = SensorData(
        temperature: _data!.temperature,
        humidity:    _data!.humidity,
        soilPercent: _data!.soilPercent,
        ldrRaw:      _data!.ldrRaw,
        ph:          _data!.ph,
        waterLevel:  _data!.waterLevel,
        relay:       turnOn,
        autoMode:    _data!.autoMode,
      );
    });

    try {
      if (turnOn) {
        await SensorService.pumpOn();
      } else {
        await SensorService.pumpOff();
      }
    } catch (_) {
      // Command failed — revert the optimistic update
      if (!mounted) return;
      setState(() {
        _data = SensorData(
          temperature: _data!.temperature,
          humidity:    _data!.humidity,
          soilPercent: _data!.soilPercent,
          ldrRaw:      _data!.ldrRaw,
          ph:          _data!.ph,
          waterLevel:  _data!.waterLevel,
          relay:       !turnOn, // revert
          autoMode:    _data!.autoMode,
        );
      });
      _pumpLocked = false;
      _pumpLockTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration:
                BoxDecoration(gradient: AppColors.bgGradient(context)),
          ),
          Positioned(
            top: -80,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  primary.withOpacity(0.08),
                  Colors.transparent
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hii, ${widget.username} 👋',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(context),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Here\'s your farm overview',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSub(context),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const ThemeToggleButton(),
                      const SizedBox(width: 8),
                      // ── Alerts button ──────────────────────
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, a, __) => const AlertsScreen(),
                            transitionsBuilder: (_, a, __, child) =>
                                FadeTransition(opacity: a, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 350),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.darkGreen
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0xFFEF5350)
                                          .withOpacity(0.25),
                                      blurRadius: 10)
                                ],
                                border: Border.all(
                                    color: const Color(0xFFEF5350)
                                        .withOpacity(0.4)),
                              ),
                              child: const Icon(
                                  Icons.notifications_rounded,
                                  color: Color(0xFFEF5350),
                                  size: 20),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEF5350),
                                ),
                                child: const Center(
                                  child: Text('3',
                                      style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ── Profile button ─────────────────────
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, a, __) =>
                                const ProfileScreen(),
                            transitionsBuilder: (_, a, __, child) =>
                                FadeTransition(opacity: a, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 350),
                          ),
                        ),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.darkGreen
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: primary.withOpacity(0.2),
                                  blurRadius: 10)
                            ],
                            border: Border.all(
                                color: primary.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.person_rounded,
                              color: primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Body ─────────────────────────────────────
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Loading state
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
                color: AppColors.primary(context), strokeWidth: 2),
            const SizedBox(height: 16),
            Text('Connecting to device...',
                style: TextStyle(
                    color: AppColors.textSub(context), fontSize: 13)),
          ],
        ),
      );
    }

    // Offline state
    if (_offline) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: const Color(0xFFEF5350), size: 48),
            const SizedBox(height: 14),
            Text('Device not connected',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF5350))),
            const SizedBox(height: 6),
            Text('Make sure the ESP32 and backend are running',
                style: TextStyle(
                    color: AppColors.textSub(context), fontSize: 12)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() => _loading = true);
                _fetchData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
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
          ],
        ),
      );
    }

    final d = _data!;
    final moisture = d.soilPercent;
    final moistureColor =
        moisture < 30 ? const Color(0xFFEF5350) : const Color(0xFF66BB6A);
    final moistureSub =
        moisture < 30 ? 'Needs water' : 'Optimal range';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      children: [
        // ── Sensor tiles ──────────────────────────────────
        _SectionLabel(label: 'Live Sensors', context: context),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.18,
          children: [
            _SensorTile(
              icon: Icons.thermostat_rounded,
              label: 'Temperature',
              value: '${d.temperature.toStringAsFixed(1)}°C',
              sub: 'Live reading',
              color: const Color(0xFFFF6B35),
            ),
            _SensorTile(
              icon: Icons.water_drop_rounded,
              label: 'Humidity',
              value: '${d.humidity.toStringAsFixed(1)}%',
              sub: 'Relative humidity',
              color: const Color(0xFF29B6F6),
            ),
            _SensorTile(
              icon: Icons.grass_rounded,
              label: 'Soil Moisture',
              value: '${d.soilPercent.toStringAsFixed(0)}%',
              sub: moistureSub,
              color: moistureColor,
            ),
            _SensorTile(
              icon: Icons.wb_sunny_rounded,
              label: 'Light Intensity',
              value: '${d.ldrRaw.toStringAsFixed(0)} lx',
              sub: 'LDR raw value',
              color: const Color(0xFFFFCA28),
            ),
            _SensorTile(
              icon: Icons.science_rounded,
              label: 'PH Value',
              value: d.ph.toStringAsFixed(2),
              sub: d.ph < 6.0
                  ? 'Acidic'
                  : d.ph > 7.5
                      ? 'Alkaline'
                      : 'Neutral',
              color: const Color(0xFFAB47BC),
            ),
            _SensorTile(
              icon: Icons.waves_rounded,
              label: 'Water Level',
              value: d.waterLevel ? 'PRESENT' : 'NOT PRESENT',
              sub: d.waterLevel ? 'Tank has water' : 'Tank empty',
              color: d.waterLevel
                  ? const Color(0xFF26C6DA)
                  : const Color(0xFFEF5350),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // ── Pump control ──────────────────────────────────
        _SectionLabel(label: 'Pump Control', context: context),
        const SizedBox(height: 10),
        _PumpControl(
          pumpOn: d.relay,
          pulseAnim: _pumpPulse,
          onToggle: _togglePump,
        ),

        const SizedBox(height: 22),

        // ── Weather forecast ──────────────────────────────
        _SectionLabel(label: 'Weather & Forecast', context: context),
        const SizedBox(height: 10),
        if (_userRegion != 'Unknown' && !_profileLoading) ...[
          WeatherCard(region: _userRegion, isDark: Theme.of(context).brightness == Brightness.dark),
          const SizedBox(height: 14),
          WeatherForecastCard(region: _userRegion, isDark: Theme.of(context).brightness == Brightness.dark),
        ] else
          const _WeatherLoadingPlaceholder(),

        const SizedBox(height: 22),

        // ── Crop Recommendations ───────────────────────────
        _SectionLabel(label: 'Crop Recommendations', context: context),
        const SizedBox(height: 10),
        if (_userRegion != 'Unknown' && !_profileLoading)
          CropRecommendationCard(
              region: _userRegion,
              isDark: Theme.of(context).brightness == Brightness.dark)
        else
          const _LoadingPlaceholder(),

        const SizedBox(height: 22),

        // ── Crop Health ───────────────────────────────────
        _SectionLabel(label: 'Crop Health', context: context),
        const SizedBox(height: 10),
        CropHealthCard(
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),

        const SizedBox(height: 22),

        const SizedBox(height: 22),

        // ── Wind direction + Crop health ──────────────────
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _WindDirectionTile()),
            SizedBox(width: 12),
            Expanded(child: _CropHealthTile()),
          ],
        ),

        const SizedBox(height: 22),

        // ── Water tank ────────────────────────────────────
        _SectionLabel(label: 'Water Tank Status', context: context),
        const SizedBox(height: 10),
        _WaterTankTile(waterPresent: d.waterLevel),

        const SizedBox(height: 36),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final BuildContext context;
  const _SectionLabel({required this.label, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textSub(ctx),
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── Sensor tile ───────────────────────────────────────────────────────────────
class _SensorTile extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final Color color;
  const _SensorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.15 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSub(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  color: AppColors.textSub(context).withOpacity(0.6),
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pump control ──────────────────────────────────────────────────────────────
class _PumpControl extends StatelessWidget {
  final bool pumpOn;
  final Animation<double> pulseAnim;
  final VoidCallback onToggle;
  const _PumpControl(
      {required this.pumpOn,
      required this.pulseAnim,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onColor = isDark ? const Color(0xFF39FF14) : const Color(0xFF1B7A3E);
    final offColor = isDark ? const Color(0xFF455A64) : const Color(0xFF90A4AE);

    return GlassCard(
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Transform.scale(
              scale: pumpOn ? pulseAnim.value : 1.0,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (pumpOn ? onColor : offColor).withOpacity(0.15),
                  border: Border.all(
                    color: (pumpOn ? onColor : offColor).withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: pumpOn
                      ? [
                          BoxShadow(
                            color: onColor.withOpacity(0.35),
                            blurRadius: 16,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  Icons.water_rounded,
                  color: pumpOn ? onColor : offColor,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Pump',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pumpOn
                      ? 'Running — irrigating field'
                      : 'Stopped — tap to start',
                  style: TextStyle(
                    fontSize: 12,
                    color: pumpOn
                        ? onColor.withOpacity(0.85)
                        : AppColors.textSub(context),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 58,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: pumpOn
                    ? onColor.withOpacity(isDark ? 0.25 : 0.2)
                    : offColor.withOpacity(0.15),
                border: Border.all(
                  color: pumpOn
                      ? onColor.withOpacity(0.6)
                      : offColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: pumpOn ? 28 : 2,
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pumpOn ? onColor : offColor,
                        boxShadow: pumpOn
                            ? [
                                BoxShadow(
                                    color: onColor.withOpacity(0.5),
                                    blurRadius: 8)
                              ]
                            : [],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather forecast tile ─────────────────────────────────────────────────────
class _WeatherLoadingPlaceholder extends StatelessWidget {
  const _WeatherLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.cloud_queue_rounded,
                  color: AppColors.primary(context), size: 16),
              const SizedBox(width: 8),
              Text('Weather Data',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context))),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: CircularProgressIndicator(
                color: AppColors.primary(context), strokeWidth: 2),
          ),
          const SizedBox(height: 16),
          Text('Loading weather data...',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSub(context))),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.grass_rounded,
                  color: AppColors.primary(context), size: 16),
              const SizedBox(width: 8),
              Text('Loading...',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context))),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: CircularProgressIndicator(
                color: AppColors.primary(context), strokeWidth: 2),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Old placeholder (kept for reference) ──────────────────────────────────────
class _WeatherForecastTile extends StatelessWidget {
  const _WeatherForecastTile();

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final days = [
      {'day': 'Today', 'icon': Icons.wb_sunny_rounded, 'high': '34°', 'low': '24°', 'color': const Color(0xFFFFCA28)},
      {'day': 'Thu', 'icon': Icons.cloud_rounded, 'high': '30°', 'low': '22°', 'color': const Color(0xFF90A4AE)},
      {'day': 'Fri', 'icon': Icons.thunderstorm_rounded, 'high': '27°', 'low': '20°', 'color': const Color(0xFF5C6BC0)},
      {'day': 'Sat', 'icon': Icons.grain_rounded, 'high': '25°', 'low': '19°', 'color': const Color(0xFF29B6F6)},
      {'day': 'Sun', 'icon': Icons.wb_sunny_rounded, 'high': '33°', 'low': '23°', 'color': const Color(0xFFFFCA28)},
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.cloud_queue_rounded, color: primary, size: 16),
            const SizedBox(width: 8),
            Text('5-Day Forecast',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primary)),
            const Spacer(),
            Text('Pune, MH',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSub(context))),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((d) {
              return Column(children: [
                Text(d['day'] as String,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSub(context))),
                const SizedBox(height: 8),
                Icon(d['icon'] as IconData,
                    color: d['color'] as Color, size: 24),
                const SizedBox(height: 8),
                Text(d['high'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context))),
                Text(d['low'] as String,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSub(context))),
              ]);
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF5C6BC0).withOpacity(0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF5C6BC0), size: 14),
              const SizedBox(width: 8),
              Text('Rain expected Friday — plan irrigation accordingly',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSub(context))),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Pesticides tile ───────────────────────────────────────────────────────────
class _PesticidesTile extends StatelessWidget {
  const _PesticidesTile();

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final items = [
      {'name': 'Chlorpyrifos', 'reason': 'Aphid control', 'urgency': 'High', 'color': const Color(0xFFEF5350)},
      {'name': 'Mancozeb', 'reason': 'Fungal prevention', 'urgency': 'Medium', 'color': const Color(0xFFFFCA28)},
      {'name': 'Neem Oil', 'reason': 'General pest repellent', 'urgency': 'Low', 'color': const Color(0xFF66BB6A)},
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.bug_report_rounded, color: primary, size: 16),
            const SizedBox(width: 8),
            Text('Pesticides Required',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primary)),
          ]),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] as String,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context))),
                          Text(item['reason'] as String,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSub(context))),
                        ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: (item['color'] as Color).withOpacity(0.3)),
                    ),
                    child: Text(item['urgency'] as String,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: item['color'] as Color)),
                  ),
                ]),
              )),
        ],
      ),
    );
  }
}

// ── Wind direction tile ───────────────────────────────────────────────────────
class _WindDirectionTile extends StatelessWidget {
  const _WindDirectionTile();

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.air_rounded, color: primary, size: 15),
            const SizedBox(width: 6),
            Text('Wind',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primary)),
          ]),
          const SizedBox(height: 16),
          Center(child: _WindCompass()),
          const SizedBox(height: 12),
          Center(
            child: Text('12 km/h · NE',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
          ),
          Center(
            child: Text('North-East',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSub(context))),
          ),
        ],
      ),
    );
  }
}

class _WindCompass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // NE = 45 degrees
    const angle = 45.0 * pi / 180;

    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: _CompassPainter(
          angle: angle,
          primary: primary,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double angle;
  final Color primary;
  final bool isDark;
  const _CompassPainter(
      {required this.angle, required this.primary, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;

    // Outer ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = primary.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Cardinal labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final dirs = {'N': Offset(cx, cy - r + 10), 'S': Offset(cx, cy + r - 4),
      'E': Offset(cx + r - 6, cy + 4), 'W': Offset(cx - r + 2, cy + 4)};
    dirs.forEach((label, pos) {
      tp.text = TextSpan(
        text: label,
        style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: primary.withOpacity(0.5)),
      );
      tp.layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    });

    // Arrow
    final arrowPaint = Paint()
      ..color = primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arrowLen = r * 0.65;
    final dx = sin(angle) * arrowLen;
    final dy = -cos(angle) * arrowLen;

    canvas.drawLine(
      Offset(cx - dx * 0.4, cy - dy * 0.4),
      Offset(cx + dx, cy + dy),
      arrowPaint,
    );

    // Center dot
    canvas.drawCircle(
      Offset(cx, cy),
      4,
      Paint()..color = primary..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) =>
      old.angle != angle || old.primary != primary;
}

// ── Crop health tile ──────────────────────────────────────────────────────────
class _CropHealthTile extends StatelessWidget {
  const _CropHealthTile();

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    const healthPct = 0.82;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.eco_rounded, color: primary, size: 15),
            const SizedBox(width: 6),
            Text('Crop Health',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primary)),
          ]),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: _ArcPainter(
                    value: healthPct, color: const Color(0xFF66BB6A)),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(healthPct * 100).toInt()}%',
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(context))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text('Good Condition',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF66BB6A))),
          ),
          Center(
            child: Text('Wheat · Rice · Maize',
                style: TextStyle(
                    fontSize: 10, color: AppColors.textSub(context))),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color color;
  const _ArcPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 6;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = color.withOpacity(0.15)
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Value arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi * value,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.value != value;
}

// ── Water tank tile ───────────────────────────────────────────────────────────
class _WaterTankTile extends StatelessWidget {
  final bool waterPresent;
  const _WaterTankTile({required this.waterPresent});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    const fillColor = Color(0xFFEF5350);
    const okColor   = Color(0xFF43A047);
    final statusColor = waterPresent ? okColor : fillColor;
    const tankH = 120.0;
    const tankW = 72.0;
    // Show a low fill when not present, full when present
    final level = waterPresent ? 0.85 : 0.12;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Row(children: [
            Icon(Icons.water_rounded, color: primary, size: 16),
            const SizedBox(width: 8),
            Text('Water Tank',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primary)),
            const Spacer(),
            // Status indicator pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: statusColor),
                ),
                const SizedBox(width: 6),
                Text(
                  waterPresent ? 'Water Present' : 'No Water',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor),
                ),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Tank + info row ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tank visual
              Column(children: [
                Text(
                  waterPresent
                      ? '${(level * 100).toInt()}%'
                      : 'Critical',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: fillColor),
                ),
                const SizedBox(height: 6),
                Container(
                  width: tankW,
                  height: tankH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: fillColor.withOpacity(0.5), width: 1.5),
                    color: fillColor.withOpacity(0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.5),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Fill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOut,
                          width: tankW,
                          height: tankH * level,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                fillColor.withOpacity(0.45),
                                fillColor.withOpacity(0.85),
                              ],
                            ),
                          ),
                        ),
                        // Water surface line
                        if (level > 0.04)
                          Positioned(
                            bottom: tankH * level - 3,
                            child: Container(
                              width: tankW,
                              height: 3,
                              color: fillColor.withOpacity(0.35),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ]),

              const SizedBox(width: 20),

              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'Level',
                      value: '${(level * 100).toInt()}%',
                      valueColor: fillColor,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Capacity',
                      value: '500 L',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Status',
                      value: waterPresent ? 'Sufficient' : 'Refill Now',
                      valueColor: statusColor,
                    ),
                    const SizedBox(height: 16),
                    if (!waterPresent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: fillColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: fillColor.withOpacity(0.35)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFEF5350), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Tank critically low!\nRefill immediately.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: fillColor,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4),
                            ),
                          ),
                        ]),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12, color: AppColors.textSub(context))),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary(context))),
      ],
    );
  }
}
