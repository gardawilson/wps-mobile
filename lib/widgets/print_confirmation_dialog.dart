import 'package:flutter/material.dart';

// Widget untuk konfirmasi pencetakan ulang label
class PrintConfirmationDialog extends StatelessWidget {
  final VoidCallback onPrint;

  const PrintConfirmationDialog({super.key, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konfirmasi Pencetakan Ulang'),
      content: const Text('Apakah Anda ingin melakukan print ulang label?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Tutup dialog jika memilih Tidak
          },
          child: const Text('Tidak'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Tutup dialog setelah memilih Ya
            onPrint(); // Jalankan fungsi print yang diberikan
          },
          child: const Text('Ya'),
        ),
      ],
    );
  }
}
