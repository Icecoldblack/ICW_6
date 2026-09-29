// In-Class Activity 06: Drawing with Flutter
// Student: Uyiosa Nehikhuere
// Date: September 29, 2026
//
// SmileyPainter and the FaceConfig it draws.
// Every coordinate is based on the canvas size or the face radius,
// so the drawing scales on any phone size or orientation.

import 'dart:math' show pi;

import 'package:flutter/material.dart';

/// The named designs in the Level 3 gallery.
enum FaceType { classic, sleepy, surprised }

extension FaceTypeLabel on FaceType {
  String get label {
    switch (this) {
      case FaceType.classic:
        return 'Classic';
      case FaceType.sleepy:
        return 'Sleepy';
      case FaceType.surprised:
        return 'Surprised';
    }
  }
}

/// Every value the painter needs. The widget owns this in state and
/// passes a new copy to the painter each time something changes.
@immutable
class FaceConfig {
  const FaceConfig({
    this.type = FaceType.classic,
    this.mood = 0.8,
    this.eyeSize = 0.08,
    this.eyeGap = 0.35,
    this.blush = false,
    this.hat = false,
    this.glasses = false,
    this.mustache = false,
  });

  final FaceType type;
  final double mood; // 0.0 sad to 1.0 happy
  final double eyeSize; // eye radius as a fraction of the face radius
  final double eyeGap; // eye distance from center as a fraction of radius
  final bool blush;
  final bool hat;
  final bool glasses;
  final bool mustache;

  FaceConfig copyWith({
    FaceType? type,
    double? mood,
    double? eyeSize,
    double? eyeGap,
    bool? blush,
    bool? hat,
    bool? glasses,
    bool? mustache,
  }) {
    return FaceConfig(
      type: type ?? this.type,
      mood: mood ?? this.mood,
      eyeSize: eyeSize ?? this.eyeSize,
      eyeGap: eyeGap ?? this.eyeGap,
      blush: blush ?? this.blush,
      hat: hat ?? this.hat,
      glasses: glasses ?? this.glasses,
      mustache: mustache ?? this.mustache,
    );
  }

  /// Level 2 mood bands for the face color.
  Color get faceColor {
    if (mood < 0.35) return const Color(0xFF90CAF9); // cool blue
    if (mood <= 0.7) return const Color(0xFFFFD54F); // yellow
    return const Color(0xFFFFA726); // warm orange
  }

  String get moodLabel {
    if (mood < 0.35) return 'Sad';
    if (mood <= 0.7) return 'Neutral';
    return 'Happy';
  }

  @override
  bool operator ==(Object other) {
    return other is FaceConfig &&
        other.type == type &&
        other.mood == mood &&
        other.eyeSize == eyeSize &&
        other.eyeGap == eyeGap &&
        other.blush == blush &&
        other.hat == hat &&
        other.glasses == glasses &&
        other.mustache == mustache;
  }

  @override
  int get hashCode => Object.hash(
      type, mood, eyeSize, eyeGap, blush, hat, glasses, mustache);
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({required this.config});

  final FaceConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    // Anchors: everything below is measured from these two values.
    final Offset c = Offset(size.width / 2, size.height / 2);
    // shortestSide keeps the face fully visible in portrait and landscape.
    // 0.36 (not 0.40) leaves headroom so the hat never gets clipped.
    final double r = size.shortestSide * 0.36;

    final Offset leftEye = Offset(c.dx - r * config.eyeGap, c.dy - r * 0.18);
    final Offset rightEye = Offset(c.dx + r * config.eyeGap, c.dy - r * 0.18);
    final double eyeR = r * config.eyeSize;

    // Painter's algorithm: bottom layer first, top layer last.
    _drawFace(canvas, c, r);
    if (config.blush) _drawBlush(canvas, c, r);
    _drawEyes(canvas, c, r, leftEye, rightEye, eyeR);
    _drawMouth(canvas, c, r);
    if (config.mustache) _drawMustache(canvas, c, r);
    if (config.glasses) _drawGlasses(canvas, r, leftEye, rightEye, eyeR);
    if (config.hat) _drawHat(canvas, c, r);
  }

  // 1) Face fill + border
  void _drawFace(Canvas canvas, Offset c, double r) {
    final facePaint = Paint()
      ..color = config.faceColor
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04;
    canvas.drawCircle(c, r, facePaint);
    canvas.drawCircle(c, r, border);
  }

  // 2) Blush ovals
  void _drawBlush(Canvas canvas, Offset c, double r) {
    final blushPaint = Paint()..color = const Color(0x66F06292);
    for (final side in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + side * r * 0.58, c.dy + r * 0.12),
          width: r * 0.30,
          height: r * 0.15,
        ),
        blushPaint,
      );
    }
  }

  // 3) Eyes (and brows for Surprised)
  void _drawEyes(Canvas canvas, Offset c, double r, Offset leftEye,
      Offset rightEye, double eyeR) {
    final eyePaint = Paint()..color = Colors.black87;
    switch (config.type) {
      case FaceType.classic:
        canvas.drawCircle(leftEye, eyeR, eyePaint);
        canvas.drawCircle(rightEye, eyeR, eyePaint);
        break;

      case FaceType.sleepy:
        // Closed eyes: the bottom half of a small ellipse, drawn as a stroke.
        final lidPaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.04;
        for (final eye in [leftEye, rightEye]) {
          final rect = Rect.fromCenter(
              center: eye, width: eyeR * 3, height: eyeR * 1.6);
          canvas.drawArc(rect, 0, pi, false, lidPaint);
        }
        _drawSleepyZ(canvas, c, r);
        break;

      case FaceType.surprised:
        // Big white eyes with pupils, plus raised brows.
        final bigR = eyeR * 1.6;
        final white = Paint()..color = Colors.white;
        final outline = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.025;
        for (final eye in [leftEye, rightEye]) {
          canvas.drawCircle(eye, bigR, white);
          canvas.drawCircle(eye, bigR, outline);
          canvas.drawCircle(eye, bigR * 0.45, eyePaint);
        }
        final brow = Paint()
          ..color = Colors.black87
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.04;
        final browY = leftEye.dy - bigR - r * 0.12;
        canvas.drawLine(Offset(leftEye.dx - bigR, browY + r * 0.03),
            Offset(leftEye.dx + bigR, browY - r * 0.03), brow);
        canvas.drawLine(Offset(rightEye.dx - bigR, browY - r * 0.03),
            Offset(rightEye.dx + bigR, browY + r * 0.03), brow);
        break;
    }
  }

  // 4) Mouth
  void _drawMouth(Canvas canvas, Offset c, double r) {
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.06;

    switch (config.type) {
      case FaceType.classic:
        _drawMoodArc(canvas, c, r, mouthPaint);
        break;

      case FaceType.sleepy:
        // Small soft smile that is always calm.
        final rect = Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.35),
          width: r * 0.45,
          height: r * 0.15,
        );
        canvas.drawArc(rect, 0, pi, false, mouthPaint..strokeWidth = r * 0.045);
        break;

      case FaceType.surprised:
        // Round open "O" mouth. Mood makes it a little bigger or smaller.
        final open = 0.8 + config.mood * 0.4;
        final rect = Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.42),
          width: r * 0.32 * open,
          height: r * 0.42 * open,
        );
        canvas.drawOval(rect, Paint()..color = const Color(0xFF5D1A1A));
        canvas.drawOval(rect, mouthPaint..strokeWidth = r * 0.04);
        break;
    }
  }

  /// Maps mood (0..1) to a balanced smile or frown made with drawArc.
  ///
  /// The mouth corners always sit on the same horizontal line, and the
  /// arc is the bottom half (smile) or top half (frown) of an ellipse
  /// whose height grows as the mood moves away from neutral (0.5).
  void _drawMoodArc(Canvas canvas, Offset c, double r, Paint mouthPaint) {
    final k = (config.mood - 0.5) * 2; // -1 (sad) .. 0 (neutral) .. 1 (happy)
    final mouthWidth = r * 1.1;
    final mouthHeight = r * (0.06 + 0.64 * k.abs());
    final cornerY = c.dy + r * 0.35; // mouth corners line

    if (k >= 0) {
      // Smile: start at 3 o'clock (0) and sweep clockwise half a turn (pi)
      // so the arc dips down through 6 o'clock.
      final rect = Rect.fromCenter(
        center: Offset(c.dx, cornerY),
        width: mouthWidth,
        height: mouthHeight,
      );
      if (config.mood > 0.7) {
        // Big happy grin: fill the open mouth, then outline it.
        canvas.drawArc(
            rect, 0, pi, false, Paint()..color = const Color(0xFF8E2424));
      }
      canvas.drawArc(rect, 0, pi, false, mouthPaint);
    } else {
      // Frown: start at 9 o'clock (pi) and sweep clockwise half a turn
      // so the arc rises through 12 o'clock. Shift down so it stays
      // in the same mouth area as the smile.
      final rect = Rect.fromCenter(
        center: Offset(c.dx, cornerY + mouthHeight / 2),
        width: mouthWidth,
        height: mouthHeight,
      );
      canvas.drawArc(rect, pi, pi, false, mouthPaint);
    }
  }

  void _drawSleepyZ(Canvas canvas, Offset c, double r) {
    final zPaint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < 3; i++) {
      final s = r * (0.12 + i * 0.05); // each Z gets bigger
      final x = c.dx + r * (0.75 + i * 0.18);
      final y = c.dy - r * (0.55 + i * 0.22);
      final z = Path()
        ..moveTo(x, y)
        ..lineTo(x + s, y)
        ..lineTo(x, y + s)
        ..lineTo(x + s, y + s);
      canvas.drawPath(z, zPaint);
    }
  }

  // Accessories: drawn after the face so they sit on top.
  void _drawMustache(Canvas canvas, Offset c, double r) {
    final p = Paint()..color = const Color(0xFF3E2723);
    final y = c.dy + r * 0.2;
    final path = Path()
      ..moveTo(c.dx, y - r * 0.02)
      ..quadraticBezierTo(c.dx - r * 0.18, y - r * 0.14, c.dx - r * 0.38, y + r * 0.02)
      ..quadraticBezierTo(c.dx - r * 0.2, y + r * 0.02, c.dx, y + r * 0.06)
      ..quadraticBezierTo(c.dx + r * 0.2, y + r * 0.02, c.dx + r * 0.38, y + r * 0.02)
      ..quadraticBezierTo(c.dx + r * 0.18, y - r * 0.14, c.dx, y - r * 0.02)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawGlasses(Canvas canvas, double r, Offset leftEye, Offset rightEye,
      double eyeR) {
    final frame = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.035;
    final lensR = r * 0.2;
    final lens = Paint()..color = const Color(0x3364B5F6);
    for (final eye in [leftEye, rightEye]) {
      canvas.drawCircle(eye, lensR, lens);
      canvas.drawCircle(eye, lensR, frame);
    }
    canvas.drawLine(Offset(leftEye.dx + lensR, leftEye.dy),
        Offset(rightEye.dx - lensR, rightEye.dy), frame);
  }

  void _drawHat(Canvas canvas, Offset c, double r) {
    final hatPaint = Paint()..color = const Color(0xFF212121);
    final bandPaint = Paint()..color = const Color(0xFFD32F2F);
    final brimY = c.dy - r * 0.8;
    // Crown (rounded box) then brim (flat box) then band on top.
    final crown = RRect.fromRectAndRadius(
      Rect.fromLTRB(c.dx - r * 0.45, brimY - r * 0.55, c.dx + r * 0.45, brimY),
      Radius.circular(r * 0.08),
    );
    canvas.drawRRect(crown, hatPaint);
    canvas.drawRect(
      Rect.fromLTRB(c.dx - r * 0.75, brimY - r * 0.06, c.dx + r * 0.75, brimY + r * 0.06),
      hatPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(c.dx - r * 0.45, brimY - r * 0.2, c.dx + r * 0.45, brimY - r * 0.1),
      bandPaint,
    );
  }

  /// Repaint only when an input the painter uses has changed.
  /// FaceConfig's == compares every field (type, mood, eye size, eye gap,
  /// blush, and each accessory), so an identical config skips the redraw.
  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.config != config;
  }
}
