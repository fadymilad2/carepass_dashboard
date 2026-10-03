part of '../../pages/users_page.dart';

class _SearchField extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search by name, phone or member ID...',
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: DColors.textSecondary,
        ),
        suffixIcon: ctrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () {
                  ctrl.clear();
                  onChanged('');
                },
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Status Filter
// ─────────────────────────────────────────────
