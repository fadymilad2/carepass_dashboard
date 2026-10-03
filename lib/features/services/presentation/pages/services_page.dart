import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../data/models/service_model.dart';
import '../../domain/entities/service_entity.dart';
import '../bloc/services_bloc.dart';
import '../widgets/service_form_sheet.dart';

part '../widgets/services_page/manage_categories_dialog.dart';
part '../widgets/services_page/services_list.dart';
part '../widgets/services_page/t_h.dart';
part '../widgets/services_page/service_table_row.dart';
part '../widgets/services_page/service_card_row.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final _searchCtrl = TextEditingController();

  // ✅ Dynamic categories loaded from Firestore
  List<Map<String, String>> _dynamicCategories = [];
  bool _loadingCategories = false;

  // ✅ Static fallback — used only if Firestore has no categories yet
  static const _staticCategories = <Map<String, String>>[
    {'value': 'all', 'name': 'All'},
    {'value': 'consultation', 'name': 'Consultation'},
    {'value': 'radiology', 'name': 'Radiology'},
    {'value': 'lab', 'name': 'Lab'},
    {'value': 'pharmacy', 'name': 'Pharmacy'},
    {'value': 'dental', 'name': 'Dental'},
    {'value': 'physiotherapy', 'name': 'Physiotherapy'},
    {'value': 'blood_pressure', 'name': 'Blood Pressure'},
    {'value': 'blood_sugar', 'name': 'Blood Sugar'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<ServicesBloc>().add(ServicesLoadRequested());
    _loadCategories();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ✅ Load categories from Firestore
  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('service_categories')
          .where('isActive', isEqualTo: true)
          .get();

      if (!mounted) return;
      if (snap.docs.isEmpty) {
        setState(() {
          _dynamicCategories = List.from(_staticCategories);
          _loadingCategories = false;
        });
        return;
      }

      final cats = snap.docs.map((doc) {
        final data = doc.data();
        return {
          'value': data['value'] as String? ?? doc.id,
          'name': data['name'] as String? ?? 'Unknown',
          'order': (data['order'] as int? ?? 99).toString(),
        };
      }).toList();

      // Sort in memory — no Firestore index needed
      cats.sort(
        (a, b) => int.parse(a['order']!).compareTo(int.parse(b['order']!)),
      );

      setState(() {
        _dynamicCategories = [
          {'value': 'all', 'name': 'All'},
          ...cats.map((c) => {'value': c['value']!, 'name': c['name']!}),
        ];
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dynamicCategories = List.from(_staticCategories);
        _loadingCategories = false;
      });
    }
  }

  // ✅ Show Manage Categories dialog
  void _showManageCategories() {
    showDialog(
      context: context,
      builder: (_) => _ManageCategoriesDialog(onChanged: _loadCategories),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    // ✅ Use dynamic categories once loaded, fallback to static
    final filterCategories = _dynamicCategories.isEmpty
        ? _staticCategories
        : _dynamicCategories;

    return BlocConsumer<ServicesBloc, ServicesState>(
      listener: (context, state) {
        if (state is ServicesActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is ServicesError) {
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
        final loading = state is ServicesLoading;
        List<ServiceEntity> all = [];
        List<ServiceEntity> filtered = [];
        String catFilter = 'all';
        int available = 0;

        if (state is ServicesLoaded) {
          all = state.all;
          filtered = state.filtered;
          catFilter = state.categoryFilter;
          available = state.availableCount;
        } else if (state is ServicesActionSuccess) {
          all = state.all;
          filtered = state.filtered;
          catFilter = state.categoryFilter;
          available = state.all.where((s) => s.isAvailable).length;
        }

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
                        Text('Services', style: DTextStyles.h2),
                        Text(
                          '${all.length} services · $available available',
                          style: DTextStyles.body.copyWith(
                            color: DColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ Manage Categories button
                  OutlinedButton.icon(
                    onPressed: _showManageCategories,
                    icon: const Icon(Icons.category_outlined, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Categories'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DColors.primary,
                      side: const BorderSide(color: DColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: DColors.primary),
                    onPressed: loading
                        ? null
                        : () => context.read<ServicesBloc>().add(
                            ServicesLoadRequested(),
                          ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(context, null),
                    icon: const Icon(Icons.add, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Add Service'),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Search ───────────────────────────
              TextField(
                controller: _searchCtrl,
                onChanged: (q) =>
                    context.read<ServicesBloc>().add(ServicesSearchChanged(q)),
                decoration: InputDecoration(
                  hintText: 'Search by name, provider...',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: DColors.textSecondary,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            context.read<ServicesBloc>().add(
                              ServicesSearchChanged(''),
                            );
                          },
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              // ── Category Filter ✅ Dynamic ──────────
              _loadingCategories
                  ? const SizedBox(
                      height: 36,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: DColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filterCategories.map((cat) {
                          final selected = catFilter == cat['value'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat['name']!),
                              selected: selected,
                              onSelected: (_) =>
                                  context.read<ServicesBloc>().add(
                                    ServicesCategoryFilterChanged(
                                      cat['value']!,
                                    ),
                                  ),
                              selectedColor: DColors.primaryLight,
                              checkmarkColor: DColors.primary,
                              labelStyle: TextStyle(
                                color: selected
                                    ? DColors.primary
                                    : DColors.textPrimary,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? DColors.primary
                                    : DColors.border,
                              ),
                            ),
                          );
                        }).toList(),
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
              else if (filtered.isEmpty)
                EmptyState(
                  icon: Icons.medical_services_outlined,
                  title: 'No services found',
                  subtitle: 'Add your first service',
                  action: ElevatedButton.icon(
                    onPressed: () => _showForm(context, null),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Service'),
                  ),
                )
              else
                _ServicesList(
                  services: filtered,
                  isMobile: isMobile,
                  onEdit: (s) => _showForm(context, s),
                  onToggle: (s) => context.read<ServicesBloc>().add(
                    ServiceToggleRequested(
                      id: s.id,
                      isAvailable: !s.isAvailable,
                    ),
                  ),
                  onDelete: (s) => _confirmDelete(context, s),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, ServiceEntity? s) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ServicesBloc>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ServiceFormSheet(
            service: s != null ? s as ServiceModel : null,
            // ✅ Pass loaded categories (excluding "All") to the form
            categories: _dynamicCategories
                .where((c) => c['value'] != 'all')
                .toList(),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ServiceEntity s) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DDimens.radiusLG),
        ),
        title: Text('Delete Service', style: DTextStyles.h3),
        content: Text(
          'Delete "${s.name}"? This cannot be undone.',
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
              context.read<ServicesBloc>().add(ServiceDeleteRequested(s.id));
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
//  ✅ Manage Categories Dialog
// ─────────────────────────────────────────────
