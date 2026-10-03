part of '../../pages/banners_page.dart';

class _BannersList extends StatelessWidget {
  final List<BannerEntity> banners;
  final bool isMobile;
  final bool isTablet;
  final Function(BannerEntity) onEdit;
  final Function(BannerEntity) onToggle;
  final Function(BannerEntity) onDelete;

  const _BannersList({
    required this.banners,
    required this.isMobile,
    required this.isTablet,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cols = isMobile
        ? 1
        : isTablet
        ? 2
        : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: cols == 1 ? 2.2 : 1.6,
      ),
      itemCount: banners.length,
      itemBuilder: (_, i) => BannerCard(
        banner: banners[i],
        onEdit: () => onEdit(banners[i]),
        onToggle: () => onToggle(banners[i]),
        onDelete: () => onDelete(banners[i]),
      ),
    );
  }
}
