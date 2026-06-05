import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/marketplace_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/media_url.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

class PropertySearchScreen extends ConsumerStatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  ConsumerState<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends ConsumerState<PropertySearchScreen> {
  final _search = TextEditingController();
  double _maxRent = 5000000;
  double _minRent = 0;
  String? _unitType;
  List<dynamic> _list = [];
  bool _loading = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await ref.read(marketplaceApiProvider).listings(
            search: _search.text,
            minRent: _minRent > 0 ? _minRent : null,
            maxRent: _maxRent,
            unitType: (_unitType != null && _unitType!.isNotEmpty) ? _unitType : null,
          );
      setState(() => _list = rows);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Search',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Location, property name…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(icon: const Icon(Icons.tune), onPressed: _showFilters),
                  ),
                  onSubmitted: (_) => _load(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: _load, child: const Text('Apply filters')),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final m = _list[i] as Map<String, dynamic>;
                      final id = (m['id'] as num).toInt();
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => context.push(RouteNames.listingDetail(id)),
                          child: GlassPanel(
                            padding: const EdgeInsets.all(12),
                            borderRadius: 14,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    resolveMediaUrl(m['image'] as String?),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 72,
                                      height: 72,
                                      color: AppColors.surfaceDark,
                                      child: const Icon(Icons.home),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${m['title']}', style: AppTextStyles.bodyMediumOnDark),
                                      Text('UGX ${m['price']} / mo', style: AppTextStyles.captionOnDark.copyWith(color: AppColors.accentGreen)),
                                      Text('${m['beds']} bed · ${m['loc']}', style: AppTextStyles.captionOnDark),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Unit type', style: AppTextStyles.headingSmallOnDark),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _unitType,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              dropdownColor: AppColors.surfaceDark,
              style: AppTextStyles.bodySmallOnDark,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Any', style: AppTextStyles.bodySmallOnDark),
                ),
                DropdownMenuItem(
                  value: 'studio',
                  child: Text('Studio', style: AppTextStyles.bodySmallOnDark),
                ),
                DropdownMenuItem(
                  value: 'bedsitter',
                  child: Text('Bedsitter', style: AppTextStyles.bodySmallOnDark),
                ),
                DropdownMenuItem(
                  value: 'one_bedroom',
                  child: Text('1 bedroom', style: AppTextStyles.bodySmallOnDark),
                ),
                DropdownMenuItem(
                  value: 'two_bedroom',
                  child: Text('2 bedroom', style: AppTextStyles.bodySmallOnDark),
                ),
                DropdownMenuItem(
                  value: 'three_bedroom',
                  child: Text('3 bedroom', style: AppTextStyles.bodySmallOnDark),
                ),
              ],
              onChanged: (v) => setState(() => _unitType = v),
            ),
            const SizedBox(height: 20),
            Text('Min rent (UGX)', style: AppTextStyles.headingSmallOnDark),
            Slider(
              value: _minRent.clamp(0, _maxRent),
              min: 0,
              max: 5000000,
              divisions: 25,
              label: _minRent <= 0 ? 'Any' : _minRent.round().toString(),
              onChanged: (v) => setState(() => _minRent = v),
            ),
            Text('Max rent (UGX)', style: AppTextStyles.headingSmallOnDark),
            Slider(
              value: _maxRent.clamp(_minRent > 0 ? _minRent : 200000, 10000000),
              min: 200000,
              max: 10000000,
              divisions: 20,
              label: _maxRent.round().toString(),
              onChanged: (v) => setState(() => _maxRent = v),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() {
                _minRent = 0;
                _unitType = null;
              }),
              child: const Text('Reset filters'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _load();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
