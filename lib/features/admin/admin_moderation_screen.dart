import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/api/workspace_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _pendingUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  final all = await ref.watch(workspaceApiProvider).adminUsers(role: 'landlord');
  final agents = await ref.watch(workspaceApiProvider).adminUsers(role: 'staff');
  return [...all, ...agents].where((u) {
    final m = u as Map<String, dynamic>;
    return m['kyc_review_status'] == 'pending';
  }).toList();
});

class AdminModerationScreen extends ConsumerWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(_pendingUsersProvider);

    return PageScaffold(
      title: 'User moderation',
      body: users.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text('No pending KYC reviews.', style: AppTextStyles.bodyMediumOnDark));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final u = list[i] as Map<String, dynamic>;
              final id = (u['id'] as num).toInt();
              return GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${u['full_name']}', style: AppTextStyles.bodyMediumOnDark),
                    Text('${u['email']} · ${u['role']}', style: AppTextStyles.captionOnDark),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _review(context, ref, id, 'approve'),
                            child: const Text('Approve'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _review(context, ref, id, 'reject'),
                            child: const Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (e, _) => Center(child: Text(apiErrorMessage(e), style: AppTextStyles.captionOnDark)),
      ),
    );
  }

  Future<void> _review(BuildContext context, WidgetRef ref, int id, String action) async {
    try {
      await ref.read(workspaceApiProvider).kycReview(id, action);
      ref.invalidate(_pendingUsersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User $action')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    }
  }
}
