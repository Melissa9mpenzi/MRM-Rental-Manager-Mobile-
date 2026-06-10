/// Sui console access — mirrors web `suiSidebarNav.js`.
bool canAccessSuiPortal(String? role) => role == 'system_admin';

bool isSuiRoute(String path) =>
    path == '/sui' || path.startsWith('/sui/');
