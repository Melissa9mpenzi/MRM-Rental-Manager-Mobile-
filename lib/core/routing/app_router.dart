import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_tenant/core/routing/route_names.dart';
import 'package:mobile_tenant/features/auth/screens/login_screen.dart';
import 'package:mobile_tenant/features/auth/screens/register_screen.dart';
import 'package:mobile_tenant/features/auth/screens/splash_screen.dart';
import 'package:mobile_tenant/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile_tenant/features/maintenance/screens/maintenance_detail_screen.dart';
import 'package:mobile_tenant/features/maintenance/screens/maintenance_list_screen.dart';
import 'package:mobile_tenant/features/maintenance/screens/submit_maintenance_screen.dart';
import 'package:mobile_tenant/features/notifications/screens/notifications_screen.dart';
import 'package:mobile_tenant/features/payments/screens/payment_detail_screen.dart';
import 'package:mobile_tenant/features/payments/screens/payments_list_screen.dart';
import 'package:mobile_tenant/features/payments/screens/record_payment_screen.dart';
import 'package:mobile_tenant/features/profile/screens/change_password_screen.dart';
import 'package:mobile_tenant/features/profile/screens/edit_profile_screen.dart';
import 'package:mobile_tenant/features/profile/screens/profile_screen.dart';
import 'package:mobile_tenant/core/widgets/app_shell.dart';


final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      //  Auth routes
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => _fadeTransition(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        pageBuilder: (context, state) => _fadeTransition(
          state,
          const RegisterScreen(),
        ),
      ),

      // ── Shell with Bottom Navigation ────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.payments,
            name: 'payments',
            builder: (context, state) => const PaymentsListScreen(),
            routes: [
              GoRoute(
                path: 'record',
                name: 'record-payment',
                builder: (context, state) => const RecordPaymentScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'payment-detail',
                builder: (context, state) => PaymentDetailScreen(
                  paymentId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.maintenance,
            name: 'maintenance',
            builder: (context, state) => const MaintenanceListScreen(),
            routes: [
              GoRoute(
                path: 'submit',
                name: 'submit-maintenance',
                builder: (context, state) => const SubmitMaintenanceScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'maintenance-detail',
                builder: (context, state) => MaintenanceDetailScreen(
                  requestId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'change-password',
                name: 'change-password',
                builder: (context, state) => const ChangePasswordScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    // ── Error handler ──────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ),
  );
});

/// Shared fade-transition page builder
CustomTransitionPage<void> _fadeTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  );
}
