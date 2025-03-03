import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/stock_opname_input_view_model.dart';

class AddManualDialog extends StatefulWidget {
  final String noSO; // Diterima dari halaman utama

  const AddManualDialog({super.key, required this.noSO});

  @override
  State<AddManualDialog> createState() => _AddManualDialogState();
}

class _AddManualDialogState extends State<AddManualDialog> {
  final TextEditingController _labelController = TextEditingController();
  bool isFormValid = false; // Untuk validasi tombol

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
          // Dropdown Pilih Blok
          DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Pilih Blok'),
            value: viewModel.blok.isEmpty ? null : viewModel.blok,
            items: viewModel.blokList.map((blokData) => blokData.blok).toSet().map((blok) {
              return DropdownMenuItem<String>(
                value: blok,
                child: Text(blok),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.updateBlokAndLokasi(value);
                setState(() {}); // Perbarui UI agar tombol aktif
              }
            },
          ),
          const SizedBox(height: 16),

          // Dropdown Pilih ID Lokasi
          DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Pilih ID Lokasi'),
            value: viewModel.idLokasi.isEmpty ? null : viewModel.idLokasi,
            items: viewModel.blokList
                .where((blokData) => blokData.blok == viewModel.blok)
                .map((blokData) {
              return DropdownMenuItem<String>(
                value: blokData.idLokasi,
                child: Text(blokData.idLokasi),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.idLokasi = value;
                viewModel.notifyListeners();
                setState(() {}); // Perbarui UI agar tombol aktif
              }
            },
          ),
          const SizedBox(height: 16),

          // Input Text Manual
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
          onPressed: viewModel.blok.isNotEmpty &&
              viewModel.idLokasi.isNotEmpty &&
              isFormValid
              ? () {
            viewModel.processScannedCode(
              _labelController.text.trim().toUpperCase(),
              viewModel.blok,
              viewModel.idLokasi,
              widget.noSO,
              onSaveComplete: (success, message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
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
