part of '../shared_widgets.dart';

class AppSheetScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? footer;

  const AppSheetScaffold({
    super.key,
    required this.title,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: DColors.border,
            borderRadius: BorderRadius.circular(100),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
          child: Row(
            children: [
              Expanded(child: Text(title, style: DTextStyles.h3)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Scrollable body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: body,
          ),
        ),

        // Optional footer
        if (footer != null)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: DColors.surface,
              border: Border(top: BorderSide(color: DColors.border)),
            ),
            child: footer!,
          ),
      ],
    );
  }
}
