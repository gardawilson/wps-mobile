import 'package:flutter/material.dart';

class DatePickerField extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.onChangedYmd, // callback "YYYY-MM-DD" atau null
    this.initialYmd,
    this.hintText,
    this.required = false,
    this.firstDate,
    this.lastDate,
    this.showWeekday = true,   // true -> "Senin, 28 Okt 2025", false -> "28 Okt 2025"
    this.validator,
    this.enabled = true,
  });

  final String label;
  final String? hintText;
  final bool required;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showWeekday;
  final bool enabled;

  final String? initialYmd;                  // "YYYY-MM-DD"
  final ValueChanged<String?> onChangedYmd;  // hasil "YYYY-MM-DD" / null
  final String? Function(String? ymd)? validator;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late TextEditingController _displayCtrl;
  String? _currentYmd;

  @override
  void initState() {
    super.initState();
    _displayCtrl = TextEditingController();
    _setFromYmd(widget.initialYmd);
  }

  @override
  void didUpdateWidget(covariant DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialYmd != widget.initialYmd) {
      _setFromYmd(widget.initialYmd);
    }
  }

  @override
  void dispose() {
    _displayCtrl.dispose();
    super.dispose();
  }

  String _toYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  DateTime? _parseYmd(String? ymd) {
    if (ymd == null || ymd.isEmpty) return null;
    try {
      return DateTime.parse(ymd);
    } catch (_) {
      return null;
    }
  }

  // --- FIX: hindari duplikasi weekday ---
  String _formatDisplay(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);

    final medium = loc.formatMediumDate(d);
    if (!widget.showWeekday) return medium;

    // weekday full dari formatFullDate: ambil sebelum koma
    final full = loc.formatFullDate(d);
    final commaIdx = full.indexOf(',');
    final weekdayFull = (commaIdx >= 0 ? full.substring(0, commaIdx) : full.split(RegExp(r'\s+')).first).trim();

    // medium bisa diawali weekday singkat (contoh EN: "Wed, Oct 29, 2025")
    String normalizedMedium = medium;
    final mComma = medium.indexOf(',');
    if (mComma > 0) {
      final head = medium.substring(0, mComma).trim(); // contoh "Wed"
      final headLower = head.toLowerCase();
      final wfLower   = weekdayFull.toLowerCase();
      final wfAbbr    = (weekdayFull.length >= 3) ? weekdayFull.substring(0, 3).toLowerCase() : wfLower;

      if (headLower == wfLower || headLower == wfAbbr) {
        final after = medium.substring(mComma + 1).trimLeft(); // buang "Wed, "
        if (after.isNotEmpty) normalizedMedium = after;
      }
    }

    return '$weekdayFull, $normalizedMedium';
  }

  void _setFromYmd(String? ymd) {
    _currentYmd = ymd;
    final d = _parseYmd(ymd);
    if (!mounted) return;
    _displayCtrl.text = (d == null) ? '' : _formatDisplay(context, d);
  }

  Future<void> _pick() async {
    if (!widget.enabled) return;
    final now   = DateTime.now();
    final init  = _parseYmd(_currentYmd) ?? now;
    final first = widget.firstDate ?? DateTime(2000);
    final last  = widget.lastDate  ?? DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      final ymd = _toYmd(picked);
      setState(() {
        _currentYmd = ymd;
        _displayCtrl.text = _formatDisplay(context, picked);
      });
      widget.onChangedYmd(ymd);
    }
  }

  String? _defaultValidator(String? ymd) {
    if (!widget.required) return null;
    if (ymd == null || ymd.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final validator = widget.validator ?? _defaultValidator;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label + (widget.required ? ' *' : ''),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _displayCtrl,
          readOnly: true,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Pilih tanggal',
            suffixIcon: IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: widget.enabled ? _pick : null,
            ),
            border: const OutlineInputBorder(),
          ),
          onTap: _pick,
          validator: (_) => validator(_currentYmd),
        ),
      ],
    );
  }
}
