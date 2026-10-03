part of '../../pages/users_page.dart';

class _EditUserSheet extends StatefulWidget {
  final UserEntity user;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const _EditUserSheet({
    required this.user,
    required this.onCancel,
    required this.onSaved,
  });

  @override
  State<_EditUserSheet> createState() => _EditUserSheetState();
}

class _EditUserSheetState extends State<_EditUserSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _emergencyCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.username);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _cityCtrl = TextEditingController(text: widget.user.city);
    _emergencyCtrl = TextEditingController(text: widget.user.emergencyContact);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updates = <String, dynamic>{};
      if (_nameCtrl.text.trim().isNotEmpty) {
        updates['username'] = _nameCtrl.text.trim();
      }
      if (_emailCtrl.text.trim().isNotEmpty) {
        updates['email'] = _emailCtrl.text.trim();
      }
      if (_cityCtrl.text.trim().isNotEmpty) {
        updates['city'] = _cityCtrl.text.trim();
      }
      if (_emergencyCtrl.text.trim().isNotEmpty) {
        updates['emergencyContact'] = _emergencyCtrl.text.trim();
      }

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.id)
            .update(updates);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated ✅'),
            backgroundColor: DColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<UsersBloc>().add(UsersLoadRequested());
        widget.onSaved();
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
    return Container(
      width: 480,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit User', style: DTextStyles.h3),
                      Text(
                        widget.user.phoneNumber,
                        style: DTextStyles.bodySmall.copyWith(
                          color: DColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Locked info banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DColors.warningLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outlined,
                  size: 14,
                  color: DColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phone, DOB, and Member ID cannot be changed.',
                    style: DTextStyles.bodySmall.copyWith(
                      color: DColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _F('Full Name'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _F('Email'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _F('City'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                      hintText: 'e.g. Accra',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _F('Emergency Contact'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emergencyCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.emergency_outlined, size: 18),
                      hintText: '+233 XX XXX XXXX',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
