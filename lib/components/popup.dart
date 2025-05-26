import 'package:flutter/material.dart';

Future<bool?> MyPopup({
  required BuildContext context,
  required String title,
  required String content,
  String cancelText = "Batal",
  String confirmText = "Konfirmasi",
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}
