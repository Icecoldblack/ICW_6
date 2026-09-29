# ICW_6: Drawing with Flutter (Smiley Painter)

In-Class Activity 06 for Mobile App Development. Author: **Uyiosa Nehikhuere**.

A `CustomPainter` smiley face that reacts to state.

## Features

| Level | What it does |
|---|---|
| 1 · Basics | Face circle with stroke border, two symmetric eyes, `drawArc` mouth |
| 2 · State & Feedback | Mood slider changes the mouth arc live; face color follows mood bands (below 0.35 blue frown, 0.35 to 0.7 yellow soft smile, above 0.7 orange open grin); `shouldRepaint` compares every painter input |
| 3 · Gallery | Classic, Sleepy (closed arc eyes, soft mouth, Zs) and Surprised (big eyes, raised brows, round open mouth) chosen with a `SegmentedButton` |
| 4 · Interaction | Tap the face to cycle designs, long-press to randomize, one `SnackBar` per action (old one cleared first) |
| Bonus | Hat, glasses and mustache toggle independently; undo stack (`List<FaceConfig>`) in the app bar |

Also: eye size and eye gap sliders, blush toggle (`drawOval`), and a layout that switches to side by side in landscape.

## Project layout

```
lib/main.dart            App, state, controls, gestures, undo
lib/smiley_painter.dart  FaceConfig + SmileyPainter (all drawing)
test/widget_test.dart    Widget + shouldRepaint tests
docs/critical_thinking.md
```

## Run it

```bash
flutter create . --project-name smiley_painter   # only if android/ or ios/ is missing
flutter pub get
flutter run
```

## Build the release APK

```bash
flutter clean
flutter pub get
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```
