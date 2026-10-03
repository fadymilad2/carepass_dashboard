part of '../../pages/login_page.dart';

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'CarePass',
          style: DTextStyles.h1.copyWith(
            color: Colors.white,
            fontSize: 40,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Admin Dashboard',
          style: DTextStyles.body.copyWith(color: Colors.white70, fontSize: 16),
        ),

        const SizedBox(height: 56),

        // Features list
        ...[
          (Icons.people_outlined, 'Manage Users & Subscriptions'),
          (Icons.local_hospital_outlined, 'Add & Edit Providers'),
          (Icons.payments_outlined, 'Track Payments & Revenue'),
          (Icons.discount_outlined, 'Discount & Promo Codes'),
          (Icons.notifications_outlined, 'Send Push Notifications'),
          (Icons.image_outlined, 'Manage Home Banners'),
        ].map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 48),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.$1, color: Colors.white70, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  item.$2,
                  style: DTextStyles.body.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Login Form
// ─────────────────────────────────────────────
