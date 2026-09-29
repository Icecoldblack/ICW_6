// Smoke test: the app builds, the painter is on screen, and tapping
// the face cycles to the next design.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smiley_painter/main.dart';
import 'package:smiley_painter/smiley_painter.dart';

void main() {
  testWidgets('Smiley renders and tap cycles faces', (tester) async {
    await tester.pumpWidget(const SmileyApp());
    expect(find.text('CustomPainter Smiley Lab'), findsOneWidget);

    CustomPaint facePaint() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .firstWhere((w) => w.painter is SmileyPainter);

    expect((facePaint().painter as SmileyPainter).config.type,
        FaceType.classic);

    await tester.tap(find.byWidget(facePaint()));
    await tester.pump();
    expect((facePaint().painter as SmileyPainter).config.type,
        FaceType.sleepy);
  });

  test('shouldRepaint only when inputs change', () {
    final a = SmileyPainter(config: const FaceConfig(mood: 0.5));
    final same = SmileyPainter(config: const FaceConfig(mood: 0.5));
    final happier = SmileyPainter(config: const FaceConfig(mood: 0.9));
    expect(same.shouldRepaint(a), isFalse);
    expect(happier.shouldRepaint(a), isTrue);
  });
}
