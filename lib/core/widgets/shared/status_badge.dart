part of '../shared_widgets.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase().trim()) {
      case 'active':
        return DColors.success;
      case 'expired':
        return DColors.warning;
      case 'suspended':
        return DColors.error;
      case 'inactive':
        return DColors.error;
      case 'exhausted':
        return DColors.error;
      case 'success':
        return DColors.success;
      case 'failed':
        return DColors.error;
      case 'cancelled':
        return DColors.textSecondary;
      case 'pending':
        return DColors.warning;
      default:
        return DColors.textSecondary;
    }
  }

  String get _label {
    switch (status.toLowerCase().trim()) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'suspended':
        return 'Suspended';
      case 'inactive':
        return 'Inactive';
      case 'exhausted':
        return 'Exhausted';
      case 'none':
        return 'No Plan';
      case 'success':
        return 'Success';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        if (status.isEmpty) return '—';
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Action Button
// ─────────────────────────────────────────────
