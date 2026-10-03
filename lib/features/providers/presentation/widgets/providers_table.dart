import 'package:flutter/material.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/provider_entity.dart';

class ProvidersTable extends StatelessWidget {
  final List<ProviderEntity> providers;
  final Function(ProviderEntity) onEdit;
  final Function(ProviderEntity) onToggle;
  final Function(ProviderEntity) onDelete;

  const ProvidersTable({
    super.key,
    required this.providers,
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
                Expanded(flex: 3, child: _TH('Provider')),
                Expanded(flex: 1, child: _TH('Type')),
                Expanded(flex: 2, child: _TH('Area / Phone')),
                Expanded(flex: 1, child: _TH('Discount')),
                Expanded(flex: 1, child: _TH('Rating')),
                Expanded(flex: 1, child: _TH('Network')),
                Expanded(flex: 1, child: _TH('Status')),
                Expanded(flex: 2, child: _TH('Actions')),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: providers.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: DColors.border),
            itemBuilder: (_, i) => _ProviderRow(
              provider: providers[i],
              onEdit: () => onEdit(providers[i]),
              onToggle: () => onToggle(providers[i]),
              onDelete: () => onDelete(providers[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: DTextStyles.label);
}

class _ProviderRow extends StatelessWidget {
  final ProviderEntity provider;
  final VoidCallback onEdit, onToggle, onDelete;

  const _ProviderRow({
    required this.provider,
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
            // ── Name + logo ───────────────────────
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: DColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        provider.avatarLetter,
                        style: DTextStyles.label.copyWith(
                          color: DColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      provider.name,
                      style: DTextStyles.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Type ──────────────────────────────
            Expanded(
              flex: 1,
              child: Align(
                // ✅ التعديل هنا: يمنع التمدد ويخليه ياخد حجم الكلمة بس
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
                    provider.typeLabel,
                    style: DTextStyles.bodySmall.copyWith(
                      color: DColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            // ── Area + Phone ──────────────────────
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.area,
                    style: DTextStyles.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    provider.phoneNumber,
                    style: DTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Discount ──────────────────────────
            Expanded(
              flex: 1,
              child: Text(
                provider.discountLabel,
                style: DTextStyles.label.copyWith(color: DColors.success),
              ),
            ),

            // ── Rating ────────────────────────────
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    provider.rating.toStringAsFixed(1),
                    style: DTextStyles.body,
                  ),
                ],
              ),
            ),

            // ── In Network ────────────────────────
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  provider.isInNetwork ? Icons.check_circle : Icons.cancel,
                  color: provider.isInNetwork
                      ? DColors.success
                      : DColors.border,
                  size: 18,
                ),
              ),
            ),

            // ── Status ────────────────────────────
            Expanded(
              flex: 1,
              child: Align(
                // ✅ التعديل هنا: يمنع التمدد للبادج
                alignment: Alignment.centerLeft,
                child: StatusBadge(
                  status: provider.isActive ? 'active' : 'inactive',
                ),
              ),
            ),

            // ── Actions ───────────────────────────
            Expanded(
              flex: 2,
              child: Wrap(
                // ✅ التعديل هنا: استخدمنا Wrap عشان الزراير ماتتزنقش
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
                    icon: provider.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    label: provider.isActive ? 'Disable' : 'Enable',
                    color: provider.isActive
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
