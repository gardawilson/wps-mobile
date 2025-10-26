import 'package:flutter/material.dart';

/// AppToast: helper SnackBar seragam untuk seluruh app.
class AppToast {
  AppToast._(); // no instance

  static void show(
      BuildContext context,
      String message, {
        Color? background,
        Color? textColor,
        Duration duration = const Duration(seconds: 2),
        SnackBarAction? action,
      }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    // Tutup toast sebelumnya biar nggak numpuk
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: action,
      ),
    );
  }

  /// Varian siap pakai
  static void success(BuildContext context, String message) {
    show(
      context,
      message,
      background: Colors.green.shade600,
      textColor: Colors.white,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      background: Colors.red.shade600,
      textColor: Colors.white,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message,
      background: Colors.grey.shade800,
      textColor: Colors.white,
    );
  }

  static void warning(BuildContext context, String message) {
    show(
      context,
      message,
      background: Colors.orange.shade600,
      textColor: Colors.white,
    );
  }
}