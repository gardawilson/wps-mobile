import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../view_models/preview_label_view_model.dart';

class LabelPreviewPage extends StatelessWidget {
  final String nolabel;

  const LabelPreviewPage({Key? key, required this.nolabel}) : super(key: key);

  Future<void> _createAndPrintPDF(BuildContext context) async {
    final viewModel = Provider.of<PreviewLabelViewModel>(context, listen: false);
    final label = viewModel.label;

    if (label == null) return;

    final pdf = pw.Document();

    // Menambahkan halaman ke dokumen PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [

              // Tabel Header
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1), // Kolom untuk tanda ':'

                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          'LABEL S4S',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(
                          'NO   : ${nolabel}',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            decoration: pw.TextDecoration.underline, // Menambahkan underline
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Membuat tabel dengan 6 kolom (3 untuk kiri dan 3 untuk kanan)
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(0.8),
                  1: pw.FlexColumnWidth(0.1), // Kolom untuk tanda ':'
                  2: pw.FlexColumnWidth(1.8),
                  3: pw.FlexColumnWidth(0.6),
                  4: pw.FlexColumnWidth(0.1), // Kolom untuk tanda ':'
                  5: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Jenis', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                        child: pw.Text(':', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('${label.jenis}', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Tgl', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                        child: pw.Text(':', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('${label.dateCreate} (${label.jam})', style: pw.TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Grade', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                        child: pw.Text(':', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('${label.namaGrade}', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Telly', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                        child: pw.Text(':', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('${label.namaOrgTelly}', style: pw.TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Fisik', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                        child: pw.Text(':', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('${label.namaWarehouse}', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('SPK', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                        child: pw.Text(':', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('${label.noSPK}', style: pw.TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 5),

              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(0.8),
                  1: pw.FlexColumnWidth(0.1), // Kolom untuk tanda ':'
                  2: pw.FlexColumnWidth(4.5),

                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Mesin', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                        child: pw.Text(':', style: pw.TextStyle(fontSize: 18)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('${label.namaMesin} - ${label.noProduksi}', style: pw.TextStyle(fontSize: 18)), // Kolom kosong setelah tanda ':'
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 5),

              // Tabel Detail
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Center(child: pw.Text('Tebal', style: pw.TextStyle(fontSize: 20))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Center(child: pw.Text('Lebar', style: pw.TextStyle(fontSize: 20))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Center(child: pw.Text('Panjang', style: pw.TextStyle(fontSize: 20))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Center(child: pw.Text('Pcs', style: pw.TextStyle(fontSize: 20))),
                      ),
                    ],
                  ),
                  ...label.details.map((detail) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Center(child: pw.Text('${detail.tebal} mm', style: pw.TextStyle(fontSize: 20))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Center(child: pw.Text('${detail.lebar} mm', style: pw.TextStyle(fontSize: 20))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Center(child: pw.Text('${detail.panjang} mm', style: pw.TextStyle(fontSize: 20))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Center(child: pw.Text('${detail.jmlhBatang}', style: pw.TextStyle(fontSize: 20))),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 10),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start, // Align item ke atas
                children: [
                  // QR Code dengan margin kiri
                  pw.Align(
                    alignment: pw.Alignment.topLeft, // Align QR code ke atas
                    child: pw.Container(
                      margin: pw.EdgeInsets.only(left: 50), // Menambahkan margin kiri sebesar 20
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: nolabel,
                        width: 145,
                        height: 145,
                        padding: pw.EdgeInsets.all(0),
                      ),
                    ),
                  ),


                  // Tabel baru di sebelah kanan QR Code (jumlah dan m3)
                  pw.SizedBox(width: 10), // Menambahkan jarak antara QR code dan tabel
                  pw.Expanded(
                    child: pw.Align(
                      alignment: pw.Alignment.topLeft, // Align tabel ke atas
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start, // Align tabel secara vertikal
                        children: [
                          // Tabel pertama (Jumlah dan M3)
                          pw.Table(
                            border: pw.TableBorder.all(),
                            columnWidths: {
                              0: pw.FlexColumnWidth(1.9),
                              1: pw.FlexColumnWidth(0.1),
                              2: pw.FlexColumnWidth(1),
                            },
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4.0),
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerRight, // Mengatur teks ke align right
                                      child: pw.Text('Jumlah', style: pw.TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                                    child: pw.Text(':', style: pw.TextStyle(fontSize: 22)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4.0),
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft, // Mengatur teks ke align right
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4.0),
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerRight, // Mengatur teks ke align right
                                      child: pw.Text('M3', style: pw.TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.fromLTRB(1, 4, 1, 4), // Kiri: 1, Top: 4, Kanan: 1, Bottom: 4
                                    child: pw.Text(':', style: pw.TextStyle(fontSize: 22)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4.0),
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft, // Mengatur teks ke align right
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          pw.Container(
                            alignment: pw.Alignment.centerRight,
                            width: double.infinity,
                            margin: pw.EdgeInsets.only(top: -10), // Mengatur margin top menjadi 20
                            padding: pw.EdgeInsets.symmetric(vertical: 0), // Padding tetap 0
                            child: pw.Text(
                              '0125',
                              style: pw.TextStyle(
                                fontSize: 85,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Tabel kedua (contoh tambahan tabel lain di bawah)
              pw.Container(
                margin: pw.EdgeInsets.only(top: -10),
                child: pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1.7),
                    1: pw.FlexColumnWidth(0.2),
                    2: pw.FlexColumnWidth(0.6),
                    3: pw.FlexColumnWidth(0.1),
                    4: pw.FlexColumnWidth(0.6),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1.0),
                          child: pw.Center(child: pw.Text('${nolabel}', style: pw.TextStyle(fontSize: 22))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1.0),
                          child: pw.Center(child: pw.Text('', style: pw.TextStyle(fontSize: 20))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1.0),
                          child: pw.Center(
                            child: pw.Text(
                              label.isReject ? 'Reject' : '', // Menampilkan 'Lembur' jika islembur == true
                              style: pw.TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1.0),
                          child: pw.Center(child: pw.Text('', style: pw.TextStyle(fontSize: 20))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1.0),
                          child: pw.Center(
                            child: pw.Text(
                              label.isLembur ? 'Lembur' : '', // Menampilkan 'Lembur' jika islembur == true
                              style: pw.TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (label.remark?.isNotEmpty ?? false) ...[
                pw.Container(
                  alignment: pw.Alignment.center,
                  width: double.infinity, // Full width
                  margin: pw.EdgeInsets.only(top: 10), // Mengatur margin top sebesar 10
                  child: pw.Text(
                    'Remark: ${label.remark}',
                    style: pw.TextStyle(fontSize: 22),
                  ),
                ),
              ],

            ],
          );
        },
      ),
    );

    // Mencetak dokumen PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Label')),
      body: Consumer<PreviewLabelViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          final label = viewModel.label;
          if (label == null) {
            return const Center(child: Text('Label not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Menampilkan data header
                Text('No: ${nolabel}', style: const TextStyle(fontSize: 18)),
                Text('SPK: ${label.noSPK}', style: const TextStyle(fontSize: 18)),
                Text('Grade: ${label.namaGrade}', style: const TextStyle(fontSize: 18)),
                Text('Tgl: ${label.dateCreate} (${label.jam})', style: const TextStyle(fontSize: 18)),
                Text('Telly: ${label.namaOrgTelly}', style: const TextStyle(fontSize: 18)),
                Text('Mesin: ${label.namaMesin} - ${label.noProduksi}', style: const TextStyle(fontSize: 18)),
                Text('Fisik: ${label.namaWarehouse}', style: const TextStyle(fontSize: 18)),
                Text('Jenis: ${label.jenis}', style: const TextStyle(fontSize: 18)),
                Text('Is Lembur: ${label.isLembur ? "Yes" : "No"}', style: const TextStyle(fontSize: 18)),
                Text('Is Reject: ${label.isReject ? "Yes" : "No"}', style: const TextStyle(fontSize: 18)),
                Text('Remark: ${label.remark}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 40),

                // Menampilkan data detail
                const Text('Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...label.details.map((detail) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tebal: ${detail.tebal}', style: const TextStyle(fontSize: 16)),
                      Text('Lebar: ${detail.lebar}', style: const TextStyle(fontSize: 16)),
                      Text('Panjang: ${detail.panjang}', style: const TextStyle(fontSize: 16)),
                      Text('Jumlah Batang: ${detail.jmlhBatang}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10), // Space between details
                    ],
                  );
                }).toList(),

                // Tombol untuk print PDF
                ElevatedButton(
                  onPressed: () {
                    _createAndPrintPDF(context); // Panggil fungsi untuk membuat dan mencetak PDF
                  },
                  child: const Text('Print Label'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
