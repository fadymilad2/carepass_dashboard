part of '../../pages/admin_users_page.dart';

class _RoleBadge extends StatelessWidget {
  final AdminRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: role.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: role.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: role.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            role.label,
            style: DTextStyles.bodySmall.copyWith(
              color: role.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ✅ Fixed — Editable Permissions Dialog now waits for a
//  confirmed success/error from the Bloc before closing, and
//  shows the error inline instead of silently disappearing.
// ─────────────────────────────────────────────
