import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/dashboard_api.dart';
import 'package:rental_mgr_mobile/core/api/workspace_api.dart';

/// Landlord metrics from `GET /dashboard/stats`.
final landlordDashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(dashboardApiProvider).stats();
});

/// Agent / staff workspace from `GET /workspace/staff/summary`.
final agentWorkspaceSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(workspaceApiProvider).staffSummary();
});

/// Admin workspace from `GET /workspace/admin/summary`.
final adminWorkspaceSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(workspaceApiProvider).adminSummary();
});
