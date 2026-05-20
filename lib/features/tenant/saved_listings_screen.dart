import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/saved_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _savedProvider = FutureProvider<List<dynamic>>((ref) => ref.watch(savedApiProvider).list());

class SavedListingsScreen extends ConsumerWidget {
  const SavedListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(_savedProvider);

    return PageScaffold(
      title: 'Saved listings',
      body: saved.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text('No saved listings yet.', style: AppTextStyles.bodyMediumOnDark));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final m = list[i] as Map<String, dynamic>;
              final id = (m['id'] as num?)?.toInt() ?? 0;
              return GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${m['title'] ?? 'Listing'}', style: AppTextStyles.bodyMediumOnDark),
                  subtitle: Text('UGX ${m['price'] ?? '—'}', style: AppTextStyles.captionOnDark),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RouteNames.listingDetail(id)),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Sign in as tenant to view saved listings.', style: AppTextStyles.captionOnDark)),
      ),
    );
  }
}
