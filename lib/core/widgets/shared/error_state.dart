part of '../shared_widgets.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        border: Border.all(color: DColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: DColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: DColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text('Something went wrong', style: DTextStyles.h3),
          const SizedBox(height: 6),
          Text(
            message,
            style: DTextStyles.body.copyWith(color: DColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shimmer Box
// ─────────────────────────────────────────────
