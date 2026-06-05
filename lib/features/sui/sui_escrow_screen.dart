import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/features/sui/sui_dashboard_screen.dart';

class SuiEscrowScreen extends ConsumerWidget {
  const SuiEscrowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(suiDashboardProvider);
    return dash.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
      error: (e, _) => Center(child: Text('$e')),
      data: (d) {
        final rows = (d['escrows'] as List?) ?? [];
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rows.isEmpty ? 1 : rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            if (rows.isEmpty) {
              return Text('No escrow contracts.', style: AppTextStyles.bodyMediumOnDark.copyWith(color: Colors.white54));
            }
            final e = Map<String, dynamic>.from(rows[i] as Map);
            return GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${e['contract_id']}', style: AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.w800)),
                        _badge('${e['status']}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${e['property_name']}', style: AppTextStyles.caption),
                    Text('${e['amount_sui'] ?? 0} SUI', style: AppTextStyles.headingSmallOnDark.copyWith(color: const Color(0xFF8B5CF6))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _badge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFC4B5FD))),
    );
  }
}
