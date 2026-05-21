import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';

class DrawerMenuItem {
  const DrawerMenuItem({
    required this.label,
    required this.icon,
    required this.route,
  });
  final String label;
  final IconData icon;
  final String route;
}

List<DrawerMenuItem> drawerItemsForRole(String role) {
  if (role.startsWith('gov_') || role == 'system_admin') {
    return [
      const DrawerMenuItem(
        label: 'Web portal',
        icon: Icons.language,
        route: RouteNames.governmentWebOnly,
      ),
      const DrawerMenuItem(label: 'Settings', icon: Icons.settings_outlined, route: RouteNames.settings),
    ];
  }

  final home = switch (role) {
    'landlord' => RouteNames.landlordDashboard,
    'staff' => RouteNames.agentDashboard,
    _ => RouteNames.tenantDashboard,
  };

  final common = [
    DrawerMenuItem(label: 'Home', icon: Icons.dashboard_outlined, route: home),
    DrawerMenuItem(label: 'Messages', icon: Icons.chat_bubble_outline, route: RouteNames.messages),
    DrawerMenuItem(label: 'Notifications', icon: Icons.notifications_outlined, route: RouteNames.notifications),
    DrawerMenuItem(label: 'Wallet', icon: Icons.account_balance_wallet_outlined, route: RouteNames.wallet),
    DrawerMenuItem(label: 'Profile', icon: Icons.person_outline, route: RouteNames.profile),
    DrawerMenuItem(label: 'Settings', icon: Icons.settings_outlined, route: RouteNames.settings),
  ];

  if (role == 'tenant') {
    return [
      ...common.take(1),
      const DrawerMenuItem(label: 'Search properties', icon: Icons.search, route: RouteNames.search),
      const DrawerMenuItem(label: 'Saved listings', icon: Icons.favorite_border, route: RouteNames.saved),
      const DrawerMenuItem(label: 'My contracts', icon: Icons.description_outlined, route: RouteNames.contracts),
      const DrawerMenuItem(label: 'Pay rent', icon: Icons.payments_outlined, route: RouteNames.payRent),
      ...common.skip(1),
    ];
  }

  if (role == 'landlord') {
    return [
      ...common.take(1),
      const DrawerMenuItem(label: 'My properties', icon: Icons.apartment_outlined, route: RouteNames.landlordProperties),
      const DrawerMenuItem(label: 'Maintenance', icon: Icons.build_outlined, route: RouteNames.maintenance),
      ...common.skip(1),
    ];
  }

  if (role == 'staff') {
    return [
      ...common.take(1),
      const DrawerMenuItem(label: 'Search listings', icon: Icons.search, route: RouteNames.search),
      ...common.skip(1),
    ];
  }

  return common;
}
