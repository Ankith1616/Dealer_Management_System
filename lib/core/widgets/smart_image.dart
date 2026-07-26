import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const SmartImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return errorWidget ??
          const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey));
    }

    if (path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('blob:') ||
        path.startsWith('data:')) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
      );
    }

    // Local file path (file:/// or C:\... or /data/...)
    try {
      final cleanPath =
          path.startsWith('file://') ? Uri.parse(path).toFilePath() : path;
      if (!kIsWeb) {
        final file = File(cleanPath);
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            // Fallback try asset if file doesn't exist
            return Image.asset(
              path,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (context, error, stackTrace) =>
                  errorWidget ??
                  const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey)),
            );
          },
        );
      }
    } catch (_) {}

    return errorWidget ??
        const Center(
            child:
                Icon(Icons.image_not_supported_outlined, color: Colors.grey));
  }
}
