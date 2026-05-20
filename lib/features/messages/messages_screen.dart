import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/messages_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final messageThreadsProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(messagesApiProvider).threads();
});

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  bool _isUnread(Map<String, dynamic> t) {
    final n = t['unread_count'] ?? t['unread'] ?? 0;
    if (n is num) return n > 0;
    return t['is_read'] == false;
  }

  @override
  Widget build(BuildContext context) {
    final threads = ref.watch(messageThreadsProvider);

    return PageScaffold(
      title: 'Messages',
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            indicatorColor: AppColors.accentGreen,
            labelColor: AppColors.accentGreen,
            unselectedLabelColor: AppColors.textMutedOnDark,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Unread'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _ThreadList(
                  threads: threads,
                  filter: null,
                  onRefresh: () async => ref.invalidate(messageThreadsProvider),
                ),
                _ThreadList(
                  threads: threads,
                  filter: _isUnread,
                  onRefresh: () async => ref.invalidate(messageThreadsProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadList extends StatelessWidget {
  const _ThreadList({required this.threads, this.filter, required this.onRefresh});

  final AsyncValue<List<dynamic>> threads;
  final bool Function(Map<String, dynamic>)? filter;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return threads.when(
      data: (list) {
        final filtered = filter == null
            ? list
            : list.where((e) => filter!(e as Map<String, dynamic>)).toList();
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              filter == null ? 'No conversations yet.' : 'No unread messages.',
              style: AppTextStyles.bodyMediumOnDark,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final t = filtered[i] as Map<String, dynamic>;
              final id = (t['id'] as num?)?.toInt() ?? (t['thread_id'] as num?)?.toInt() ?? 0;
              final title = t['title'] ?? t['subject'] ?? t['listing_title'] ?? 'Conversation';
              final unread = (t['unread_count'] as num?)?.toInt() ?? 0;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push(RouteNames.messageThread(id)),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(14),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.accentGreen.withOpacity(0.2),
                          child: Text(
                            '${title.toString().isNotEmpty ? title.toString()[0].toUpperCase() : '?'}',
                            style: AppTextStyles.caption.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$title', style: AppTextStyles.bodyMediumOnDark),
                              Text(
                                '${t['last_message_preview'] ?? t['preview'] ?? ''}',
                                style: AppTextStyles.captionOnDark,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$unread', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                          )
                        else
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedOnDark),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
      error: (_, __) => Center(child: Text('Could not load messages.', style: AppTextStyles.captionOnDark)),
    );
  }
}
