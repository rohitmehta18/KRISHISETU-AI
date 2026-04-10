import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../services/crop_health_service.dart';

class CropHealthCard extends StatefulWidget {
  final bool isDark;

  const CropHealthCard({
    super.key,
    required this.isDark,
  });

  @override
  State<CropHealthCard> createState() => _CropHealthCardState();
}

class _CropHealthCardState extends State<CropHealthCard> {
  late Future<CropHealthReport> _healthFuture;

  @override
  void initState() {
    super.initState();
    _healthFuture = CropHealthService.getCropHealth();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CropHealthReport>(
      future: _healthFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildErrorState(context, 'No health data available');
        }

        final health = snapshot.data!;
        return _buildHealthCard(context, health);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded,
                  color: AppColors.primary(context), size: 16),
              const SizedBox(width: 8),
              Text('Crop Health',
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

  Widget _buildErrorState(BuildContext context, String error) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded,
                  color: AppColors.primary(context), size: 16),
              const SizedBox(width: 8),
              Text('Crop Health',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context))),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Unable to fetch health data',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSub(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, CropHealthReport health) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(health.statusIcon,
                  color: health.statusColor, size: 18),
              const SizedBox(width: 8),
              Text('Crop Health Status',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context))),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: health.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: health.statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(health.healthStatus,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: health.statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overall Score
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  health.statusColor.withOpacity(0.12),
                  health.statusColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: health.statusColor.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: health.overallScore / 100,
                        strokeWidth: 4,
                        backgroundColor: health.statusColor.withOpacity(0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(health.statusColor),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${health.overallScore}%',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: health.statusColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overall Health',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSub(context))),
                      const SizedBox(height: 4),
                      Text(
                          health.overallScore >= 85
                              ? 'Crop is thriving'
                              : health.overallScore >= 70
                                  ? 'Crop is healthy'
                                  : health.overallScore >= 50
                                      ? 'Needs attention'
                                      : 'Critical issues detected',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Health Metrics Grid
          Text('Health Metrics',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
            children: health.metrics.entries.map((entry) {
              final name = entry.key;
              final metric = entry.value;
              return _buildMetricTile(context, name, metric);
            }).toList(),
          ),

          // Critical Alerts
          if (health.criticalAlerts.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFEF5350).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: Color(0xFFEF5350), size: 16),
                      const SizedBox(width: 8),
                      Text('⚠️ Critical Alerts',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEF5350))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: health.criticalAlerts
                        .map((alert) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('• ${alert.recommendation}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],

          // Improvements
          if (health.improvements.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded,
                          color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text('💡 Recommended Actions',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: health.improvements
                        .map((imp) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${imp.parameter}: ',
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87)),
                                  Expanded(
                                    child: Text(imp.recommendation,
                                        style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54)),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile(
      BuildContext context, String name, HealthMetric metric) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = name.replaceFirst(name[0], name[0].toUpperCase());

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            metric.statusColor.withOpacity(0.12),
            metric.statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: metric.statusColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayName,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: metric.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(metric.displayScore,
                    style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: metric.statusColor)),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: metric.score / 100,
              minHeight: 3,
              backgroundColor: metric.statusColor.withOpacity(0.2),
              valueColor:
                  AlwaysStoppedAnimation<Color>(metric.statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
