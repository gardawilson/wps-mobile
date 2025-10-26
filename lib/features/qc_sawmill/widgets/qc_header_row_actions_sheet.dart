// lib/features/qc_sawmill/widgets/qc_header_row_actions_sheet.dart
import 'package:flutter/material.dart';
import '../model/qc_sawmill_header.dart';

enum QcRowAction { edit, delete }

Future<QcRowAction?> showQcHeaderRowActionsSheet(
    BuildContext context, {
      required QcSawmillHeader row,
    }) {
  return showModalBottomSheet<QcRowAction>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: Colors.white, // ⬅️ background putih
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Judul: NoQC saja
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                row.noQc,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),

            // Opsi: Edit
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(ctx, QcRowAction.edit),
            ),
            const Divider(height: 1),

            // Opsi: Hapus (destruktif)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline, color: cs.error),
              title: Text('Hapus', style: TextStyle(color: cs.error)),
              onTap: () => Navigator.pop(ctx, QcRowAction.delete),
            ),
          ],
        ),
      );
    },
  );
}
