part of '../../pages/services_page.dart';

class _ServiceCardRow extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onEdit, onToggle, onDelete;

  const _ServiceCardRow({
    required this.service,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                service.categoryLabel[0],
                style: DTextStyles.label.copyWith(color: DColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: DTextStyles.label),
                Text(service.providerName, style: DTextStyles.bodySmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(
                      status: service.isAvailable ? 'active' : 'inactive',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.discountLabel,
                      style: DTextStyles.bodySmall.copyWith(
                        color: DColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              SmallIconBtn(
                icon: Icons.edit_outlined,
                color: DColors.info,
                onTap: onEdit,
              ),
              SmallIconBtn(
                icon: service.isAvailable
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: service.isAvailable ? DColors.warning : DColors.success,
                onTap: onToggle,
              ),
              SmallIconBtn(
                icon: Icons.delete_outline,
                color: DColors.error,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
