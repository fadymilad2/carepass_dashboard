part of '../../pages/admin_users_page.dart';

class _AddAdminSheet extends StatefulWidget {
  const _AddAdminSheet();

  @override
  State<_AddAdminSheet> createState() => _AddAdminSheetState();
}

class _AddAdminSheetState extends State<_AddAdminSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  AdminRole _startingPreset = AdminRole.support;
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  late Set<String> _selectedPermissions = Set<String>.from(
    AdminRole.support.permissions,
  );

  AdminRole get _resolvedRole =>
      AdminRole.resolveFromPermissions(_selectedPermissions.toList());

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    context.read<AdminUsersBloc>().add(
      AdminUserCreateRequested(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _resolvedRole,
        permissions: _selectedPermissions.toList(),
      ),
    );
    // ✅ Pop happens in the BlocListener below, only on
    // confirmed success.
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminUsersBloc, AdminUsersState>(
      listener: (context, state) {
        if (!_saving) return;
        if (state is AdminUsersActionSuccess) {
          Navigator.pop(context);
        } else if (state is AdminUsersError) {
          setState(() {
            _saving = false;
            _error = state.message;
          });
        }
      },
      child: Container(
        width: 650,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: DColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Add Admin User', style: DTextStyles.h3),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _saving ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StatefulBuilder(
                builder: (context, setLocalState) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Text('Full Name', style: DTextStyles.label),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameCtrl,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                        hintText: 'John Doe',
                        prefixIcon: Icon(Icons.person_outline, size: 18),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text('Email', style: DTextStyles.label),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailCtrl,
                      enabled: !_saving,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'admin@carepass.app',
                        prefixIcon: Icon(Icons.email_outlined, size: 18),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text('Password', style: DTextStyles.label),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passCtrl,
                      enabled: !_saving,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                          onPressed: () =>
                              setLocalState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text('Start from a preset', style: DTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      'Pick a starting point, then fine-tune the exact '
                      'permissions below. Editing the checkboxes away '
                      'from a preset will automatically save this admin '
                      'as "Custom".',
                      style: DTextStyles.bodySmall.copyWith(
                        color: DColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...AdminRole.values.map((role) {
                      final selected = _startingPreset == role;
                      return GestureDetector(
                        onTap: _saving
                            ? null
                            : () => setLocalState(() {
                                _startingPreset = role;
                                _selectedPermissions = Set<String>.from(
                                  role.permissions,
                                );
                              }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected
                                ? role.color.withValues(alpha: 0.06)
                                : DColors.background,
                            borderRadius: BorderRadius.circular(
                              DDimens.radiusMD,
                            ),
                            border: Border.all(
                              color: selected ? role.color : DColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              RadioGroup<AdminRole>(
                                groupValue: _startingPreset,
                                onChanged: (role) {
                                  if (_saving || role == null) return;
                                  setLocalState(() {
                                    _startingPreset = role;
                                    _selectedPermissions = Set<String>.from(
                                      role.permissions,
                                    );
                                  });
                                },
                                child: Radio<AdminRole>(
                                  value: role,
                                  enabled: !_saving,
                                  activeColor: role.color,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _RoleBadge(role: role),
                                    const SizedBox(height: 4),
                                    Text(
                                      _roleDescription(role),
                                      style: DTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Text(
                          'Permissions (${_selectedPermissions.length})',
                          style: DTextStyles.label,
                        ),
                        const Spacer(),
                        Text('Will save as: ', style: DTextStyles.bodySmall),
                        const SizedBox(width: 4),
                        _RoleBadge(role: _resolvedRole),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...kAllPermissions.map((p) {
                      final checked = _selectedPermissions.contains(p.key);
                      return CheckboxListTile(
                        value: checked,
                        onChanged: _saving
                            ? null
                            : (v) {
                                setLocalState(() {
                                  if (v == true) {
                                    _selectedPermissions.add(p.key);
                                  } else {
                                    _selectedPermissions.remove(p.key);
                                  }
                                });
                              },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: DColors.primary,
                        secondary: Icon(
                          p.icon,
                          size: 18,
                          color: DColors.textSecondary,
                        ),
                        title: Text(p.label, style: DTextStyles.body),
                      );
                    }),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: DColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(DDimens.radiusMD),
                          border: Border.all(
                            color: DColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: DColors.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: DTextStyles.bodySmall.copyWith(
                                  color: DColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : () => _submit(context),
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.person_add_outlined, size: 18),
                        label: Text(_saving ? 'Adding...' : 'Add Admin User'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _roleDescription(AdminRole role) {
  switch (role) {
    case AdminRole.superAdmin:
      return 'Full access to all features';
    case AdminRole.support:
      return 'View overview, manage users & view payments';
    case AdminRole.marketer:
      return 'View overview, payments & discount codes only';
    case AdminRole.custom:
      return 'Start blank and pick exactly what this admin can access';
  }
}
