part of '../../pages/services_page.dart';

class _ManageCategoriesDialog extends StatefulWidget {
  final VoidCallback onChanged;
  const _ManageCategoriesDialog({required this.onChanged});

  @override
  State<_ManageCategoriesDialog> createState() =>
      _ManageCategoriesDialogState();
}

class _ManageCategoriesDialogState extends State<_ManageCategoriesDialog> {
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('service_categories')
          .get();

      final cats = snap.docs
          .map(
            (doc) => {
              'id': doc.id,
              'name': doc.data()['name'] as String? ?? '',
              'value': doc.data()['value'] as String? ?? doc.id,
              'order': doc.data()['order'] as int? ?? 99,
              'isActive': doc.data()['isActive'] as bool? ?? true,
            },
          )
          .toList();

      cats.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

      setState(() {
        _categories = cats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load: $e';
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }

    // ✅ Auto-generate value from name if not provided
    final value = _valueCtrl.text.trim().isNotEmpty
        ? _valueCtrl.text.trim().toLowerCase().replaceAll(' ', '_')
        : name.toLowerCase().replaceAll(' ', '_');

    final isDuplicate = _categories.any((c) => c['value'] == value);
    if (isDuplicate) {
      setState(() => _error = 'Category key "$value" already exists');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance.collection('service_categories').add({
        'name': name,
        'value': value,
        'order': _categories.length + 1,
        'isActive': true,
      });

      _nameCtrl.clear();
      _valueCtrl.clear();
      await _load();
      widget.onChanged();
    } catch (e) {
      setState(() {
        _error = 'Failed to add: $e';
        _loading = false;
      });
    }
  }

  Future<void> _delete(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Delete "$name"? Services with this category will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => dc.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => dc.pop(true),
            style: TextButton.styleFrom(foregroundColor: DColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance
          .collection('service_categories')
          .doc(id)
          .delete();
      await _load();
      widget.onChanged();
    } catch (e) {
      setState(() {
        _error = 'Failed to delete: $e';
        _loading = false;
      });
    }
  }

  Future<void> _toggleActive(String id, bool currentValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('service_categories')
          .doc(id)
          .update({'isActive': !currentValue});
      await _load();
      widget.onChanged();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
      ),
      title: Row(
        children: [
          const Icon(Icons.category_outlined, color: DColors.primary, size: 20),
          const SizedBox(width: 8),
          Text('Manage Categories', style: DTextStyles.h3),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Add New ────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DColors.background,
                borderRadius: BorderRadius.circular(DDimens.radiusMD),
                border: Border.all(color: DColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Category', style: DTextStyles.label),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Name (e.g. Ophthalmology)',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _valueCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Key (auto if empty)',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _loading ? null : _add,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(60, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add'),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _error!,
                      style: DTextStyles.bodySmall.copyWith(
                        color: DColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Existing Categories (${_categories.length})',
              style: DTextStyles.label,
            ),
            const SizedBox(height: 8),

            // ── Category List ──────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: DColors.primary),
                    )
                  : _categories.isEmpty
                  ? Center(
                      child: Text(
                        'No categories yet.\nAdd your first one above.',
                        style: DTextStyles.body.copyWith(
                          color: DColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final isActive = cat['isActive'] as bool;
                        return ListTile(
                          dense: true,
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? DColors.primaryLight
                                  : DColors.border,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (cat['name'] as String).isNotEmpty
                                    ? (cat['name'] as String)[0].toUpperCase()
                                    : '?',
                                style: DTextStyles.label.copyWith(
                                  color: isActive
                                      ? DColors.primary
                                      : DColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            cat['name'] as String,
                            style: DTextStyles.label.copyWith(
                              color: isActive
                                  ? DColors.textPrimary
                                  : DColors.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            cat['value'] as String,
                            style: DTextStyles.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isActive,
                                onChanged: (_) => _toggleActive(
                                  cat['id'] as String,
                                  isActive,
                                ),
                                activeThumbColor: DColors.primary,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: DColors.error,
                                ),
                                onPressed: () => _delete(
                                  cat['id'] as String,
                                  cat['name'] as String,
                                ),
                                padding: EdgeInsets.zero,
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Services List
// ─────────────────────────────────────────────
