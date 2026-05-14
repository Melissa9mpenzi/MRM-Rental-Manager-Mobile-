/// App-wide string constants for localization.
/// All user-facing strings live here. Swap values for Swahili support in Phase 2.
abstract class AppStrings {
  // ── App ────────────────────────────────────────────────────────
  static const String appName = 'RentalMGR';
  static const String appTagline = 'Property. Simplified.';

  // ── Auth ────────────────────────────────────────────────────────
  static const String login = 'Log In';
  static const String register = 'Create Account';
  static const String logout = 'Log Out';
  static const String email = 'Email address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm password';
  static const String fullName = 'Full name';
  static const String phone = 'Phone number';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account?";
  static const String haveAccount = 'Already have an account?';
  static const String loginSuccess = 'Welcome back!';
  static const String registerSuccess = 'Account created. Please log in.';

  // ── Dashboard ──────────────────────────────────────────────────
  static const String dashboard = 'Dashboard';
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String currentBalance = 'Current Balance';
  static const String lastPayment = 'Last Payment';
  static const String nextDue = 'Next Due';
  static const String unitInfo = 'My Unit';
  static const String quickActions = 'Quick Actions';
  static const String recentActivity = 'Recent Activity';
  static const String viewAll = 'View all';

  // ── Payments ────────────────────────────────────────────────────
  static const String payments = 'Payments';
  static const String paymentHistory = 'Payment History';
  static const String recordPayment = 'Record Payment';
  static const String amount = 'Amount (UGX)';
  static const String paymentDate = 'Payment date';
  static const String paymentMethod = 'Payment method';
  static const String referenceCode = 'Reference / MoMo code';
  static const String periodMonth = 'Month covering';
  static const String notes = 'Notes (optional)';
  static const String paymentRecorded = 'Payment recorded successfully';
  static const String noPayments = 'No payments recorded yet';
  static const String receiptDownload = 'Download Receipt';
  static const String shareWhatsApp = 'Share via WhatsApp';

  // ── Payment Methods ─────────────────────────────────────────────
  static const String momoMtn = 'MTN MoMo';
  static const String momoAirtel = 'Airtel Money';
  static const String cash = 'Cash';
  static const String bankTransfer = 'Bank Transfer';
  static const String cheque = 'Cheque';
  static const String other = 'Other';

  // ── Maintenance ─────────────────────────────────────────────────
  static const String maintenance = 'Maintenance';
  static const String submitRequest = 'Submit Request';
  static const String requestTitle = 'Issue title';
  static const String description = 'Description';
  static const String priority = 'Priority';
  static const String status = 'Status';
  static const String noMaintenanceRequests = 'No maintenance requests';
  static const String requestSubmitted = 'Request submitted successfully';
  static const String open = 'Open';
  static const String inProgress = 'In Progress';
  static const String resolved = 'Resolved';
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';
  static const String urgent = 'Urgent';

  // ── Notifications ────────────────────────────────────────────────
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No notifications';
  static const String markAllRead = 'Mark all as read';

  // ── Profile ──────────────────────────────────────────────────────
  static const String profile = 'My Profile';
  static const String editProfile = 'Edit Profile';
  static const String changePassword = 'Change Password';
  static const String currentPassword = 'Current password';
  static const String newPassword = 'New password';
  static const String saveChanges = 'Save Changes';
  static const String profileUpdated = 'Profile updated';
  static const String passwordChanged = 'Password changed';

  // ── Common ──────────────────────────────────────────────────────
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String submit = 'Submit';
  static const String loading = 'Loading…';
  static const String retry = 'Try again';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String noInternetConnection = 'No internet connection.';
  static const String sessionExpired = 'Session expired. Please log in again.';

  // ── Validation ──────────────────────────────────────────────────
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordsMismatch = 'Passwords do not match';
  static const String invalidPhone = 'Enter a valid Ugandan phone number';
  static const String invalidAmount = 'Enter a valid amount';
}
