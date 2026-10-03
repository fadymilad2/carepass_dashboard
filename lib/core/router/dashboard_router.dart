import 'package:carepass_dashboard/features/plans/presentation/pages/plans_page.dart';
import 'package:carepass_dashboard/features/services/presentation/pages/services_page.dart';
import 'package:carepass_dashboard/features/settings/presentation/pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/overview/presentation/pages/overview_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/providers/presentation/pages/providers_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/banners/presentation/pages/banners_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/discount_codes/presentation/pages/discount_codes_page.dart';
import '../../features/admin_users/presentation/pages/admin_users_page.dart';
import '../services/admin_session.dart';
import '../widgets/dashboard_shell.dart';
import '../widgets/dashboard_feature_scope.dart';

class DRoutes {
  DRoutes._();
  static const login = '/login';
  static const overview = '/';
  static const users = '/users';
  static const providers = '/providers';
  static const services = '/services';
  static const payments = '/payments';
  static const plans = '/plans';
  static const discountCodes = '/discount-codes';
  static const banners = '/banners';
  static const notifications = '/notifications';
  static const adminUsers = '/admin-users';
  static const settings = '/settings';
}

// ✅ Route → required permissions (any one is enough)
const _routePermissions = <String, List<String>>{
  DRoutes.users: ['manage_users', 'view_users'],
  DRoutes.providers: ['manage_providers', 'view_providers'],
  DRoutes.services: ['manage_services', 'view_services'],
  DRoutes.payments: ['manage_payments', 'view_payments'],
  DRoutes.plans: ['manage_plans', 'view_plans'],
  DRoutes.discountCodes: ['manage_discount_codes', 'view_discount_codes'],
  DRoutes.banners: ['manage_banners', 'view_banners'],
  DRoutes.notifications: [
    'manage_notifications',
    'view_notifications',
    'send_notifications',
  ],
  DRoutes.adminUsers: ['manage_admin_users'],
  DRoutes.settings: ['manage_settings', 'view_settings'],
  // overview → accessible to all admins (no entry = always allowed)
};

// ── Router ──────────────────────────────────────────────────────────────────
final dashboardRouter = GoRouter(
  initialLocation: DRoutes.overview,
  refreshListenable: AdminSession.instance,
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final loc = state.uri.path;
    final isLoginPage = loc == DRoutes.login;

    // ── Auth Guard ────────────────────────────────────────────────────────
    if (!isLoggedIn && !isLoginPage) return DRoutes.login;
    if (isLoggedIn &&
        isLoginPage &&
        AdminSession.instance.isLoaded &&
        AdminSession.instance.isValidAdmin) {
      return DRoutes.overview;
    }

    // ── Wait for session to load ──────────────────────────────────────────
    if (isLoggedIn && !AdminSession.instance.isLoaded) return null;

    if (isLoggedIn &&
        AdminSession.instance.isLoaded &&
        !AdminSession.instance.isValidAdmin &&
        !isLoginPage) {
      return DRoutes.login;
    }

    // ── Permission Guard ──────────────────────────────────────────────────
    if (isLoggedIn && AdminSession.instance.isLoaded) {
      final session = AdminSession.instance;

      // Check each protected route
      for (final entry in _routePermissions.entries) {
        if (loc == entry.key || loc.startsWith('${entry.key}/')) {
          if (!session.hasAnyPermission(entry.value)) {
            // ✅ Redirect to overview if no permission
            return DRoutes.overview;
          }
          break;
        }
      }
    }

    return null;
  },
  routes: [
    // ── Login ─────────────────────────────────────────────────────────────
    GoRoute(path: DRoutes.login, builder: (_, _) => const LoginPage()),

    // ── Shell (Protected) ─────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AnimatedBuilder(
        animation: AdminSession.instance,
        builder: (_, _) =>
            AdminSession.instance.isLoaded && AdminSession.instance.isValidAdmin
            ? DashboardFeatureScope(
                key: ValueKey(FirebaseAuth.instance.currentUser?.uid),
                child: DashboardShell(child: child),
              )
            : const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      routes: [
        GoRoute(
          path: DRoutes.overview,
          builder: (_, _) => const OverviewPage(),
        ),
        GoRoute(path: DRoutes.users, builder: (_, _) => const UsersPage()),
        GoRoute(
          path: DRoutes.providers,
          builder: (_, _) => const ProvidersPage(),
        ),
        GoRoute(
          path: DRoutes.services,
          builder: (_, _) => const ServicesPage(),
        ),
        GoRoute(
          path: DRoutes.payments,
          builder: (_, _) => const PaymentsPage(),
        ),
        GoRoute(path: DRoutes.plans, builder: (_, _) => const PlansPage()),
        GoRoute(
          path: DRoutes.discountCodes,
          builder: (_, _) => const DiscountCodesPage(),
        ),
        GoRoute(path: DRoutes.banners, builder: (_, _) => const BannersPage()),
        GoRoute(
          path: DRoutes.notifications,
          builder: (_, _) => const NotificationsPage(),
        ),
        GoRoute(
          path: DRoutes.adminUsers,
          builder: (_, _) => const AdminUsersPage(),
        ),
        GoRoute(
          path: DRoutes.settings,
          builder: (_, _) => const SettingsPage(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFE53E3E)),
          const SizedBox(height: 12),
          const Text(
            'Page not found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go(DRoutes.overview),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    ),
  ),
);
