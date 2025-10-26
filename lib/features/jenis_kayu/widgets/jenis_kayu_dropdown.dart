// lib/features/jenis_kayu/widgets/jenis_kayu_dropdown.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/dropdown_field.dart';
import '../view_model/jenis_kayu_view_model.dart';

class JenisKayuDropdown extends StatelessWidget {
  const JenisKayuDropdown({
    super.key,
    required this.onChanged,
    this.value,
    this.validator,
    this.labelText = 'Jenis Kayu',
    this.hintText = 'PILIH',
    this.prefixIcon,
    this.helperText,
    this.autoload = true,
    this.enabled = true,
    this.isExpanded = true,
    this.fieldHeight = 48,
    this.popupMaxHeight = 500,
    this.autovalidateMode,
  });

  // API eksternal tetap sama
  final int? value;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;

  // Tampilan (disalurkan ke DropdownPlainField)
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final String? helperText;
  final bool enabled;
  final bool isExpanded;
  final double fieldHeight;
  final double popupMaxHeight;
  final AutovalidateMode? autovalidateMode;

  // Data loading
  final bool autoload;

  @override
  Widget build(BuildContext context) {
    return Consumer<JenisKayuViewModel>(
      builder: (_, vm, __) {
        // Autoload sekali saat pertama render (jika belum ada data & tidak sedang loading & tidak error)
        if (autoload && vm.items.isEmpty && !vm.isLoading && vm.error.isEmpty) {
          vm.load();
        }

        // Siapkan sumber data: kita pakai LIST OF ID (int) agar API eksternal tetap value:int?
        final List<int> idItems = vm.items
            .map((e) => e.idJenisKayu)
            .whereType<int>()
            .toList();

        String _labelOf(int? id) {
          if (id == null) return '';
          final found = vm.items.where((e) => e.idJenisKayu == id).toList();
          if (found.isEmpty) return '($id)';
          // Model kamu sebelumnya sudah pakai jk.toString() → aman dipakai lagi.
          return found.first.toString();
        }

        return DropdownPlainField<int>(
          // data
          items: idItems,
          value: idItems.contains(value) ? value : null, // jaga bila preselect tidak ada di list
          onChanged: onChanged,
          itemAsString: (id) => _labelOf(id),

          // UX & form
          label: labelText,
          hint: hintText,
          prefixIcon: prefixIcon,
          enabled: enabled,
          isExpanded: isExpanded,
          fieldHeight: fieldHeight,
          validator: validator,
          autovalidateMode: autovalidateMode,
          helperText: helperText,

          // state (loading/error)
          isLoading: vm.isLoading && vm.items.isEmpty,
          fetchError: vm.error.isNotEmpty && vm.items.isEmpty,
          fetchErrorText: vm.error.isNotEmpty ? vm.error : null,
          onRetry: () => vm.load(force: true),

          // style
          popupMaxHeight: popupMaxHeight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),

          // compare
          compareFn: (a, b) => a == b,
        );
      },
    );
  }
}
