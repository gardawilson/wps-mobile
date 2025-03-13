import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Untuk menghubungkan ViewModel
import '../view_models/preview_label_view_model.dart'; // Pastikan ini adalah PreviewLabelViewModel yang benar
import '../views/preview_label_screen.dart'; // Pastikan halaman preview yang benar

class PrintConfirmationDialog extends StatelessWidget {
  final String nolabel; // Menambahkan nolabel sebagai parameter

  const PrintConfirmationDialog({super.key, required this.nolabel});

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
          onPressed: () async {
            final previewLabelViewModel =
            Provider.of<PreviewLabelViewModel>(context, listen: false);

            await previewLabelViewModel.fetchLabelData(nolabel);

            print("Label data: ${previewLabelViewModel.label}");

            if (previewLabelViewModel.label != null) {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LabelPreviewPage(nolabel: nolabel),
                ),
              );
            } else {
              Navigator.of(context).pop();

              // Membungkus ScaffoldMessenger di dalam Builder untuk memastikan konteks yang benar
              Builder(
                builder: (context) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengambil data label untuk $nolabel')),
                  );
                  return const SizedBox.shrink(); // Return empty widget
                },
              );
            }
          },
          child: const Text('Ya'),
        ),
      ],
    );
  }
}
