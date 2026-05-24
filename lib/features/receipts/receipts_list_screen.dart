import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/receipts_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final receiptsListProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(receiptsApiProvider).list(limit: 100);
});

const _filters = [
  ('all', 'All'),
  ('rent_payment', 'Rent'),
  ('security_deposit', 'Deposit'),
  ('commission', 'Commission'),
  ('government_tax', 'Tax'),
];

class ReceiptsListScreen extends ConsumerStatefulWidget {
  const ReceiptsListScreen({super.key});

  @override
  ConsumerState<ReceiptsListScreen> createState() => _ReceiptsListScreenState();
}

class _ReceiptsListScreenState extends ConsumerState<ReceiptsListScreen> {
  String filter = 'all';
  String query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(receiptsListProvider);

    return PageScaffold(
      title: 'My Receipts',
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: () async => ref.invalidate(receiptsListProvider),
        child: async.when(
          loading: () => ListView(
            children: const [SizedBox(height: 120), Center(child: CircularProgressIndicator(color: AppColors.accentGreen))],
          ),
          error: (e, _) => ListView(children: [Text('Could not load receipts: $e', style: AppTextStyles.bodyMediumOnDark)]),
          data: (rows) {
            final filtered = _filterRows(rows);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search receipts…',
                    hintStyle: AppTextStyles.captionOnDark,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                  ),
                  style: AppTextStyles.bodyMediumOnDark,
                  onChanged: (v) => setState(() => query = v),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final active = filter == f.$1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f.$2),
                          selected: active,
                          onSelected: (_) => setState(() => filter = f.$1),
                          selectedColor: AppColors.accentGreen.withValues(alpha: 0.25),
                          labelStyle: TextStyle(
                            color: active ? AppColors.accentGreen : Colors.white54,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Center(child: Text('No receipts yet')),
                  )
                else
                  ...filtered.map((r) => _ReceiptRow(receipt: r as Map<String, dynamic>)),
              ],
            );
          },
        ),
      ),
    );
  }

  List<dynamic> _filterRows(List<dynamic> rows) {
    var list = rows;
    if (filter != 'all') list = list.where((r) => (r as Map)['receipt_type'] == filter).toList();
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((r) {
        final m = r as Map<String, dynamic>;
        return '${m['receipt_number']}'.toLowerCase().contains(q) ||
            '${m['property_name']}'.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.receipt});
  final Map<String, dynamic> receipt;

  @override
  Widget build(BuildContext context) {
    final status = '${receipt['status'] ?? 'paid'}'.toUpperCase();
    final statusColor = status == 'ESCROWED'
        ? const Color(0xFF8B5CF6)
        : receipt['tx_hash'] != null
            ? const Color(0xFF14B8A6)
            : AppColors.accentGreen;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Icon(Icons.receipt_long, color: statusColor, size: 20),
          ),
          title: Text('${receipt['receipt_number']}', style: AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.w800)),
          subtitle: Text('${receipt['period_label'] ?? receipt['property_name'] ?? ''}', style: AppTextStyles.caption),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${receipt['currency'] ?? 'UGX'} ${(receipt['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w800),
              ),
              Text(status, style: AppTextStyles.caption.copyWith(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700)),
            ],
          ),
          onTap: () => context.push(RouteNames.receiptDetail((receipt['id'] as num).toInt())),
        ),
      ),
    );
  }
}
