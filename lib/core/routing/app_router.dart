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
import 'package:rental_mgr_mobile/features/auth/government_web_only_screen.dart';
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
import 'package:rental_mgr_mobile/features/dashboard/agent_dashboard_screen.dart';
import 'package:rental_mgr_mobile/features/dashboard/landlord_dashboard_screen.dart';
import 'package:rental_mgr_mobile/features/dashboard/tenant_dashboard_screen.dart';
import 'package:rental_mgr_mobile/features/landlord/landlord_properties_screen.dart';
import 'package:rental_mgr_mobile/features/maintenance/maintenance_screen.dart';
import 'package:rental_mgr_mobile/features/maintenance/submit_maintenance_screen.dart';
import 'package:rental_mgr_mobile/features/marketplace/property_detail_screen.dart';
import 'package:rental_mgr_mobile/features/marketplace/property_search_screen.dart';
import 'package:rental_mgr_mobile/features/receipts/receipts_list_screen.dart';
import 'package:rental_mgr_mobile/features/receipts/system_receipt_detail_screen.dart';
import 'package:rental_mgr_mobile/features/messages/message_thread_screen.dart';
import 'package:rental_mgr_mobile/features/messages/messages_screen.dart';
import 'package:rental_mgr_mobile/features/profile/settings_screen.dart';
import 'package:rental_mgr_mobile/features/tenant/contracts_screen.dart';
import 'package:rental_mgr_mobile/features/tenant/pay_rent_screen.dart';
import 'package:rental_mgr_mobile/features/tenant/saved_listings_screen.dart';
import 'package:rental_mgr_mobile/features/notifications/notifications_screen.dart';
import 'package:rental_mgr_mobile/features/profile/profile_screen.dart';
import 'package:rental_mgr_mobile/features/wallet/wallet_screen.dart';
import 'package:rental_mgr_mobile/features/sui/sui_shell.dart';
import 'package:rental_mgr_mobile/features/sui/sui_dashboard_screen.dart';
import 'package:rental_mgr_mobile/features/sui/sui_transactions_screen.dart';
import 'package:rental_mgr_mobile/features/sui/sui_escrow_screen.dart';
import 'package:rental_mgr_mobile/features/sui/sui_wallet_screen.dart';
import 'package:rental_mgr_mobile/features/sui/sui_receipt_screen.dart';
import 'package:rental_mgr_mobile/language_selection_screen.dart';

/// Do not [ref.watch] auth here — that recreates [GoRouter] on every login and breaks navigation.
final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = _AuthRefreshListenable(ref);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authRefresh,
    redirect: (context, state) => _authRedirect(ref.read(authProvider), state),
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
        builder: (_, state) => ForgotPasswordScreen(
          initialEmail: state.uri.queryParameters['email'],
          initialStep: state.uri.queryParameters['step'] == '2' ? 2 : 1,
        ),
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
      GoRoute(path: RouteNames.governmentWebOnly, builder: (_, __) => const GovernmentWebOnlyScreen()),
      ShellRoute(
        builder: (_, __, child) => SuiShell(child: child),
        routes: [
          GoRoute(path: RouteNames.suiDashboard, builder: (_, __) => const SuiDashboardScreen()),
          GoRoute(path: RouteNames.suiTransactions, builder: (_, __) => const SuiTransactionsScreen()),
          GoRoute(path: RouteNames.suiEscrow, builder: (_, __) => const SuiEscrowScreen()),
          GoRoute(path: RouteNames.suiWallet, builder: (_, __) => const SuiWalletScreen()),
          GoRoute(
            path: '/sui/receipts/:id',
            builder: (_, state) => SuiReceiptScreen(receiptId: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: RouteNames.tenantDashboard, builder: (_, __) => const TenantDashboardScreen()),
          GoRoute(path: RouteNames.landlordDashboard, builder: (_, __) => const LandlordDashboardScreen()),
          GoRoute(path: RouteNames.agentDashboard, builder: (_, __) => const AgentDashboardScreen()),
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
          GoRoute(path: RouteNames.messages, builder: (_, __) => const MessagesScreen()),
          GoRoute(
            path: '/messages/:threadId',
            builder: (_, state) => MessageThreadScreen(threadId: int.parse(state.pathParameters['threadId']!)),
          ),
          GoRoute(path: RouteNames.notifications, builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: RouteNames.wallet, builder: (_, __) => const WalletScreen()),
          GoRoute(path: RouteNames.receipts, builder: (_, __) => const ReceiptsListScreen()),
          GoRoute(
            path: '/receipts/:id',
            builder: (_, state) => SystemReceiptDetailScreen(receiptId: int.parse(state.pathParameters['id']!)),
          ),
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

String? _authRedirect(AuthState auth, GoRouterState state) {
  if (!auth.bootstrapped) return null;

  final path = state.uri.path;
  final uri = state.uri;
  final user = auth.user;

  if (!auth.isAuthenticated || user == null) {
    if (_isShellRoute(path) || authGatePaths.contains(path)) {
      return RouteNames.login;
    }
    if (!unauthenticatedAuthPaths.contains(path) && path != RouteNames.splash) {
      return RouteNames.login;
    }
    return null;
  }

  final u = user;

  if (path == RouteNames.forgotPassword || path == RouteNames.resetPassword) {
    return null;
  }

  if (path == RouteNames.login) {
    if (auth.onboardingFlowActive || isLoginOnboardingUri(uri)) {
      return RouteNames.selectRole;
    }
    return postLoginDestination(u);
  }

  if (auth.onboardingFlowActive || isPostAuthOnboardingPath(path, uri)) {
    if (path == RouteNames.register || path == RouteNames.verifyPhone) {
      final em = Uri.encodeComponent(u.email);
      return '${RouteNames.login}?email=$em&onboarding=1';
    }
    return null;
  }

  if (isAccountGated(u)) {
    final dest = postLoginDestination(u);
    final onGateScreen = authGatePaths.contains(path) || path.startsWith(RouteNames.kyc);
    if (_isShellRoute(path) && !onGateScreen) return dest;
  }

  if ((u.role.startsWith('gov_') || u.role == 'system_admin') &&
      path != RouteNames.governmentWebOnly) {
    if (_isShellRoute(path) || isRoleDashboardPath(path)) {
      return RouteNames.governmentWebOnly;
    }
  }

  if (isRoleDashboardPath(path)) {
    final expected = roleDashboardPath(u.role);
    if (path != expected) {
      return expected;
    }
  }


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

  if (preAuth.contains(path) && path != RouteNames.splash && path != RouteNames.language) {
    return postLoginDestination(u);
  }

  return null;
}

bool _isShellRoute(String path) {
  if (RouteNames.shellPaths.contains(path)) return true;
  if (RouteNames.suiShellPaths.contains(path) || path.startsWith('/sui/receipts/')) return true;
  if (path == RouteNames.receipts || path.startsWith('/receipts/')) return true;
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
