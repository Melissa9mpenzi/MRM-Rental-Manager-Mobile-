import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/notifications_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final notificationsListProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(notificationsApiProvider).list();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsListProvider);

    return PageScaffold(
      title: 'Notifications',
      body: items.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text('No notifications.', style: AppTextStyles.bodyMediumOnDark));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = list[i] as Map<String, dynamic>;
              return GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: AppColors.forestTeal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${n['title'] ?? n['message'] ?? 'Notification'}', style: AppTextStyles.bodyMediumOnDark),
                          if (n['body'] != null)
                            Text('${n['body']}', style: AppTextStyles.captionOnDark),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (_, __) => Center(child: Text('Could not load notifications.', style: AppTextStyles.captionOnDark)),
      ),
    );
  }
}
