import 'package:flutter/material.dart';

class ProductImageView extends StatelessWidget {
  final String? imagePath;
  final BoxFit fit;
  final Widget? fallback;

  const ProductImageView({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null || path.isEmpty) {
      return fallback ?? const SizedBox.shrink();
    }

    // Check if it's a local asset path
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback ?? const SizedBox.shrink(),
      );
    } else if (!path.startsWith('http://') && !path.startsWith('https://')) {
      // Path without 'assets/' prefix—assume it's a local asset
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback ?? const SizedBox.shrink(),
      );
    }

    // Otherwise, it's a network URL
    return Image.network(
      path,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback ?? const SizedBox.shrink(),
    );
  }
}
