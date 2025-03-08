import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/stock_opname_input_view_model.dart';
import 'not_found_dialog.dart'; // Import widget NotFoundDialog
import 'print_confirmation_dialog.dart';


class AddManualDialog extends StatefulWidget {
  final String noSO;
  final String idLokasi;
  final String selectedFilter; // Menambahkan parameter selectedFilter

  const AddManualDialog({
    super.key,
    required this.noSO,
    required this.idLokasi,
    required this.selectedFilter, // Pastikan parameter ini diterima
  });

  @override
  State<AddManualDialog> createState() => _AddManualDialogState();
}

class _AddManualDialogState extends State<AddManualDialog> {
  final TextEditingController _labelController = TextEditingController();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    _labelController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid = _labelController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _labelController.removeListener(_validateForm);
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StockOpnameInputViewModel>(context);

    return AlertDialog(
      title: const Text('Tambah Data Manual'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Text(
                  'No SO: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.noSO),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Text(
                  'Lokasi: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.idLokasi),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              hintText: 'Masukkan Label',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            viewModel.resetBlokAndLokasi();
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: isFormValid
              ? () {
            viewModel.processScannedCode(
              _labelController.text.trim().toUpperCase(),
              widget.idLokasi,
              widget.noSO,
              onSaveComplete: (success, statusCode, message) {
                if (success) {
                  final viewModel = Provider.of<StockOpnameInputViewModel>(context, listen: false);
                  viewModel.fetchData(
                      widget.noSO,
                      filterBy: widget.selectedFilter,
                      idLokasi: widget.idLokasi
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );

                  // // Menampilkan dialog konfirmasi print ulang label
                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return PrintConfirmationDialog(
                  //       onPrint: () {
                  //         // Panggil fungsi untuk mencetak ulang label
                  //       },
                  //     );
                  //   },
                  // );

                } else {
                  if (statusCode == 404 || statusCode == 409) {
                    // Menangani statusCode 404 dengan dialog konfirmasi
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NotFoundDialog(
                          message: message, // Pesan error dari API
                          onConfirm: () {
                            // Lanjutkan pemrosesan jika user pilih "Ya"
                            viewModel.processScannedCode(
                              _labelController.text.trim().toUpperCase(),
                              widget.idLokasi,
                              widget.noSO,
                              onSaveComplete: (success, statusCode, message) {
                                if (success) {

                                  final viewModel = Provider.of<StockOpnameInputViewModel>(context, listen: false);
                                  viewModel.fetchData(
                                      widget.noSO,
                                      filterBy: widget.selectedFilter,
                                      idLokasi: widget.idLokasi
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );

                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                }
                              },
                              forceSave: true, // Flag untuk memaksa penyimpanan meskipun data tidak ada
                            );
                          },
                        );
                      },
                    );
                  }
                  else {
                    // Menampilkan error dengan snackbar jika status code selain 404
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                }
              },
            );
            Navigator.of(context).pop();
          }
              : null,
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
