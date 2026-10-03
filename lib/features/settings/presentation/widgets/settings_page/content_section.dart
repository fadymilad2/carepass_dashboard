part of '../../pages/settings_page.dart';

class _ContentSection extends StatefulWidget {
  final String title;
  final String label;
  final String hint;
  final int maxLines;
  final String docKey;
  final Future<void> Function(String) onSave;

  const _ContentSection({
    required this.title,
    required this.label,
    required this.hint,
    required this.maxLines,
    required this.docKey,
    required this.onSave,
  });

  @override
  State<_ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<_ContentSection> {
  late TextEditingController _ctrl;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('app_content')
          .get();

      if (!mounted) return;
      if (doc.exists && doc.data() != null) {
        dynamic current = doc.data();
        for (final key in widget.docKey.split('.')) {
          if (current is Map) {
            current = (current)[key];
          } else {
            current = null;
            break;
          }
        }
        if (current is String) _ctrl.text = current;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_ctrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved ✅'),
            backgroundColor: DColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: DColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: widget.title,
      action: ElevatedButton.icon(
        onPressed: _saving || _loading ? null : _save,
        icon: _saving
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_outlined, size: 14),
        label: Text(_saving ? 'Saving...' : 'Save'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
      child: _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: DColors.primary),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: DTextStyles.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _ctrl,
                  maxLines: widget.maxLines,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    alignLabelWithHint: true,
                  ),
                ),
                if (widget.maxLines > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Changes are reflected in the app immediately after saving.',
                    style: DTextStyles.bodySmall.copyWith(
                      color: DColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────
//  Check Limit Row
// ─────────────────────────────────────────────
