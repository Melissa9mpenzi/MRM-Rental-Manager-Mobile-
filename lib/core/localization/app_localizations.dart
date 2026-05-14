import 'package:flutter/material.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'app_title': 'Rental Manager',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'logout': 'Logout',

      // Auth
      'auth_login': 'Login',
      'auth_register': 'Register',
      'auth_email': 'Email',
      'auth_password': 'Password',
      'auth_confirm_password': 'Confirm Password',
      'auth_remember_me': 'Remember Me',
      'auth_forgot_password': 'Forgot Password?',
      'auth_login_error': 'Invalid email or password',
      'auth_signup': 'Sign Up',
      'auth_already_have_account': 'Already have an account?',
      'auth_create_account': 'Create Account',
      'auth_no_account': "Don't have an account?",

      // Dashboard
      'dashboard_title': 'Dashboard',
      'dashboard_welcome': 'Welcome Back',
      'dashboard_properties': 'Properties',
      'dashboard_tenants': 'Tenants',
      'dashboard_payments': 'Payments',
      'dashboard_maintenance': 'Maintenance',
      'dashboard_quick_actions': 'Quick Actions',

      // Payments
      'payments_title': 'Payments',
      'payments_pending': 'Pending',
      'payments_paid': 'Paid',
      'payments_overdue': 'Overdue',
      'payments_record_payment': 'Record Payment',
      'payments_amount': 'Amount',
      'payments_date': 'Date',

      // Maintenance
      'maintenance_title': 'Maintenance',
      'maintenance_pending': 'Pending',
      'maintenance_completed': 'Completed',
      'maintenance_new_request': 'New Request',
      'maintenance_description': 'Description',
      'maintenance_priority': 'Priority',

      // Notifications
      'notifications_title': 'Notifications',
      'notifications_no_notifications': 'No new notifications',

      // Profile
      'profile_title': 'Profile',
      'profile_my_profile': 'My Profile',
      'profile_settings': 'Settings',
      'profile_name': 'Full Name',
      'profile_phone': 'Phone',
      'profile_address': 'Address',
      'profile_change_password': 'Change Password',
    },
  };

  static String of(BuildContext context, String key) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en')];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
