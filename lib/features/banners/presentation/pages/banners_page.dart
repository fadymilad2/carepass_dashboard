import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../data/models/banner_model.dart';
import '../../domain/entities/banner_entity.dart';
import '../bloc/banners_bloc.dart';
import '../widgets/banner_card.dart';
import '../widgets/banner_form_sheet.dart';

part '../widgets/banners_page/banners_list.dart';

class BannersPage extends StatefulWidget {
  const BannersPage({super.key});
  @override
  State<BannersPage> createState() => _BannersPageState();
}

class _BannersPageState extends State<BannersPage> {
  @override
  void initState() {
    super.initState();
    context.read<BannersBloc>().add(BannersLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final padding = Responsive.padding(context);

    return BlocConsumer<BannersBloc, BannersState>(
      listener: (context, state) {
        if (state is BannersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is BannersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is BannersLoading;
        final banners = state is BannersLoaded
            ? state.banners
            : state is BannersActionSuccess
            ? state.banners
            : <BannerEntity>[];

        final activeCount = banners.where((b) => b.isActive).length;

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Banners', style: DTextStyles.h2),
                        Text(
                          '${banners.length} banners · '
                          '$activeCount active',
                          style: DTextStyles.body.copyWith(
                            color: DColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: DColors.primary),
                    onPressed: loading
                        ? null
                        : () => context.read<BannersBloc>().add(
                            BannersLoadRequested(),
                          ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(context, null),
                    icon: const Icon(Icons.add, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Add Banner'),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Info Banner ──────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DColors.infoLight,
                  borderRadius: BorderRadius.circular(DDimens.radiusMD),
                  border: Border.all(
                    color: DColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: DColors.info,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Banners appear on the Home screen. '
                        'Subscribed users see provider banners, '
                        'others see general banners.',
                        style: DTextStyles.bodySmall.copyWith(
                          color: DColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Content ──────────────────────────
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: DColors.primary),
                  ),
                )
              else if (banners.isEmpty)
                EmptyState(
                  icon: Icons.image_outlined,
                  title: 'No banners yet',
                  subtitle: 'Add your first home screen banner',
                  action: ElevatedButton.icon(
                    onPressed: () => _showForm(context, null),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Banner'),
                  ),
                )
              else
                _BannersList(
                  banners: banners,
                  isMobile: isMobile,
                  isTablet: isTablet,
                  onEdit: (b) => _showForm(context, b),
                  onToggle: (b) => context.read<BannersBloc>().add(
                    BannerToggleRequested(id: b.id, isActive: !b.isActive),
                  ),
                  onDelete: (b) => _confirmDelete(context, b),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, BannerEntity? banner) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<BannersBloc>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: BannerFormSheet(
            banner: banner != null ? banner as BannerModel : null,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BannerEntity banner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DDimens.radiusLG),
        ),
        title: Text('Delete Banner', style: DTextStyles.h3),
        content: Text(
          'Delete "${banner.title}"? This cannot be undone.',
          style: DTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: DTextStyles.label),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<BannersBloc>().add(BannerDeleteRequested(banner.id));
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Banners List
// ─────────────────────────────────────────────
