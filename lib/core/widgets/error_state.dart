import 'package:flutter/material.dart';

/// Widget error state generik untuk seluruh aplikasi.
/// - Tampilkan saat terjadi kegagalan memuat data / proses.
/// - Opsional: tombol aksi (mis. "Coba lagi") via [primaryAction].
class ErrorState extends StatelessWidget {
  /// Judul utama (default: "Terjadi kesalahan")
  final String title;

  /// Pesan ringkas yang ramah pengguna
  final String message;

  /// Ikon yang ditampilkan (default: Icons.error_outline)
  final IconData icon;

  /// Warna ikon (default: Colors.redAccent)
  final Color? iconColor;

  /// Lebar maksimum konten (opsional)
  final double? maxContentWidth;

  /// Aksi utama opsional (mis. tombol "Coba lagi")
  final Widget? primaryAction;

  /// Konten tambahan opsional (mis. detail error teknis yang bisa di-expand)
  final Widget? extra;

  /// Spasi vertikal antar elemen
  final double spacing;

  const ErrorState({
    super.key,
    this.title = 'Terjadi kesalahan',
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.maxContentWidth,
    this.primaryAction,
    this.extra,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: iconColor ?? Colors.redAccent),
        SizedBox(height: spacing),
        Text(title, style: txt.titleMedium, textAlign: TextAlign.center),
        SizedBox(height: spacing / 2),
        Text(
          message,
          style: txt.bodyMedium?.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        if (extra != null) ...[
          SizedBox(height: spacing),
          extra!,
        ],
        if (primaryAction != null) ...[
          SizedBox(height: spacing),
          primaryAction!,
        ],
      ],
    );

    if (maxContentWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth!),
        child: content,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: content,
      ),
    );
  }
}
