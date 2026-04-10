import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../services/crop_service.dart';

class CropRecommendationCard extends StatefulWidget {
  final String region;
  final bool isDark;

  const CropRecommendationCard({
    super.key,
    required this.region,
    required this.isDark,
  });

  @override
  State<CropRecommendationCard> createState() => _CropRecommendationCardState();
}

class _CropRecommendationCardState extends State<CropRecommendationCard> {
  late Future<CropRecommendationsResult> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture =
        CropService.getCropRecommendations(widget.region);
  }

  @override
  void didUpdateWidget(CropRecommendationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.region != widget.region) {
      _recommendationsFuture =
          CropService.getCropRecommendations(widget.region);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CropRecommendationsResult>(
      future: _recommendationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.recommendations.isEmpty) {
          return _buildErrorState(context, 'No recommendations available');
        }

        final result = snapshot.data!;
        return _buildRecommendationCard(context, result);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.grass_rounded,
                  color: AppColors.primary(context), size: 16),
              const SizedBox(width: 8),
              Text('Crop Recommendations',
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
              Icon(Icons.grass_rounded,
                  color: AppColors.primary(context), size: 16),
              const SizedBox(width: 8),
              Text('Crop Recommendations',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context))),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Unable to fetch recommendations',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSub(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context,
      CropRecommendationsResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grass_rounded,
                  color: AppColors.primary(context), size: 16),
              const SizedBox(width: 8),
              Text('Crop Recommendations',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context))),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(result.region,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary(context))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(result.message,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSub(context),
                  height: 1.4)),
          const SizedBox(height: 16),
          Column(
            children: result.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final crop = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index < result.recommendations.length - 1 ? 12 : 0),
                child: _buildCropTile(context, crop),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCropTile(BuildContext context, CropRecommendation crop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            crop.scoreColor.withOpacity(0.12),
            crop.scoreColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: crop.scoreColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with crop name and score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(crop.name,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: crop.scoreColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${crop.score}% • ${crop.scoreLabel}',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: crop.score / 100,
              minHeight: 5,
              backgroundColor: crop.scoreColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(crop.scoreColor),
            ),
          ),
          const SizedBox(height: 10),
          // Reasons
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: crop.reasons.map((reason) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: crop.scoreColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(reason,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black54)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Environmental ranges
          Row(
            children: [
              Expanded(
                child: _buildRangeInfo(
                  icon: Icons.thermostat,
                  label: 'Temp',
                  value: crop.tempRange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRangeInfo(
                  icon: Icons.water_drop,
                  label: 'Moisture',
                  value: crop.moistureRange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRangeInfo(
                  icon: Icons.science,
                  label: 'pH',
                  value: crop.phRange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeInfo({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white70,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: const Color(0xFF90A4AE)),
              const SizedBox(width: 4),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF90A4AE))),
            ],
          ),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }
}
