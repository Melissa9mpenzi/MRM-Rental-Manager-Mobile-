import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/marketplace_api.dart';
import 'package:rental_mgr_mobile/core/api/messages_api.dart';
import 'package:rental_mgr_mobile/core/api/saved_api.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/media_url.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  const PropertyDetailScreen({super.key, required this.unitId});

  final int unitId;

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  Map<String, dynamic>? _listing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(marketplaceApiProvider).listing(widget.unitId);
      setState(() => _listing = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      await ref.read(savedApiProvider).add(widget.unitId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  Future<void> _contact() async {
    try {
      final threadId = await ref.read(messagesApiProvider).startThread(widget.unitId, 'Hi, I am interested in this listing.');
      if (mounted && threadId > 0) context.push(RouteNames.messageThread(threadId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const PageScaffold(
        title: 'Property',
        body: Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
      );
    }
    final m = _listing;
    if (m == null) {
      return const PageScaffold(title: 'Property', body: Center(child: Text('Listing not found')));
    }

    return PageScaffold(
      title: 'Details',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              resolveMediaUrl(m['image'] as String?),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 220, color: AppColors.surfaceDark),
            ),
          ),
          const SizedBox(height: 16),
          Text('${m['title']}', style: AppTextStyles.headingLarge),
          Text(
            'UGX ${m['price']} / month',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.accentGreen),
          ),
          const SizedBox(height: 8),
          Text('${m['beds']} beds · ${m['baths']} baths · ${m['loc']}', style: AppTextStyles.bodySmallOnDark),
          const SizedBox(height: 16),
          GlassPanel(child: Text('${m['desc']}', style: AppTextStyles.bodyMediumOnDark)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: _save, child: const Text('Save'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(onPressed: _contact, child: const Text('Contact landlord')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
