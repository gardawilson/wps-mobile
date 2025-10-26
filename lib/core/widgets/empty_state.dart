import 'package:flutter/material.dart';

/// Widget empty state generik untuk seluruh aplikasi.
/// - Gunakan pada layar/list kosong, hasil pencarian kosong, dsb.
/// - Opsional: tambahkan tombol aksi (mis. "Coba lagi") via [primaryAction].
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  /// Warna ikon (default: Colors.black26)
  final Color? iconColor;

  /// Lebar maksimum konten di tengah (default: tidak dibatasi)
  final double? maxContentWidth;

  /// Aksi utama opsional (mis. tombol "Coba lagi")
  final Widget? primaryAction;

  /// Spasi vertikal antar elemen
  final double spacing;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.maxContentWidth,
    this.primaryAction,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: iconColor ?? Colors.black26),
        SizedBox(height: spacing),
        Text(title, style: txt.titleMedium, textAlign: TextAlign.center),
        SizedBox(height: spacing / 2),
        Text(
          subtitle,
          style: txt.bodyMedium?.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
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
