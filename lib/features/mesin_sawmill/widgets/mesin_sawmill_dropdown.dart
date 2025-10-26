// lib/features/mesin_sawmill/widgets/mesin_sawmill_dropdown.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/dropdown_field.dart';
import '../view_model/mesin_sawmill_view_model.dart';
import '../model/mesin_sawmill_model.dart';

class MesinSawmillDropdown extends StatelessWidget {
  const MesinSawmillDropdown({
    super.key,
    required this.onChanged,         // return noMeja (String?) atau null
    this.value,
    this.validator,
    this.labelText = 'Meja / Mesin',
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

  // API eksternal (tetap)
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  // Tampilan/UX
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
    return Consumer<MesinSawmillViewModel>(
      builder: (_, vm, __) {
        // Autoload sekali saat initial render
        if (autoload && vm.items.isEmpty && !vm.isLoading && vm.error.isEmpty) {
          vm.load();
        }

        // Sumber data: list value = noMeja (String)
        final List<String> values = vm.items
            .map((MesinSawmill m) => m.noMeja)
            .whereType<String>()
            .toList();

        String labelOf(String? noMeja) {
          if (noMeja == null) return '';
          final found = vm.items.where((m) => m.noMeja == noMeja).toList();
          if (found.isEmpty) return '($noMeja)';
          // toString() milik model dipakai sebagai label (konsisten dengan implementasi lama)
          return found.first.toString();
        }

        return DropdownPlainField<String>(
          // data
          items: values,
          value: values.contains(value) ? value : null, // aman saat preselect belum ada di list
          onChanged: onChanged,
          itemAsString: (v) => labelOf(v),

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

          // state (loading/error + retry)
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
