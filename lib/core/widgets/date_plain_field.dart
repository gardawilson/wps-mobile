import 'package:flutter/material.dart';

typedef YmdChanged = void Function(String? ymdValue);

class DatePlainField extends StatelessWidget {
  const DatePlainField({
    super.key,
    required this.valueYmd,          // nilai RAW 'yyyy-MM-dd' (boleh null)
    required this.onChangedYmd,      // callback hasil pilih tanggal (RAW)
    required this.formatter,         // (BuildContext, ymd) -> "Senin, 26 Oktober 2025"
    this.label = 'Tanggal',
    this.hint = 'Ketuk untuk memilih tanggal',
    this.helperText,
    this.validator,                  // validator pakai ymd
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.initialDate,                // fallback jika valueYmd null
    this.fieldHeight = 48,
    this.prefixIcon = Icons.date_range,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
  });

  final String? valueYmd;
  final YmdChanged onChangedYmd;
  final String Function(BuildContext, String) formatter;

  // UX
  final String label;
  final String hint;
  final String? helperText;
  final String? Function(String?)? validator;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final double fieldHeight;
  final IconData? prefixIcon;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final displayText = (valueYmd == null || valueYmd!.isEmpty)
        ? hint
        : formatter(context, valueYmd!);

    final displayColor = (valueYmd == null || valueYmd!.isEmpty)
        ? Colors.grey.shade600
        : Colors.black87;

    return FormField<String>(
      initialValue: valueYmd,
      validator: validator,
      builder: (field) {
        return InputDecorator(
          isFocused: false,
          decoration: InputDecoration(
            labelText: label,
            helperText: helperText,
            errorText: field.errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabled: enabled,
            isDense: true,
            contentPadding: contentPadding,
          ),
          child: InkWell(
            onTap: enabled ? () async {
              final now = DateTime.now();
              final init = valueYmd != null && valueYmd!.isNotEmpty
                  ? DateTime.tryParse(valueYmd!) ?? initialDate ?? now
                  : initialDate ?? now;

              final picked = await showDatePicker(
                context: context,
                initialDate: init,
                firstDate: firstDate ?? DateTime(2020),
                lastDate: lastDate ?? DateTime(now.year + 2),
              );

              if (picked != null) {
                final ymd =
                    '${picked.year.toString().padLeft(4, '0')}-'
                    '${picked.month.toString().padLeft(2, '0')}-'
                    '${picked.day.toString().padLeft(2, '0')}';
                onChangedYmd(ymd);
                // Inform FormField validator bahwa value berubah
                field.didChange(ymd);
              }
            } : null,
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: fieldHeight,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: displayColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
