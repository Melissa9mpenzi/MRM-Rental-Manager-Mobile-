/// Central route path constants for [GoRouter].
abstract class RouteNames {
  // Auth & onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String authEntry = '/auth';
  static const String language = '/language';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String register = '/register';
  static const String verifyPhone = '/verify-phone';
  static const String selectRole = '/select-role';
  static const String kyc = '/kyc';
  static const String kycReview = '/kyc-review';
  static const String reviewDetails = '/review-details';
  static const String pendingApproval = '/pending-approval';
  static const String kycRejected = '/kyc-rejected';
  static const String accountApproved = '/account-approved';

  // Role dashboards
  static const String tenantDashboard = '/tenant/dashboard';
  static const String landlordDashboard = '/landlord/dashboard';
  static const String agentDashboard = '/agent/dashboard';
  static const String adminDashboard = '/admin/dashboard';
  static const String dashboard = tenantDashboard;

  // Features (drawer + deep links)
  static const String search = '/search';
  static const String saved = '/saved';
  static const String contracts = '/contracts';
  static const String payRent = '/pay-rent';
  static const String maintenance = '/maintenance';
  static const String submitMaintenance = '/maintenance/submit';
  static const String landlordProperties = '/landlord/properties';
  static const String settings = '/settings';
  static const String adminModeration = '/admin/moderation';
  static String listingDetail(int id) => '/listings/$id';

  // Main shell tabs
  static const String messages = '/messages';
  static const String notifications = '/notifications';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static String messageThread(int id) => '/messages/$id';

  static const Set<String> shellPaths = {
    tenantDashboard,
    landlordDashboard,
    agentDashboard,
    adminDashboard,
    messages,
    notifications,
    wallet,
    profile,
    search,
    saved,
    contracts,
    payRent,
    maintenance,
    submitMaintenance,
    landlordProperties,
    settings,
    adminModeration,
  };
}
