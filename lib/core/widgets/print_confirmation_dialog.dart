import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Untuk menghubungkan ViewModel
import '../view_models/preview_label_view_model.dart'; // Pastikan ini adalah PreviewLabelViewModel yang benar
import '../view_models/pdf_view_model.dart';
import '../view_models/pdf_view_model_st.dart';

class PrintConfirmationDialog extends StatelessWidget {
  final String nolabel; // Menambahkan nolabel sebagai parameter

  const PrintConfirmationDialog({super.key, required this.nolabel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Label Telah 6 Bulan'),
      content: Text('Label berhasil disimpan. Apakah Anda ingin melakukan print ulang label $nolabel?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Tutup dialog jika memilih Tidak
          },
          child: const Text('Tidak'),
        ),
        TextButton(
          onPressed: () async {
            final previewLabelViewModel = Provider.of<PreviewLabelViewModel>(context, listen: false);

            await previewLabelViewModel.fetchLabelData(nolabel);

            print("Label data: ${previewLabelViewModel.label}");

            if (previewLabelViewModel.label != null) {
              Navigator.of(context).pop();

              // Cek huruf pertama dari nolabel untuk menentukan tindakan selanjutnya
              if (nolabel.startsWith('E')) {
                // Jika nolabel dimulai dengan 'E', jalankan PDFViewModelS4S
                final pdfViewModel = Provider.of<PDFViewModelST>(context, listen: false);
                pdfViewModel.createAndPrintPDF(context, nolabel);
              } else if (nolabel.startsWith('R')) {
                // Jika nolabel dimulai dengan 'R', jalankan PDFViewModelST
                final pdfViewModel = Provider.of<PDFViewModelS4S>(context, listen: false);
                pdfViewModel.createAndPrintPDF(context, nolabel);
              }
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
