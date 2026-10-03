part of '../../pages/providers_page.dart';

class _SearchField extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Search by name, area...',
        prefixIcon: Icon(Icons.search, size: 18, color: DColors.textSecondary),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ✅ Type Filter — Dynamic from Firestore
// ─────────────────────────────────────────────
