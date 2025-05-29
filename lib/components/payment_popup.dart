import 'package:flutter/material.dart';

Future<bool?> PaymentPopup({
  required BuildContext context,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Image.asset('assets/images/qris.jpg'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Konfirmasi Pembayaran"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Batal"),
          ),
        ],
      );
    },
  );
}
