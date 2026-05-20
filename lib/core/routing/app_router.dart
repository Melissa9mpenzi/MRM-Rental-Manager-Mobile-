import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/onboarding_navigation.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/app_shell.dart';
import 'package:rental_mgr_mobile/features/admin/admin_moderation_screen.dart';
import 'package:rental_mgr_mobile/features/auth/account_approved_screen.dart';
import 'package:rental_mgr_mobile/features/auth/auth_entry_screen.dart';
import 'package:rental_mgr_mobile/features/auth/forgot_password_screen.dart';
import 'package:rental_mgr_mobile/features/auth/kyc_rejected_screen.dart';
import 'package:rental_mgr_mobile/features/auth/kyc_review_screen.dart';
import 'package:rental_mgr_mobile/features/auth/review_details_screen.dart';
import 'package:rental_mgr_mobile/features/auth/kyc_upload_screen.dart';
import 'package:rental_mgr_mobile/features/auth/login_screen.dart';
import 'package:rental_mgr_mobile/features/auth/onboarding_screen.dart';
import 'package:rental_mgr_mobile/features/auth/pending_approval_screen.dart';
import 'package:rental_mgr_mobile/features/auth/register_screen.dart';
import 'package:rental_mgr_mobile/features/auth/reset_password_screen.dart';
import 'package:rental_mgr_mobile/features/auth/select_role_screen.dart';
import 'package:rental_mgr_mobile/features/auth/splash_screen.dart';
import 'package:rental_mgr_mobile/features/auth/verify_phone_screen.dart';
import 'package:rental_mgr_mobile/features/dashboard/admin_dashboard_screen.dart';
import 'package:rental_mgr_mobile/features/dashboard/agent_dashboard_screen.dart';
import 'package:rental_mgr_mobile/features/dashboard/landlord_dashboard_screen.dart';
import 'package:rental_mgr_mobile/features/dashboard/tenant_dashboard_screen.dart';
import 'package:rental_mgr_mobile/features/landlord/landlord_properties_screen.dart';
import 'package:rental_mgr_mobile/features/maintenance/maintenance_screen.dart';
import 'package:rental_mgr_mobile/features/maintenance/submit_maintenance_screen.dart';
import 'package:rental_mgr_mobile/features/marketplace/property_detail_screen.dart';
import 'package:rental_mgr_mobile/features/marketplace/property_search_screen.dart';
import 'package:rental_mgr_mobile/features/messages/message_thread_screen.dart';
import 'package:rental_mgr_mobile/features/messages/messages_screen.dart';
import 'package:rental_mgr_mobile/features/profile/settings_screen.dart';
import 'package:rental_mgr_mobile/features/tenant/contracts_screen.dart';
import 'package:rental_mgr_mobile/features/tenant/pay_rent_screen.dart';
import 'package:rental_mgr_mobile/features/tenant/saved_listings_screen.dart';
import 'package:rental_mgr_mobile/features/notifications/notifications_screen.dart';
import 'package:rental_mgr_mobile/features/profile/profile_screen.dart';
import 'package:rental_mgr_mobile/features/wallet/wallet_screen.dart';
import 'package:rental_mgr_mobile/language_selection_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      if (!auth.bootstrapped) return null;

      final path = state.uri.path;
      final user = auth.user;
      final loggedIn = auth.isAuthenticated && user != null;

      const preAuth = {
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.authEntry,
        RouteNames.language,
        RouteNames.login,
        RouteNames.forgotPassword,
        RouteNames.resetPassword,
        RouteNames.register,
        RouteNames.verifyPhone,
      };

      if (loggedIn && user != null && isAccountGated(user)) {
        final dest = postLoginDestination(user);
        final onGateScreen = authGatePaths.contains(path) || path.startsWith(RouteNames.kyc);
        if (_isShellRoute(path) && !onGateScreen) return dest;
      }

      if (!loggedIn) {
        if (_isShellRoute(path) || authGatePaths.contains(path)) {
          return RouteNames.onboarding;
        }
        return null;
      }

      if (preAuth.contains(path) && path != RouteNames.splash && path != RouteNames.language) {
        return postLoginDestination(user!);
      }

      return null;
    },
    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: RouteNames.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: RouteNames.authEntry, builder: (_, __) => const AuthEntryScreen()),
      GoRoute(path: RouteNames.language, builder: (_, __) => const LanguageSelectionScreen()),
      GoRoute(
        path: RouteNames.login,
        builder: (_, state) => LoginScreen(
          initialEmail: state.uri.queryParameters['email'],
          onboarding: state.uri.queryParameters['onboarding'] == '1',
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, state) => ResetPasswordScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: RouteNames.verifyPhone,
        builder: (_, state) => VerifyPhoneScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: RouteNames.selectRole, builder: (_, __) => const SelectRoleScreen()),
      GoRoute(
        path: RouteNames.kyc,
        builder: (_, state) => KycUploadScreen(roleLabel: state.uri.queryParameters['role'] ?? 'landlord'),
      ),
      GoRoute(path: RouteNames.kycReview, builder: (_, __) => const KycReviewScreen()),
      GoRoute(path: RouteNames.reviewDetails, builder: (_, __) => const ReviewDetailsScreen()),
      GoRoute(path: RouteNames.pendingApproval, builder: (_, __) => const PendingApprovalScreen()),
      GoRoute(path: RouteNames.kycRejected, builder: (_, __) => const KycRejectedScreen()),
      GoRoute(path: RouteNames.accountApproved, builder: (_, __) => const AccountApprovedScreen()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: RouteNames.tenantDashboard, builder: (_, __) => const TenantDashboardScreen()),
          GoRoute(path: RouteNames.landlordDashboard, builder: (_, __) => const LandlordDashboardScreen()),
          GoRoute(path: RouteNames.agentDashboard, builder: (_, __) => const AgentDashboardScreen()),
          GoRoute(path: RouteNames.adminDashboard, builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: RouteNames.search, builder: (_, __) => const PropertySearchScreen()),
          GoRoute(
            path: '/listings/:id',
            builder: (_, state) => PropertyDetailScreen(unitId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: RouteNames.saved, builder: (_, __) => const SavedListingsScreen()),
          GoRoute(path: RouteNames.contracts, builder: (_, __) => const ContractsScreen()),
          GoRoute(path: RouteNames.payRent, builder: (_, __) => const PayRentScreen()),
          GoRoute(path: RouteNames.maintenance, builder: (_, __) => const MaintenanceScreen()),
          GoRoute(path: RouteNames.submitMaintenance, builder: (_, __) => const SubmitMaintenanceScreen()),
          GoRoute(path: RouteNames.landlordProperties, builder: (_, __) => const LandlordPropertiesScreen()),
          GoRoute(path: RouteNames.settings, builder: (_, __) => const SettingsScreen()),
          GoRoute(path: RouteNames.adminModeration, builder: (_, __) => const AdminModerationScreen()),
          GoRoute(path: RouteNames.messages, builder: (_, __) => const MessagesScreen()),
          GoRoute(
            path: '/messages/:threadId',
            builder: (_, state) => MessageThreadScreen(threadId: int.parse(state.pathParameters['threadId']!)),
          ),
          GoRoute(path: RouteNames.notifications, builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: RouteNames.wallet, builder: (_, __) => const WalletScreen()),
          GoRoute(path: RouteNames.profile, builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => AuthPageScaffold(
      body: Center(
        child: GlassPanel(
          child: Text('Route not found\n${state.uri}', textAlign: TextAlign.center, style: AppTextStyles.bodyMediumOnDark),
        ),
      ),
    ),
  );
});

bool _isShellRoute(String path) {
  if (RouteNames.shellPaths.contains(path)) return true;
  if (path.startsWith('/listings/')) return true;
  if (path.startsWith('/messages/') && path != RouteNames.messages) return true;
  return false;
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
