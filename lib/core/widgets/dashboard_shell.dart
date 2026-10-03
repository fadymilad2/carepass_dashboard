import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/admin_session.dart';
import '../theme/dashboard_theme.dart';
import '../router/dashboard_router.dart';
import '../utils/responsive.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isSmall = Responsive.isSmall(context);

    return Scaffold(
      backgroundColor: DColors.background,
      drawer: isSmall
          ? Drawer(
              width: 260,
              backgroundColor: DColors.sidebar,
              child: const _SidebarContent(),
            )
          : null,
      body: Row(
        children: [
          if (!isSmall) const _SidebarContent(),
          Expanded(
            child: Column(
              children: [
                _TopBar(showMenuBtn: isSmall),
                Expanded(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Nav Item Model
// ─────────────────────────────────────────────
class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  // ✅ permissions needed — empty = always visible
  final List<String> requiredPerms;

  const _NavItem(
    this.route,
    this.icon,
    this.label, {
    this.requiredPerms = const [],
  });
}

// ─────────────────────────────────────────────
//  All Nav Items (with permissions)
// ─────────────────────────────────────────────
const _allNavItems = [
  _NavItem(
    DRoutes.overview,
    Icons.dashboard_outlined,
    'Overview',
    // ✅ overview — always visible to all admins
  ),
  _NavItem(
    DRoutes.users,
    Icons.people_outlined,
    'Users',
    requiredPerms: ['manage_users', 'view_users'],
  ),
  _NavItem(
    DRoutes.providers,
    Icons.local_hospital_outlined,
    'Providers',
    requiredPerms: ['manage_providers', 'view_providers'],
  ),
  _NavItem(
    DRoutes.services,
    Icons.medical_services_outlined,
    'Services',
    requiredPerms: ['manage_services', 'view_services'],
  ),
  _NavItem(
    DRoutes.payments,
    Icons.payments_outlined,
    'Payments',
    requiredPerms: ['manage_payments', 'view_payments'],
  ),
  _NavItem(
    DRoutes.plans,
    Icons.credit_card_outlined,
    'Plans',
    requiredPerms: ['manage_plans', 'view_plans'],
  ),
  _NavItem(
    DRoutes.discountCodes,
    Icons.discount_outlined,
    'Discount Codes',
    requiredPerms: ['manage_discount_codes', 'view_discount_codes'],
  ),
  _NavItem(
    DRoutes.banners,
    Icons.image_outlined,
    'Banners',
    requiredPerms: ['manage_banners', 'view_banners'],
  ),
  _NavItem(
    DRoutes.notifications,
    Icons.notifications_outlined,
    'Notifications',
    requiredPerms: [
      'view_notifications',
      'manage_notifications',
      'send_notifications',
    ],
  ),
  _NavItem(
    DRoutes.adminUsers,
    Icons.admin_panel_settings_outlined,
    'Admin Users',
    requiredPerms: ['manage_admin_users'],
  ),
  _NavItem(
    DRoutes.settings,
    Icons.settings_outlined,
    'Settings',
    requiredPerms: ['manage_settings', 'view_settings'],
  ),
];

// ─────────────────────────────────────────────
//  Sidebar Content
// ─────────────────────────────────────────────
class _SidebarContent extends StatelessWidget {
  const _SidebarContent();

  @override
  Widget build(BuildContext context) {
    // ✅ Rebuild when AdminSession changes (permissions loaded)
    return ListenableBuilder(
      listenable: AdminSession.instance,
      builder: (context, _) {
        final location = GoRouterState.of(context).uri.toString();
        final session = AdminSession.instance;

        // ✅ Filter items based on current admin's permissions
        final visibleItems = _allNavItems.where((item) {
          // No permissions required → always show (e.g., Overview)
          if (item.requiredPerms.isEmpty) return true;
          // Super admin sees everything
          if (session.isSuperAdmin) return true;
          // Check if admin has any of the required permissions
          return session.hasAnyPermission(item.requiredPerms);
        }).toList();

        return Container(
          width: DDimens.sidebarW,
          color: DColors.sidebar,
          child: SafeArea(
            child: Column(
              children: [
                // ── Logo ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'CarePass',
                        style: DTextStyles.h3.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Admin',
                          style: DTextStyles.labelSmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 8),

                // ── Nav Items (Filtered) ───────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    children: visibleItems.map((item) {
                      final isActive =
                          location == item.route ||
                          (item.route != '/' &&
                              location.startsWith(item.route));
                      return _SidebarItem(
                        item: item,
                        isActive: isActive,
                        onTap: () {
                          if (Responsive.isSmall(context)) {
                            Navigator.of(context).pop();
                          }
                          context.go(item.route);
                        },
                      );
                    }).toList(),
                  ),
                ),

                const Divider(color: Colors.white24, height: 1),

                // ── Admin Info ─────────────────────────
                if (session.isLoaded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            session.avatarLetter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.name.isEmpty ? 'Admin' : session.name,
                                style: DTextStyles.label.copyWith(
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                session.roleLabel,
                                style: DTextStyles.labelSmall.copyWith(
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Sign Out ───────────────────────────
                _SidebarItem(
                  item: const _NavItem('', Icons.logout, 'Sign Out'),
                  isActive: false,
                  onTap: () async {
                    if (Responsive.isSmall(context)) {
                      Navigator.of(context).pop();
                    }
                    await FirebaseAuth.instance.signOut();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Sidebar Item
// ─────────────────────────────────────────────
class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isActive ? Colors.white : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: DTextStyles.body.copyWith(
                      color: isActive ? Colors.white : Colors.white70,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Top Bar
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool showMenuBtn;
  const _TopBar({required this.showMenuBtn});

  String _title(String location) {
    if (location == '/') return 'Overview';
    if (location.startsWith('/users')) return 'Users';
    if (location.startsWith('/providers')) return 'Providers';
    if (location.startsWith('/services')) return 'Services';
    if (location.startsWith('/payments')) return 'Payments';
    if (location.startsWith('/plans')) return 'Plans';
    if (location.startsWith('/discount-codes')) return 'Discount Codes';
    if (location.startsWith('/banners')) return 'Banners';
    if (location.startsWith('/notifications')) return 'Notifications';
    if (location.startsWith('/admin-users')) return 'Admin Users';
    if (location.startsWith('/settings')) return 'Settings';
    return 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isMobile = Responsive.isMobile(context);

    return Container(
      height: DDimens.topBarH,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: DColors.surface,
        border: Border(bottom: BorderSide(color: DColors.border)),
      ),
      child: Row(
        children: [
          if (showMenuBtn)
            IconButton(
              icon: const Icon(Icons.menu),
              color: DColors.textPrimary,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          Text(_title(location), style: DTextStyles.h3),

          const Spacer(),

          // ✅ Show actual admin info from AdminSession
          ListenableBuilder(
            listenable: AdminSession.instance,
            builder: (context, _) {
              final session = AdminSession.instance;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: DColors.primaryLight,
                      child: Text(
                        session.avatarLetter,
                        style: DTextStyles.bodySmall.copyWith(
                          color: DColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name.isEmpty ? 'Admin' : session.name,
                            style: DTextStyles.label,
                          ),
                          // ✅ Show role badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _roleColor(
                                session.role,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              session.roleLabel,
                              style: DTextStyles.labelSmall.copyWith(
                                color: _roleColor(session.role),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'super_admin':
        return DColors.primary;
      case 'support':
        return DColors.info;
      case 'marketer':
        return DColors.warning;
      default:
        return DColors.textSecondary;
    }
  }
}
