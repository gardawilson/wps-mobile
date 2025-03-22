import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../view_models/preview_label_view_model.dart';

class PDFViewModelS4S extends ChangeNotifier {

  // Fungsi untuk membuat dan mencetak PDF
  Future<void> createAndPrintPDF(BuildContext context, String nolabel) async {
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

              // Watermark "COPY" dengan efek dithering menggunakan pw.Container
              pw.Container(
                alignment: pw.Alignment.center,
                width: 500, // Full width
                height: 100, // Full height
                margin: pw.EdgeInsets.only(bottom: -250), // Mengatur margin top sebesar 10
                child: pw.Opacity(
                  opacity: 0.5, // Atur opacity untuk efek watermark
                  child: pw.Transform.rotate(
                    angle: 0, // Putar teks untuk efek yang lebih menarik
                    child: pw.Text(
                      'COPY',
                      style: pw.TextStyle(
                        fontSize: 150,
                        color: PdfColors.grey, // Warna abu-abu untuk efek dithering
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),


              // Tabel Header
              pw.Table(
                // border: pw.TableBorder.all(),
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
                // border: pw.TableBorder.all(),
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
                // border: pw.TableBorder.all(),
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
                        child: pw.Text(
                          '${label.noBongkarSusun?.isNotEmpty == true ? label.noBongkarSusun : (label.noProduksi?.isNotEmpty == true ? '${label.namaMesin} - ${label.noProduksi}' : 'No Label')}',
                          style: pw.TextStyle(fontSize: 18),
                        ),
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
                            // border: pw.TableBorder.all(),
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
                                      child: pw.Text('${label.total.jumlah}', style: pw.TextStyle(fontSize: 22)),
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
                                      child: pw.Text('m³', style: pw.TextStyle(fontSize: 22)),
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
                                      child: pw.Text('${label.total.m3}', style: pw.TextStyle(fontSize: 22)),
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
                              '${label.formatMMYY}',
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
                  // border: pw.TableBorder.all(),
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
}

// Fungsi untuk menghitung lebar teks
double _getTextWidth(String text, double fontSize) {
  // Perkiraan lebar teks berdasarkan font size
  // Catatan: Ini adalah perkiraan sederhana. Untuk akurasi yang lebih tinggi, gunakan font metrik.
  return text.length * (fontSize / 2);
}
