import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// This is a utility file to generate a PNG logo for the app
// Run this file with 'dart run assets/images/app_logo.dart'

Future<void> main() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = Size(1024, 1024);

  // Background - gradient from dark indigo to purple
  const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3730A3), // Dark indigo
      Color(0xFF6366F1), // Lighter indigo
    ],
  );

  final bgPaint = Paint()
    ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(240),
    ),
    bgPaint,
  );

  // Add subtle pattern to background
  drawBackgroundPattern(canvas, size);

  // Modern microphone design
  drawModernMicrophone(canvas);

  // Create the image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

  // Save to file
  final output = File('assets/images/app_logo.png');
  await output.writeAsBytes(pngBytes!.buffer.asUint8List());
  print('Logo saved to ${output.path}');

  // Also create the foreground image
  await createForegroundLogo();
}

void drawBackgroundPattern(Canvas canvas, Size size) {
  final patternPaint = Paint()
    ..color = const Color(0xFF8B87FF).withOpacity(0.2)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  // Draw a pattern of circles and dots
  for (int i = 0; i < 7; i++) {
    canvas.drawCircle(
      Offset(size.width * 0.2 + i * 40.0, size.height * 0.3),
      30.0 + i * 5.0,
      patternPaint,
    );
  }

  // Draw sound wave lines in background
  final wavePaint = Paint()
    ..color = Colors.white.withOpacity(0.1)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  for (int i = 0; i < 6; i++) {
    final y = 300 + i * 80;
    final path = Path()
      ..moveTo(100.0, y.toDouble())
      ..cubicTo(300.0, y - 50.0, 500.0, y + 50.0, 900.0, y - 20.0);
    canvas.drawPath(path, wavePaint);
  }
}

void drawModernMicrophone(Canvas canvas) {
  // Subtle glow behind the microphone
  final glowPaint = Paint()
    ..color = Colors.white.withOpacity(0.2)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

  canvas.drawCircle(
    const Offset(512, 512),
    280,
    glowPaint,
  );

  // Main microphone body with gradient
  const micGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white,
      Color(0xFFF0F0F0),
    ],
  );

  final micPaint = Paint()
    ..shader = micGradient.createShader(const Rect.fromLTWH(392, 280, 240, 380));

  // Microphone body with rounded corners
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(392, 280, 240, 320),
      const Radius.circular(120),
    ),
    micPaint,
  );

  // Microphone stand - with shadow
  final standPaint = Paint()..color = const Color(0xFFE0E0E0);

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(482, 600, 60, 140),
      const Radius.circular(30),
    ),
    standPaint,
  );

  // Microphone base stand - with shadow
  final basePaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFE0E0E0),
        Color(0xFFCCCCCC),
      ],
    ).createShader(const Rect.fromLTWH(372, 740, 280, 60));

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(372, 740, 280, 60),
      const Radius.circular(30),
    ),
    basePaint,
  );

  // Microphone grid detail
  drawMicrophoneGrid(canvas);

  // Decorative sound wave elements
  drawSoundWaves(canvas);

  // AI badge on top
  drawAIBadge(canvas);
}

void drawMicrophoneGrid(Canvas canvas) {
  final gridPaint = Paint()
    ..color = const Color(0xFFCCCCCC)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  // Draw horizontal grid lines
  for (int i = 0; i < 8; i++) {
    final y = 340.0 + i * 25.0;
    canvas.drawLine(
      Offset(412.0, y),
      Offset(612.0, y),
      gridPaint,
    );
  }

  // Draw vertical grid lines
  for (int i = 0; i < 8; i++) {
    final x = 412.0 + i * 29.0;
    canvas.drawLine(
      Offset(x, 340.0),
      Offset(x, 540.0),
      gridPaint,
    );
  }
}

void drawSoundWaves(Canvas canvas) {
  // Sound waves with gradient
  const waveGradient = RadialGradient(
    center: Alignment(0.5, 0.5),
    radius: 0.7,
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFA500), // Orange
    ],
  );

  final wavePaint = Paint()
    ..shader = waveGradient.createShader(const Rect.fromLTWH(200, 400, 624, 200))
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  // Left sound waves
  for (int i = 0; i < 3; i++) {
    final offset = i * 40;
    final path = Path();
    path.addArc(
      Rect.fromCenter(
          center: const Offset(312, 440 + 20), width: 120 + offset * 2, height: 120 + offset * 2),
      2.8, // radians
      1.0, // radians
    );
    canvas.drawPath(path, wavePaint);
  }

  // Right sound waves
  for (int i = 0; i < 3; i++) {
    final offset = i * 40;
    final path = Path();
    path.addArc(
      Rect.fromCenter(
          center: const Offset(712, 440 + 20), width: 120 + offset * 2, height: 120 + offset * 2),
      0.3, // radians
      1.0, // radians
    );
    canvas.drawPath(path, wavePaint);
  }
}

void drawAIBadge(Canvas canvas) {
  // AI Badge background
  final badgePaint = Paint()..color = const Color(0xFF111827).withOpacity(0.85);

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(432, 170, 160, 70),
      const Radius.circular(35),
    ),
    badgePaint,
  );

  // AI text
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'AI',
      style: TextStyle(
        color: Colors.white,
        fontSize: 50,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, const Offset(468, 180));
}

Future<void> createForegroundLogo() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = Size(1024, 1024);

  // Transparent background
  final bgPaint = Paint()..color = Colors.transparent;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

  // Draw only the microphone elements for the foreground
  drawModernMicrophone(canvas);

  // Create the image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

  // Save to file
  final output = File('assets/images/app_logo_foreground.png');
  await output.writeAsBytes(pngBytes!.buffer.asUint8List());
  print('Foreground logo saved to ${output.path}');
}
