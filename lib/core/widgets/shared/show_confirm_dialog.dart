part of '../shared_widgets.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  Color confirmColor = DColors.error,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title, style: DTextStyles.h3),
      content: Text(message, style: DTextStyles.body),
      actions: [
        TextButton(
          // ✅ التعديل هنا لزرار الإلغاء
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          // ✅ التعديل هنا لزرار التأكيد
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  double heightFactor = 0.92,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true, // ✅ مهم جداً
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (_) => Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: const BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: child,
    ),
  );
}

// ✅ Base Sheet Widget — استخدمه في كل الـ forms
