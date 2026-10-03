part of '../../pages/providers_page.dart';

class _ManageTypesDialog extends StatefulWidget {
  const _ManageTypesDialog();

  @override
  State<_ManageTypesDialog> createState() => _ManageTypesDialogState();
}

class _ManageTypesDialogState extends State<_ManageTypesDialog> {
  final _db = FirebaseFirestore.instance;
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  Stream<QuerySnapshot> get _stream =>
      _db.collection('provider_types').orderBy('order').snapshots();

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    try {
      final countSnap = await _db.collection('provider_types').count().get();
      final count = countSnap.count ?? 0;

      await _db.collection('provider_types').add({
        'name': name,
        'value': name.toLowerCase().replaceAll(' ', '_'),
        'order': count + 1,
        'isActive': true,
      });
      _nameCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: DColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _db.collection('provider_types').doc(id).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: DColors.error),
        );
      }
    }
  }

  Future<void> _toggle(String id, bool current) async {
    await _db.collection('provider_types').doc(id).update({
      'isActive': !current,
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Manage Provider Types', style: DTextStyles.h3),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Add New ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'New type name...',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _add,
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Add'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── List ──────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: DColors.primary),
                    );
                  }

                  final docs = snap.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 48,
                              color: DColors.textHint,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No types yet',
                              style: DTextStyles.body.copyWith(
                                color: DColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Add your first provider type above',
                              style: DTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: docs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name'] as String? ?? '';
                      final active = data['isActive'] as bool? ?? true;

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: DColors.primaryLight,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: DTextStyles.bodySmall.copyWith(
                              color: DColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(name, style: DTextStyles.label),
                        subtitle: Text(
                          active ? 'Active' : 'Inactive',
                          style: DTextStyles.bodySmall.copyWith(
                            color: active ? DColors.success : DColors.textHint,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: active,
                              onChanged: (_) => _toggle(doc.id, active),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: DColors.error,
                              ),
                              tooltip: 'Delete',
                              onPressed: () =>
                                  _confirmDelete(context, doc.id, name),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('Delete Type'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dc),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _delete(id);
              Navigator.pop(dc);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Search Field
// ─────────────────────────────────────────────
