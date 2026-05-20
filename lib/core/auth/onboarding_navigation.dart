import 'package:rental_mgr_mobile/core/models/app_user.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';

String roleDashboardPath(String role) {
  switch (role) {
    case 'landlord':
      return RouteNames.landlordDashboard;
    case 'staff':
      return RouteNames.agentDashboard;
    case 'admin':
      return RouteNames.adminDashboard;
    case 'tenant':
    default:
      return RouteNames.tenantDashboard;
  }
}

bool isRoleDashboardPath(String path) {
  return path == RouteNames.tenantDashboard ||
      path == RouteNames.landlordDashboard ||
      path == RouteNames.agentDashboard ||
      path == RouteNames.adminDashboard;
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
