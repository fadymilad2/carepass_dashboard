part of '../../pages/services_page.dart';

class _ServicesList extends StatelessWidget {
  final List<ServiceEntity> services;
  final bool isMobile;
  final Function(ServiceEntity) onEdit;
  final Function(ServiceEntity) onToggle;
  final Function(ServiceEntity) onDelete;

  const _ServicesList({
    required this.services,
    required this.isMobile,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        border: Border.all(color: DColors.border),
      ),
      child: Column(
        children: [
          // Header
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: DColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(DDimens.radiusLG),
                ),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: _TH('Service')),
                  Expanded(flex: 2, child: _TH('Provider')),
                  Expanded(flex: 1, child: _TH('Category')),
                  Expanded(flex: 1, child: _TH('Discount')),
                  Expanded(flex: 1, child: _TH('Status')),
                  Expanded(flex: 2, child: _TH('Actions')),
                ],
              ),
            ),

          if (!isMobile) const Divider(height: 1),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: DColors.border),
            itemBuilder: (_, i) => isMobile
                ? _ServiceCardRow(
                    service: services[i],
                    onEdit: () => onEdit(services[i]),
                    onToggle: () => onToggle(services[i]),
                    onDelete: () => onDelete(services[i]),
                  )
                : _ServiceTableRow(
                    service: services[i],
                    onEdit: () => onEdit(services[i]),
                    onToggle: () => onToggle(services[i]),
                    onDelete: () => onDelete(services[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
