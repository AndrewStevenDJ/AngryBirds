import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreDisplay extends PositionComponent {
  ScoreDisplay({
    required this.getScore,
    required this.getAttempts,
    required this.maxAttempts,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.topCenter, priority: 10);

  final int Function() getScore;
  final int Function() getAttempts;
  final int maxAttempts;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fondo semi-transparente
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.6);
    final bgRect = Rect.fromLTWH(-100, 0, 200, 80);
    final rrect = RRect.fromRectAndRadius(bgRect, const Radius.circular(10));
    canvas.drawRRect(rrect, bgPaint);

    // Puntuación
    _drawText(
      canvas,
      'Puntos: ${getScore()}',
      Vector2(0, 15),
      Colors.yellow,
      20,
    );

    // Intentos restantes
    final attemptsLeft = maxAttempts - getAttempts();
    final attemptsColor = attemptsLeft <= 3 ? Colors.red : Colors.white;
    _drawText(
      canvas,
      'Intentos: $attemptsLeft/$maxAttempts',
      Vector2(0, 45),
      attemptsColor,
      18,
    );
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
          shadows: [
            Shadow(
              blurRadius: 3,
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.x - textPainter.width / 2,
        position.y,
      ),
    );
  }
}