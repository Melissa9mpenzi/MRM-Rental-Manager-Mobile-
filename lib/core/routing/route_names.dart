
abstract class RouteNames {
  //  Auth ────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  //  Main shell 
  static const String home = '/home';

  //  Dashboard 
  static const String dashboard = '/dashboard';

  // Payments 
  static const String payments = '/payments';
  static const String paymentDetail = '/payments/:id';
  static const String recordPayment = '/payments/record';

  // Maintenance 
  static const String maintenance = '/maintenance';
  static const String maintenanceDetail = '/maintenance/:id';
  static const String submitMaintenance = '/maintenance/submit';

  // Notifications 
  static const String notifications = '/notifications';

  // Profile 
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
}
