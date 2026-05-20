import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

/// Simple horizontal set of bars — monthly revenue / volume.
class DashboardBarChart extends StatelessWidget {
  const DashboardBarChart({
    super.key,
    required this.labels,
    required this.values,
    this.barColor = AppColors.accentGreen,
    this.height = 120,
  });

  final List<String> labels;
  final List<double> values;
  final Color barColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty || values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('No chart data yet', style: AppTextStyles.captionOnDark)),
      );
    }
    final maxV = values.fold<double>(0, (a, b) => math.max(a, b));
    final denom = maxV <= 0 ? 1.0 : maxV;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(labels.length, (i) {
          final v = i < values.length ? values[i] : 0.0;
          final frac = (v / denom).clamp(0.08, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: frac,
                        widthFactor: 0.72,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: barColor.withOpacity(0.85),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.captionOnDark.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
