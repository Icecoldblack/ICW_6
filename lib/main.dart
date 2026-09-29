// In-Class Activity 06: Drawing with Flutter
// Student: Uyiosa Nehikhuere
// Date: September 29, 2026
//
// Levels completed:
//   1. Classic smiley (face, border, two eyes, drawArc mouth)
//   2. Mood slider + mood color bands + field-based shouldRepaint
//   3. Gallery of three faces (Classic, Sleepy, Surprised) via SegmentedButton
//   4. Tap to cycle faces, long-press to randomize, SnackBar feedback
//   Bonus: hat / glasses / mustache toggles + undo stack (List<FaceConfig>)

import 'dart:math' show Random;

import 'package:flutter/material.dart';

import 'smiley_painter.dart';

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.amber, useMaterial3: true),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing state: changing this + setState() makes build() create a new
  // painter, and shouldRepaint compares the old and new config.
  FaceConfig config = const FaceConfig();

  // Bonus: undo stack of previous configurations.
  final List<FaceConfig> _history = [];
  final Random _random = Random();

  /// Saves the current config for undo, then applies the new one.
  void _apply(FaceConfig next) {
    if (next == config) return;
    setState(() {
      _history.add(config);
      config = next;
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() => config = _history.removeLast());
    _toast('Undo: back to ${config.type.label}');
  }

  /// Shows one SnackBar per action; clears any old one first.
  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
      ));
  }

  // Level 4: tap cycles to the next face.
  void _cycleFace() {
    final types = FaceType.values;
    final next = types[(config.type.index + 1) % types.length];
    _apply(config.copyWith(type: next));
    _toast('Face: ${next.label}');
  }

  // Level 4: long-press randomizes the face.
  void _randomize() {
    final types = FaceType.values;
    _apply(FaceConfig(
      type: types[_random.nextInt(types.length)],
      mood: double.parse(_random.nextDouble().toStringAsFixed(2)),
      eyeSize: 0.05 + _random.nextDouble() * 0.10,
      eyeGap: 0.22 + _random.nextDouble() * 0.23,
      blush: _random.nextBool(),
      hat: config.hat,
      glasses: config.glasses,
      mustache: config.mustache,
    ));
    _toast('Randomized: ${config.type.label}, ${config.moodLabel}');
  }

  // Sliders push one undo entry when a drag starts, not on every tick.
  FaceConfig? _dragStart;

  void _sliderStart(double _) => _dragStart = config;

  void _sliderEnd(double _) {
    final start = _dragStart;
    _dragStart = null;
    if (start != null && start != config) {
      setState(() => _history.add(start));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPainter Smiley Lab'),
        actions: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: _history.isEmpty ? null : _undo,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final landscape = constraints.maxWidth > constraints.maxHeight;
            final face = _buildFace();
            final controls = _buildControls();
            if (landscape) {
              return Row(
                children: [
                  Expanded(flex: 5, child: face),
                  Expanded(flex: 4, child: controls),
                ],
              );
            }
            return Column(
              children: [
                Expanded(flex: 5, child: face),
                Expanded(flex: 4, child: controls),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFace() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _cycleFace,
        onLongPress: _randomize,
        child: CustomPaint(
          // Fill whatever space the layout gives; the painter scales to it.
          size: Size.infinite,
          painter: SmileyPainter(config: config),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tap the face to cycle. Long-press to randomize.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          SegmentedButton<FaceType>(
            segments: [
              for (final t in FaceType.values)
                ButtonSegment(value: t, label: Text(t.label)),
            ],
            selected: {config.type},
            onSelectionChanged: (s) => _apply(config.copyWith(type: s.first)),
          ),
          const SizedBox(height: 8),
          Text(
            'Mood: ${config.mood.toStringAsFixed(2)} (${config.moodLabel})',
          ),
          Slider(
            value: config.mood,
            onChangeStart: _sliderStart,
            onChangeEnd: _sliderEnd,
            onChanged: (v) => setState(() => config = config.copyWith(mood: v)),
          ),
          Text('Eye size: ${(config.eyeSize * 100).round()}% of radius'),
          Slider(
            value: config.eyeSize,
            min: 0.05,
            max: 0.15,
            onChangeStart: _sliderStart,
            onChangeEnd: _sliderEnd,
            onChanged: (v) =>
                setState(() => config = config.copyWith(eyeSize: v)),
          ),
          Text('Eye gap: ${(config.eyeGap * 100).round()}% of radius'),
          Slider(
            value: config.eyeGap,
            min: 0.22,
            max: 0.45,
            onChangeStart: _sliderStart,
            onChangeEnd: _sliderEnd,
            onChanged: (v) =>
                setState(() => config = config.copyWith(eyeGap: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Blush (drawOval)'),
            value: config.blush,
            onChanged: (v) => _apply(config.copyWith(blush: v)),
          ),
          const Text('Accessories'),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              _accessoryButton(
                label: 'Hat',
                icon: Icons.school,
                on: config.hat,
                onPressed: () => _apply(config.copyWith(hat: !config.hat)),
              ),
              _accessoryButton(
                label: 'Glasses',
                icon: Icons.visibility,
                on: config.glasses,
                onPressed: () =>
                    _apply(config.copyWith(glasses: !config.glasses)),
              ),
              _accessoryButton(
                label: 'Mustache',
                icon: Icons.face,
                on: config.mustache,
                onPressed: () =>
                    _apply(config.copyWith(mustache: !config.mustache)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _accessoryButton({
    required String label,
    required IconData icon,
    required bool on,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: label,
          isSelected: on,
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
