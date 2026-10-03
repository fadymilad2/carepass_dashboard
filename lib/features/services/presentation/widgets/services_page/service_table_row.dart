part of '../../pages/services_page.dart';

class _ServiceTableRow extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onEdit, onToggle, onDelete;

  const _ServiceTableRow({
    required this.service,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      hoverColor: DColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                service.name,
                style: DTextStyles.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                service.providerName,
                style: DTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service.categoryLabel,
                    style: DTextStyles.bodySmall.copyWith(
                      color: DColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                service.discountLabel,
                style: DTextStyles.label.copyWith(color: DColors.success),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(
                  status: service.isAvailable ? 'active' : 'inactive',
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ActionBtn(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: DColors.info,
                    onTap: onEdit,
                  ),
                  ActionBtn(
                    icon: service.isAvailable
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    label: service.isAvailable ? 'Disable' : 'Enable',
                    color: service.isAvailable
                        ? DColors.warning
                        : DColors.success,
                    onTap: onToggle,
                  ),
                  SmallIconBtn(
                    icon: Icons.delete_outline,
                    color: DColors.error,
                    tooltip: 'Delete',
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
