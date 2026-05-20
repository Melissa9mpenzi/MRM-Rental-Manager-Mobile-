import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/maintenance_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _maintProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(maintenanceApiProvider).list();
});

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_maintProvider);

    return PageScaffold(
      title: 'Maintenance',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.submitMaintenance),
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
      body: items.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text('No maintenance requests.', style: AppTextStyles.bodyMediumOnDark));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final m = list[i] as Map<String, dynamic>;
              return GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${m['title'] ?? 'Request'}', style: AppTextStyles.bodyMediumOnDark),
                    Text('Status: ${m['status'] ?? '—'}', style: AppTextStyles.captionOnDark),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Landlord maintenance list from API.', style: AppTextStyles.captionOnDark)),
      ),
    );
  }
}
