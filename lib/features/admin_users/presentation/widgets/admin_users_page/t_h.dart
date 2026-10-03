part of '../../pages/admin_users_page.dart';

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: DTextStyles.label);
}
