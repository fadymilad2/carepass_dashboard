part of '../../pages/admin_users_page.dart';

class _EditPermissionsDialog extends StatefulWidget {
  final AdminUserEntity admin;
  const _EditPermissionsDialog({required this.admin});

  @override
  State<_EditPermissionsDialog> createState() => _EditPermissionsDialogState();
}

class _EditPermissionsDialogState extends State<_EditPermissionsDialog> {
  late Set<String> _selected;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.admin.permissions);
  }

  void _applyPreset(AdminRole role) {
    setState(() => _selected = Set<String>.from(role.permissions));
  }

  AdminRole get _previewRole =>
      AdminRole.resolveFromPermissions(_selected.toList());

  void _save(BuildContext context) {
    setState(() {
      _saving = true;
      _error = null;
    });
    context.read<AdminUsersBloc>().add(
      AdminUserPermissionsUpdateRequested(
        adminId: widget.admin.id,
        permissions: _selected.toList(),
      ),
    );
    // ✅ Dialog no longer pops here — it waits for the
    // BlocListener below to confirm the write actually
    // succeeded (or show the real error if it didn't).
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminUsersBloc, AdminUsersState>(
      listener: (context, state) {
        if (!_saving) return; // ignore unrelated state changes
        if (state is AdminUsersActionSuccess) {
          Navigator.pop(context);
        } else if (state is AdminUsersError) {
          setState(() {
            _saving = false;
            _error = state.message;
          });
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 460,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: widget.admin.role.color.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      widget.admin.avatarLetter,
                      style: DTextStyles.label.copyWith(
                        color: widget.admin.role.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.admin.displayName,
                      style: DTextStyles.h3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _saving ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Manage Permissions',
                style: DTextStyles.bodySmall.copyWith(
                  color: DColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              Text('Quick presets', style: DTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          AdminRole.superAdmin,
                          AdminRole.support,
                          AdminRole.marketer,
                        ]
                        .map(
                          (r) => OutlinedButton(
                            onPressed: _saving ? null : () => _applyPreset(r),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              side: BorderSide(
                                color: r.color.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              r.label,
                              style: DTextStyles.bodySmall.copyWith(
                                color: r.color,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    'Permissions (${_selected.length})',
                    style: DTextStyles.label,
                  ),
                  const Spacer(),
                  Text('Will save as: ', style: DTextStyles.bodySmall),
                  const SizedBox(width: 4),
                  _RoleBadge(role: _previewRole),
                ],
              ),
              const SizedBox(height: 8),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: kAllPermissions.map((p) {
                      final checked = _selected.contains(p.key);
                      return CheckboxListTile(
                        value: checked,
                        onChanged: _saving
                            ? null
                            : (v) {
                                setState(() {
                                  if (v == true) {
                                    _selected.add(p.key);
                                  } else {
                                    _selected.remove(p.key);
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
                    }).toList(),
                  ),
                ),
              ),

              // ✅ Inline error — visible instead of a snackbar
              // that could be missed after the dialog area
              if (_error != null) ...[
                const SizedBox(height: 8),
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

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: DColors.border),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : () => _save(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Permissions'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ✅ Add Admin Sheet — same fix applied: waits for confirmed
//  success before closing, shows real errors inline.
// ─────────────────────────────────────────────
