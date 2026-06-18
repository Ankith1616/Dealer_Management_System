import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InteractivePaintBackground extends StatefulWidget {
  final Widget child;

  const InteractivePaintBackground({
    super.key,
    required this.child,
  });

  @override
  State<InteractivePaintBackground> createState() => _InteractivePaintBackgroundState();
}

class _InteractivePaintBackgroundState extends State<InteractivePaintBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset _pointerPosition = Offset.zero;
  Offset _smoothedPointerPosition = Offset.zero;

  // Configuration for background blobs
  final List<_BlobConfig> _blobs = [
    _BlobConfig(
      color: AppColors.primary,
      baseX: 0.15,
      baseY: 0.2,
      radius: 260.0,
      speed: 0.4,
      reactiveness: -0.05, // Repelled by cursor
    ),
    _BlobConfig(
      color: AppColors.secondary,
      baseX: 0.8,
      baseY: 0.75,
      radius: 300.0,
      speed: 0.35,
      reactiveness: 0.08, // Attracted by cursor
    ),
    _BlobConfig(
      color: const Color(0xFF00897B), // Teal
      baseX: 0.85,
      baseY: 0.15,
      radius: 240.0,
      speed: 0.5,
      reactiveness: -0.06,
    ),
    _BlobConfig(
      color: const Color(0xFFD81B60), // Deep pink
      baseX: 0.2,
      baseY: 0.8,
      radius: 280.0,
      speed: 0.45,
      reactiveness: 0.07,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onHover: (event) {
        setState(() {
          _pointerPosition = event.localPosition;
        });
      },
      child: Listener(
        onPointerMove: (event) {
          setState(() {
            _pointerPosition = event.localPosition;
          });
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Smoothly interpolate pointer position to create a lag/inertia effect
            _smoothedPointerPosition = Offset.lerp(
              _smoothedPointerPosition,
              _pointerPosition == Offset.zero
                  ? Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2)
                  : _pointerPosition,
              0.05,
            )!;

            return CustomPaint(
              painter: _PaintBackgroundPainter(
                blobs: _blobs,
                animationValue: _controller.value,
                pointerPosition: _smoothedPointerPosition,
                isDark: isDark,
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

class _BlobConfig {
  final Color color;
  final double baseX; // Normalized 0..1
  final double baseY; // Normalized 0..1
  final double radius;
  final double speed;
  final double reactiveness; // How much it shifts in response to cursor (positive = attracted, negative = repelled)

  _BlobConfig({
    required this.color,
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.speed,
    required this.reactiveness,
  });
}

class _PaintBackgroundPainter extends CustomPainter {
  final List<_BlobConfig> blobs;
  final double animationValue;
  final Offset pointerPosition;
  final bool isDark;

  _PaintBackgroundPainter({
    required this.blobs,
    required this.animationValue,
    required this.pointerPosition,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw base gradient background
    final baseGradient = LinearGradient(
      colors: isDark
          ? [const Color(0xFF0C091F), const Color(0xFF140D29), const Color(0xFF090614)]
          : [const Color(0xFFECE9E6), const Color(0xFFFFFFFF), const Color(0xFFE9E4F0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // Save layer to blend the blobs cleanly
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 2. Draw organic, flowing blobs
    for (final blob in blobs) {
      // Calculate current base center
      final cx = blob.baseX * size.width;
      final cy = blob.baseY * size.height;

      // Add dynamic float animation using sine/cosine curves
      final angle = animationValue * 2 * math.pi * blob.speed;
      final floatX = math.sin(angle) * 35.0;
      final floatY = math.cos(angle * 1.5) * 30.0;

      // Add mouse interaction displacement
      final dxToCursor = pointerPosition.dx - cx;
      final dyToCursor = pointerPosition.dy - cy;
      final shiftX = dxToCursor * blob.reactiveness;
      final shiftY = dyToCursor * blob.reactiveness;

      final blobCenter = Offset(cx + floatX + shiftX, cy + floatY + shiftY);

      // Create a smooth, blurred radial gradient for the blob
      final blobGradient = RadialGradient(
        colors: [
          blob.color.withValues(alpha: isDark ? 0.20 : 0.28),
          blob.color.withValues(alpha: 0.08),
          blob.color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final blobPaint = Paint()
        ..shader = blobGradient.createShader(
          Rect.fromCircle(center: blobCenter, radius: blob.radius),
        )
        ..blendMode = isDark ? BlendMode.screen : BlendMode.multiply;

      canvas.drawCircle(blobCenter, blob.radius, blobPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PaintBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pointerPosition != pointerPosition ||
        oldDelegate.isDark != isDark;
  }
}
