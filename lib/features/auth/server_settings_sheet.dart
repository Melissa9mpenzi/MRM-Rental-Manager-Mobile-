import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/config/api_config.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';
import 'package:rental_mgr_mobile/core/config/api_url_store.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

Future<void> showServerSettingsSheet(BuildContext context, WidgetRef ref) async {
  await ref.read(apiUrlProvider.notifier).ensureLoaded();
  if (!context.mounted) return;

  final controller = TextEditingController(text: ref.read(apiUrlProvider));
  var testing = false;
  String? testResult;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.deepCharcoal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> testConnection() async {
            setSheetState(() {
              testing = true;
              testResult = null;
            });
            final base = resolveApiBaseUrl(controller.text.trim());
            try {
              final dio = Dio(
                BaseOptions(
                  connectTimeout: const Duration(seconds: 12),
                  receiveTimeout: const Duration(seconds: 12),
                ),
              );
              final res = await dio.get('$base/health');
              final ok = res.statusCode == 200;
              setSheetState(() {
                testing = false;
                testResult = ok ? 'Connected to $base' : 'Unexpected response ${res.statusCode}';
              });
            } catch (e) {
              setSheetState(() {
                testing = false;
                testResult = 'Failed: $e';
              });
            }
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Server settings', style: AppTextStyles.displayHero.copyWith(fontSize: 22)),
                const SizedBox(height: 8),
                Text(
                  'Enter your PC IP where the API runs (same Wi‑Fi as this phone). '
                  'Find it with ipconfig → IPv4 on Wi‑Fi.',
                  style: AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.textMutedOnDark),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.url,
                  style: AppTextStyles.bodyMediumOnDark,
                  decoration: const InputDecoration(
                    labelText: 'API base URL',
                    hintText: 'http://192.168.1.2:8000',
                    prefixIcon: Icon(Icons.dns_outlined),
                  ),
                ),
                if (testResult != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    testResult!,
                    style: AppTextStyles.bodySmallOnDark.copyWith(
                      color: testResult!.startsWith('Connected')
                          ? AppColors.accentGreen
                          : Colors.orange.shade200,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: testing ? null : testConnection,
                        child: testing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Test connection'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final url = controller.text.trim();
                          if (url.isEmpty || !url.startsWith('http')) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Enter a URL like http://192.168.1.2:8000')),
                            );
                            return;
                          }
                          if (ApiConfig.isInvalidHost(url)) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Replace your_pc_ip with your real IP')),
                            );
                            return;
                          }
                          await ref.read(apiUrlProvider.notifier).setBaseUrl(url);
                          ref.invalidate(dioProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('API set to ${ref.read(apiUrlProvider)}')),
                            );
                          }
                        },
                        child: const Text('Save'),
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
  );
  controller.dispose();
}
