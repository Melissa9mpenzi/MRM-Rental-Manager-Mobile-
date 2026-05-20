import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/dashboard_api.dart';

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(dashboardApiProvider).stats();
});
