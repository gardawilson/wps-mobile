import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final File? file;
  final String? url;

  const FullScreenImage({super.key, this.file, this.url});

  // factory constructor untuk buka dari File
  factory FullScreenImage.file(File file) {
    return FullScreenImage(file: file);
  }

  // factory constructor untuk buka dari URL
  factory FullScreenImage.network(String url) {
    return FullScreenImage(url: url);
  }

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget;

    if (file != null) {
      imageWidget = Image.file(file!);
    } else if (url != null) {
      imageWidget = Image.network(url!);
    } else {
      imageWidget = const Icon(Icons.broken_image, color: Colors.white, size: 64);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: imageWidget,
        ),
      ),
    );
  }
}
