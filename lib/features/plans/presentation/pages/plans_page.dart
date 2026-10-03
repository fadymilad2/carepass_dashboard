import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../data/models/plan_model.dart';
import '../../domain/entities/plan_entity.dart';
import '../bloc/plans_bloc.dart';

part '../widgets/plans_page/plan_card.dart';
part '../widgets/plans_page/plan_form_sheet.dart';
part '../widgets/plans_page/toggle.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});
  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  @override
  void initState() {
    super.initState();
    context.read<PlansBloc>().add(PlansLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    return BlocConsumer<PlansBloc, PlansState>(
      listener: (context, state) {
        if (state is PlansActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is PlansError) {
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
        final loading = state is PlansLoading;
        List<PlanEntity> plans = [];

        if (state is PlansLoaded) {
          plans = state.plans;
        } else if (state is PlansActionSuccess) {
          plans = state.plans;
        } else if (state is PlansError) {
          plans = state.plans;
        }

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pricing Plans', style: DTextStyles.h2),
                        Text(
                          '${plans.length} plans · ${plans.where((p) => p.isActive).length} active',
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
                        : () => context.read<PlansBloc>().add(
                            PlansLoadRequested(),
                          ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(context, null),
                    icon: const Icon(Icons.add, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Add Plan'),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 12 : 20),

              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: DColors.primary),
                  ),
                )
              else if (plans.isEmpty)
                EmptyState(
                  icon: Icons.credit_card_outlined,
                  title: 'No plans yet',
                  subtitle: 'Add your first pricing plan',
                  action: ElevatedButton.icon(
                    onPressed: () => _showForm(context, null),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Plan'),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 2.2 : 1.4,
                  ),
                  itemCount: plans.length,
                  itemBuilder: (_, i) => _PlanCard(
                    plan: plans[i],
                    onEdit: () => _showForm(context, plans[i]),
                    onToggle: () => context.read<PlansBloc>().add(
                      PlanToggleRequested(
                        id: plans[i].id,
                        isActive: !plans[i].isActive,
                      ),
                    ),
                    onDelete: () => _confirmDelete(context, plans[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, PlanEntity? plan) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<PlansBloc>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: _PlanFormSheet(plan: plan as PlanModel?),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PlanEntity plan) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Plan',
      message: 'Delete "${plan.name}" plan?',
      confirmLabel: 'Delete',
    );
    if (confirm == true && context.mounted) {
      context.read<PlansBloc>().add(PlanDeleteRequested(plan.id));
    }
  }
}

// ─────────────────────────────────────────────
//  Plan Card
// ─────────────────────────────────────────────
