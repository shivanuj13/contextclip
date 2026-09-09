import 'package:flutter/widgets.dart';

/// Full-bleed single-point perspective grid — shallow open box / tunnel.
///
/// Drop behind app content. Geometry is fully procedural from [size], so it
/// adapts to any resizable desktop window. Static for v1; [parallaxOffset]
/// is reserved for a future slow drift without rewriting the painter.
class PerspectiveGridBackground extends StatelessWidget {
  const PerspectiveGridBackground({
    super.key,
    this.backRectFraction = const Rect.fromLTWH(0.4, 0.68, 0.2, 0.22),
    this.lineOpacity = 0.06,
    this.frameOpacity = 0.10,
    this.gridDensity = 6,
    this.depthRungs = 3,
    this.backGridDivisions = 2,
    this.strokeWidth = 0.6,
    this.backgroundColor = const Color(0xFF0C0C0A),
    this.lineColor = const Color(0xFFF2F2F0),
    this.parallaxOffset = Offset.zero,
    this.child,
  });

  /// Back panel in 0–1 relative canvas coords (left, top, width, height).
  final Rect backRectFraction;

  /// Opacity for radiating fill lines and depth rungs.
  final double lineOpacity;

  /// Opacity for corner connectors, back outline, and flat back grid.
  final double frameOpacity;

  /// Evenly spaced radiating lines per face (excluding the two frame edges).
  final int gridDensity;

  /// Cross-lines (ladder rungs) along each face at interpolated depths.
  final int depthRungs;

  /// Rows/columns inside the flat back panel grid.
  final int backGridDivisions;

  final double strokeWidth;
  final Color backgroundColor;
  final Color lineColor;

  /// Reserved for future drift/parallax — nudges [backRectFraction] in 0–1 space.
  final Offset parallaxOffset;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: backgroundColor),
        Positioned.fill(
          child: RepaintBoundary(
            child: IgnorePointer(
              child: CustomPaint(
                painter: PerspectiveGridPainter(
                  backRectFraction: backRectFraction,
                  lineOpacity: lineOpacity,
                  frameOpacity: frameOpacity,
                  gridDensity: gridDensity,
                  depthRungs: depthRungs,
                  backGridDivisions: backGridDivisions,
                  strokeWidth: strokeWidth,
                  lineColor: lineColor,
                  parallaxOffset: parallaxOffset,
                ),
                isComplex: true,
                willChange: false,
              ),
            ),
          ),
        ),
        ?child,
      ],
    );
  }
}

/// Draws a single-point perspective tunnel grid into [size].
class PerspectiveGridPainter extends CustomPainter {
  const PerspectiveGridPainter({
    this.backRectFraction = const Rect.fromLTWH(0.4, 0.68, 0.2, 0.22),
    this.lineOpacity = 0.06,
    this.frameOpacity = 0.10,
    this.gridDensity = 6,
    this.depthRungs = 3,
    this.backGridDivisions = 2,
    this.strokeWidth = 0.6,
    this.lineColor = const Color(0xFFF2F2F0),
    this.parallaxOffset = Offset.zero,
  });

  final Rect backRectFraction;
  final double lineOpacity;
  final double frameOpacity;
  final int gridDensity;
  final int depthRungs;
  final int backGridDivisions;
  final double strokeWidth;
  final Color lineColor;
  final Offset parallaxOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final back = _resolveBackRect(size);
    final screen = Offset.zero & size;

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = lineColor.withValues(alpha: lineOpacity);

    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth.clamp(0.5, 0.75)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = lineColor.withValues(alpha: frameOpacity);

    final fillPath = Path();
    final framePath = Path();

    // Four trapezoidal faces: screen edge → corresponding back edge.
    _paintFace(
      fill: fillPath,
      frame: framePath,
      frontA: screen.topLeft,
      frontB: screen.topRight,
      backA: back.topLeft,
      backB: back.topRight,
    );
    _paintFace(
      fill: fillPath,
      frame: framePath,
      frontA: screen.bottomLeft,
      frontB: screen.bottomRight,
      backA: back.bottomLeft,
      backB: back.bottomRight,
    );
    _paintFace(
      fill: fillPath,
      frame: framePath,
      frontA: screen.topLeft,
      frontB: screen.bottomLeft,
      backA: back.topLeft,
      backB: back.bottomLeft,
    );
    _paintFace(
      fill: fillPath,
      frame: framePath,
      frontA: screen.topRight,
      frontB: screen.bottomRight,
      backA: back.topRight,
      backB: back.bottomRight,
    );

    // Flat grid on the back panel.
    _paintBackGrid(framePath, back);

    // Back panel outline (frame).
    framePath
      ..moveTo(back.left, back.top)
      ..lineTo(back.right, back.top)
      ..lineTo(back.right, back.bottom)
      ..lineTo(back.left, back.bottom)
      ..close();

    // Four corner connectors (also drawn as face edges; re-stroke as frame).
    _line(framePath, screen.topLeft, back.topLeft);
    _line(framePath, screen.topRight, back.topRight);
    _line(framePath, screen.bottomLeft, back.bottomLeft);
    _line(framePath, screen.bottomRight, back.bottomRight);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(framePath, framePaint);
  }

  Rect _resolveBackRect(Size size) {
    final f = backRectFraction;
    final left = ((f.left + parallaxOffset.dx).clamp(0.0, 1.0)) * size.width;
    final top = ((f.top + parallaxOffset.dy).clamp(0.0, 1.0)) * size.height;
    final width = (f.width.clamp(0.02, 1.0)) * size.width;
    final height = (f.height.clamp(0.02, 1.0)) * size.height;
    return Rect.fromLTWH(
      left.clamp(0.0, size.width - width),
      top.clamp(0.0, size.height - height),
      width,
      height,
    );
  }

  void _paintFace({
    required Path fill,
    required Path frame,
    required Offset frontA,
    required Offset frontB,
    required Offset backA,
    required Offset backB,
  }) {
    final n = gridDensity.clamp(2, 64);

    // Radiating lines: lerp points along front edge → matching back edge.
    for (var i = 0; i <= n; i++) {
      final t = i / n;
      final front = Offset.lerp(frontA, frontB, t)!;
      final back = Offset.lerp(backA, backB, t)!;
      final isEdge = i == 0 || i == n;
      _line(isEdge ? frame : fill, front, back);
    }

    // Depth rungs: at several t along the recession, connect side edges.
    final rungs = depthRungs.clamp(0, 24);
    for (var i = 1; i <= rungs; i++) {
      final t = i / (rungs + 1);
      // Ease slightly so near-front rungs aren't cramped on the long bottom face.
      final depth = t * t;
      final left = Offset.lerp(frontA, backA, depth)!;
      final right = Offset.lerp(frontB, backB, depth)!;
      _line(fill, left, right);
    }
  }

  void _paintBackGrid(Path path, Rect back) {
    final d = backGridDivisions.clamp(1, 32);
    for (var i = 1; i < d; i++) {
      final t = i / d;
      final x = back.left + back.width * t;
      final y = back.top + back.height * t;
      _line(path, Offset(x, back.top), Offset(x, back.bottom));
      _line(path, Offset(back.left, y), Offset(back.right, y));
    }
  }

  void _line(Path path, Offset a, Offset b) {
    path
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy);
  }

  @override
  bool shouldRepaint(covariant PerspectiveGridPainter oldDelegate) {
    return oldDelegate.backRectFraction != backRectFraction ||
        oldDelegate.lineOpacity != lineOpacity ||
        oldDelegate.frameOpacity != frameOpacity ||
        oldDelegate.gridDensity != gridDensity ||
        oldDelegate.depthRungs != depthRungs ||
        oldDelegate.backGridDivisions != backGridDivisions ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.parallaxOffset != parallaxOffset;
  }
}
