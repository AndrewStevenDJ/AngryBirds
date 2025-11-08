import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GameResultOverlay extends PositionComponent with TapCallbacks {
  GameResultOverlay({
    required this.isVictory,
    required this.score,
    required this.stars,
    required Vector2 position,
    required Vector2 size,
    required this.onRestart,
  }) : super(position: position, size: size, anchor: Anchor.center);

  final bool isVictory;
  final int score;
  final int stars;
  final VoidCallback onRestart;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fondo semi-transparente
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawRect(size.toRect(), bgPaint);

    // Título
    final titleText = isVictory ? '¡VICTORIA!' : '¡DERROTA!';
    final titleColor = isVictory ? Colors.yellow : Colors.red;
    
    _drawText(
      canvas,
      titleText,
      Vector2(size.x / 2, size.y * 0.2),
      titleColor,
      32,
    );

    // Puntuación
    _drawText(
      canvas,
      'Puntos: $score',
      Vector2(size.x / 2, size.y * 0.35),
      Colors.white,
      24,
    );

    // Estrellas
    if (isVictory) {
      _drawStars(canvas);
    }

    // Mensaje de reinicio
    _drawText(
      canvas,
      'Toca para reiniciar',
      Vector2(size.x / 2, size.y * 0.8),
      Colors.white70,
      18,
    );
  }

  void _drawStars(Canvas canvas) {
    final starY = size.y * 0.55;
    final starSize = size.x * 0.15;
    final spacing = size.x * 0.25;
    final startX = (size.x - (spacing * 2)) / 2;

    for (var i = 0; i < 3; i++) {
      final x = startX + (i * spacing);
      final filled = i < stars;
      _drawStar(canvas, Vector2(x, starY), starSize, filled);
    }
  }

  void _drawStar(Canvas canvas, Vector2 center, double size, bool filled) {
    final paint = Paint()
      ..color = filled ? Colors.yellow : Colors.grey.shade700
      ..style = PaintingStyle.fill;

    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = size / 4;

    for (var i = 0; i < 5; i++) {
      final outerAngle = (i * 2 * math.pi / 5) - math.pi / 2;
      final innerAngle = ((i * 2 + 1) * math.pi / 5) - math.pi / 2;

      if (i == 0) {
        path.moveTo(
          center.x + outerRadius * math.cos(outerAngle),
          center.y + outerRadius * math.sin(outerAngle),
        );
      } else {
        path.lineTo(
          center.x + outerRadius * math.cos(outerAngle),
          center.y + outerRadius * math.sin(outerAngle),
        );
      }

      path.lineTo(
        center.x + innerRadius * math.cos(innerAngle),
        center.y + innerRadius * math.sin(innerAngle),
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onRestart();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Vector2 position,
    Color color,
    double fontSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.x - textPainter.width / 2,
        position.y - textPainter.height / 2,
      ),
    );
  }
}