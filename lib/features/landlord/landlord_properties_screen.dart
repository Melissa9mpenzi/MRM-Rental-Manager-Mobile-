import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/properties_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _propertiesProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(propertiesApiProvider).list();
});

class LandlordPropertiesScreen extends ConsumerWidget {
  const LandlordPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final props = ref.watch(_propertiesProvider);

    return PageScaffold(
      title: 'My properties',
      body: props.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text('No properties yet. Add them from the web dashboard.', style: AppTextStyles.bodyMediumOnDark));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_propertiesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final p = list[i] as Map<String, dynamic>;
                return GlassPanel(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 14,
                  child: Row(
                    children: [
                      const Icon(Icons.apartment_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${p['name'] ?? 'Property'}', style: AppTextStyles.bodyMediumOnDark),
                            Text('${p['address'] ?? ''}', style: AppTextStyles.captionOnDark, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Landlord properties from /properties API', style: AppTextStyles.captionOnDark)),
      ),
    );
  }
}
