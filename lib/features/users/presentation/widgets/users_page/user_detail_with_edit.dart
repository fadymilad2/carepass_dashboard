part of '../../pages/users_page.dart';

class _UserDetailWithEdit extends StatefulWidget {
  final UserEntity user;
  const _UserDetailWithEdit({required this.user});

  @override
  State<_UserDetailWithEdit> createState() => _UserDetailWithEditState();
}

class _UserDetailWithEditState extends State<_UserDetailWithEdit> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    return _editMode
        ? _EditUserSheet(
            user: widget.user,
            onCancel: () => setState(() => _editMode = false),
            onSaved: () {
              setState(() => _editMode = false);
              Navigator.pop(context);
            },
          )
        : Stack(
            children: [
              UserDetailSheet(user: widget.user),
              Positioned(
                top: 12,
                right: 72,
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: DColors.primary),
                  tooltip: 'Edit user data',
                  onPressed: () => setState(() => _editMode = true),
                ),
              ),
            ],
          );
  }
}

// ─────────────────────────────────────────────
//  ✅ Edit User Sheet — Dashboard
// ─────────────────────────────────────────────
