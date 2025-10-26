import 'package:flutter/material.dart';

/// Dialog konfirmasi generik yang bisa dipakai di mana saja.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final bool destructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = 'Batal',
    this.confirmText = 'OK',
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(cancelText),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: destructive
                        ? Colors.red.shade500
                        : Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper: tampilkan ConfirmDialog dan kembalikan true/false/null
Future<bool?> showConfirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      String cancelText = 'Batal',
      String confirmText = 'OK',
      bool destructive = false,
    }) {
  return showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: confirmText,
      destructive: destructive,
    ),
  );
}

/// Helper spesifik untuk hapus QC Header
Future<bool?> showDeleteQcHeaderConfirm(
    BuildContext context, {
      required String noQc,
    }) {
  return showConfirmDialog(
    context,
    title: 'Hapus Data',
    message: 'Yakin menghapus data $noQc?',
    confirmText: 'Hapus',
    destructive: true,
  );
}