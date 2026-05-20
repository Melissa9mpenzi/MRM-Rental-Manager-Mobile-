import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/api/tenant_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _leaseUnitProvider = FutureProvider<int?>((ref) async {
  final lease = await ref.watch(tenantApiProvider).myLease();
  if (lease == null) return null;
  final unit = lease['unit'] ?? lease['unit_id'];
  if (unit is Map) return (unit['id'] as num?)?.toInt();
  return (unit as num?)?.toInt();
});

class SubmitMaintenanceScreen extends ConsumerStatefulWidget {
  const SubmitMaintenanceScreen({super.key});

  @override
  ConsumerState<SubmitMaintenanceScreen> createState() => _SubmitMaintenanceScreenState();
}

class _SubmitMaintenanceScreenState extends ConsumerState<SubmitMaintenanceScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit(int? unitId) async {
    if (_title.text.trim().isEmpty) return;
    if (unitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active lease unit found. Ask your landlord to link your tenant profile.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final dio = ref.read(dioProvider);
      final fd = FormData.fromMap({
        'unit_id': unitId,
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'priority': 'medium',
      });
      await dio.post('/maintenance', data: fd);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitAsync = ref.watch(_leaseUnitProvider);

    return PageScaffold(
      title: 'Submit request',
      body: unitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Could not load lease info.', style: AppTextStyles.captionOnDark)),
        data: (unitId) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (unitId != null)
                    Text('Unit #$unitId', style: AppTextStyles.captionOnDark)
                  else
                    Text(
                      'Submitting requires an active lease. Contact your landlord if you rent through RentDirect.',
                      style: AppTextStyles.captionOnDark,
                    ),
                  const SizedBox(height: 12),
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _desc,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : () => _submit(unitId),
                      child: _busy
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
