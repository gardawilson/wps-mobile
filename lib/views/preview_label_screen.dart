// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../view_models/preview_label_view_model.dart';
// import '../view_models/pdf_view_model.dart';
//
// class LabelPreviewPage extends StatelessWidget {
//   final String nolabel;
//
//   const LabelPreviewPage({Key? key, required this.nolabel}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Preview Label')),
//       body: Consumer<PreviewLabelViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (viewModel.errorMessage != null) {
//             return Center(child: Text(viewModel.errorMessage!));
//           }
//
//           final label = viewModel.label;
//           if (label == null) {
//             return const Center(child: Text('Label not found'));
//           }
//
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView(
//               children: [
//                 // Menampilkan data header
//                 Text('No: ${nolabel}', style: const TextStyle(fontSize: 18)),
//                 Text('SPK: ${label.noSPK}', style: const TextStyle(fontSize: 18)),
//                 Text('Grade: ${label.namaGrade}', style: const TextStyle(fontSize: 18)),
//                 Text('Tgl: ${label.dateCreate} (${label.jam})', style: const TextStyle(fontSize: 18)),
//                 Text('Telly: ${label.namaOrgTelly}', style: const TextStyle(fontSize: 18)),
//                 Text('Mesin: ${label.namaMesin} - ${label.noProduksi}', style: const TextStyle(fontSize: 18)),
//                 Text('Fisik: ${label.namaWarehouse}', style: const TextStyle(fontSize: 18)),
//                 Text('Jenis: ${label.jenis}', style: const TextStyle(fontSize: 18)),
//                 Text('Is Lembur: ${label.isLembur ? "Yes" : "No"}', style: const TextStyle(fontSize: 18)),
//                 Text('Is Reject: ${label.isReject ? "Yes" : "No"}', style: const TextStyle(fontSize: 18)),
//                 Text('Remark: ${label.remark}', style: const TextStyle(fontSize: 18)),
//                 const SizedBox(height: 40),
//
//                 // Menampilkan data detail
//                 const Text('Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 10),
//                 ...label.details.map((detail) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Tebal: ${detail.tebal}', style: const TextStyle(fontSize: 16)),
//                       Text('Lebar: ${detail.lebar}', style: const TextStyle(fontSize: 16)),
//                       Text('Panjang: ${detail.panjang}', style: const TextStyle(fontSize: 16)),
//                       Text('Jumlah Batang: ${detail.jmlhBatang}', style: const TextStyle(fontSize: 16)),
//                       const SizedBox(height: 10), // Space between details
//                     ],
//                   );
//                 }).toList(),
//
//                 // Tombol untuk print PDF
//                 ElevatedButton(
//                   onPressed: () {
//                     final pdfViewModel = Provider.of<PDFViewModel>(context, listen: false);
//                     pdfViewModel.createAndPrintPDF(context, nolabel); // Panggil fungsi yang dibutuhkan
//                   },
//                   child: const Text('Print Label'),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
