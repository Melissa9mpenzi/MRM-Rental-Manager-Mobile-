import 'package:rental_mgr_mobile/core/models/app_user.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';

bool isGovernmentOfficer(String role) =>
    role == 'gov_nira' || role == 'gov_kcca' || role == 'gov_ura';

bool isSystemAdministrator(String role) => role == 'system_admin';

bool isGovernmentOrSystemRole(String role) =>
    isGovernmentOfficer(role) || isSystemAdministrator(role);

String roleDashboardPath(String role) {
  if (isGovernmentOrSystemRole(role)) return RouteNames.governmentWebOnly;
  switch (role) {
    case 'landlord':
      return RouteNames.landlordDashboard;
    case 'staff':
      return RouteNames.agentDashboard;
    case 'tenant':
    default:
      return RouteNames.tenantDashboard;
  }
}

bool isRoleDashboardPath(String path) {
  return path == RouteNames.tenantDashboard ||
      path == RouteNames.landlordDashboard ||
      path == RouteNames.agentDashboard ||
      path == RouteNames.governmentWebOnly;
}

/// 1 splash 2 onboarding 3 register 4 verify 5 role 6 kyc 7 kyc-review 8 review-details 9 pending 10 approved
const int authFlowTotalSteps = 10;

String postLoginDestination(AppUser user) {
  final role = user.role;

  if (role == 'landlord' || role == 'staff') {
    if (!user.trustedForCommerce) {
      final kyc = user.kycReviewStatus;
      if (kyc == 'rejected') return RouteNames.kycRejected;
      if (user.kycSubmittedAt == null) {
        return '${RouteNames.kyc}?role=${role == 'staff' ? 'agent' : 'landlord'}';
      }
      if (kyc == 'pending') return RouteNames.pendingApproval;
    }
  }

  return roleDashboardPath(role);
}

String destinationAfterRoleSelection(String uiRole) {
  if (uiRole == 'tenant') return RouteNames.accountApproved;
  return '${RouteNames.kyc}?role=$uiRole';
}

String apiRoleFromUi(String uiRole) {
  if (uiRole == 'agent') return 'staff';
  return uiRole;
}

bool isAccountGated(AppUser user) {
  if (user.role == 'landlord' || user.role == 'staff') {
    if (!user.trustedForCommerce) {
      final kyc = user.kycReviewStatus;
      if (kyc == 'pending' || kyc == 'rejected' || user.kycSubmittedAt == null) {
        return true;
      }
    }
  }
  return false;
}

const Set<String> authGatePaths = {
  RouteNames.kyc,
  RouteNames.kycReview,
  RouteNames.reviewDetails,
  RouteNames.pendingApproval,
  RouteNames.kycRejected,
  RouteNames.accountApproved,
  RouteNames.selectRole,
};

/// Paths allowed while logged out (signup / sign-in funnel).
const Set<String> unauthenticatedAuthPaths = {
  RouteNames.onboarding,
  RouteNames.authEntry,
  RouteNames.language,
  RouteNames.login,
  RouteNames.register,
  RouteNames.verifyPhone,
  RouteNames.forgotPassword,
  RouteNames.resetPassword,
};

bool isLoginOnboardingUri(Uri uri) =>
    uri.path == RouteNames.login && uri.queryParameters['onboarding'] == '1';

/// Clear persisted onboarding when user reaches their dashboard (KYC approved or tenant path).
bool shouldClearOnboardingFlow(AppUser user, String destination) {
  return isRoleDashboardPath(destination) && !isAccountGated(user);
}

bool isPostAuthOnboardingPath(String path, Uri uri) {
  if (path == RouteNames.selectRole) return true;
  if (authGatePaths.contains(path) || path.startsWith(RouteNames.kyc)) return true;
  if (path == RouteNames.accountApproved) return true;
  return false;
}
