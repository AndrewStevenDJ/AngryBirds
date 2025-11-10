import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'shop_menu.dart';

class ScoreDisplay extends PositionComponent {
  ScoreDisplay({
    required this.getScore,
    required this.getAttempts,
    required this.maxAttempts,
    required this.getCoins,
    required this.getActivePowerUp,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.topCenter, priority: 10);

  final int Function() getScore;
  final int Function() getAttempts;
  final int maxAttempts;
  final int Function() getCoins;
  final PowerUpType? Function() getActivePowerUp;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fondo semi-transparente (más grande si hay power-up)
    final hasPowerUp = getActivePowerUp() != null;
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.6);
    final bgRect = hasPowerUp 
        ? Rect.fromLTWH(-120, 0, 240, 125)
        : Rect.fromLTWH(-120, 0, 240, 100);
    final rrect = RRect.fromRectAndRadius(bgRect, const Radius.circular(10));
    canvas.drawRRect(rrect, bgPaint);

    // Puntuación
    _drawText(
      canvas,
      'Puntos: ${getScore()}',
      Vector2(0, 12),
      Colors.yellow,
      18,
    );

    // Monedas
    _drawText(
      canvas,
      '💰 ${getCoins()}',
      Vector2(0, 38),
      const Color(0xFFFFD700),
      18,
    );

    // Intentos restantes
    final attemptsLeft = maxAttempts - getAttempts();
    final attemptsColor = attemptsLeft <= 3 ? Colors.red : Colors.white;
    _drawText(
      canvas,
      'Intentos: $attemptsLeft/$maxAttempts',
      Vector2(0, 64),
      attemptsColor,
      16,
    );

    // Power-up activo
    final activePowerUp = getActivePowerUp();
    if (activePowerUp != null) {
      String powerUpText;
      Color powerUpColor;
      
      switch (activePowerUp) {
        case PowerUpType.explosive:
          powerUpText = '💣 Explosivo';
          powerUpColor = const Color(0xFFFF5722);
          break;
        case PowerUpType.heavy:
          powerUpText = '⚡ Pesado';
          powerUpColor = const Color(0xFF9C27B0);
          break;
        case PowerUpType.splitter:
          powerUpText = '🎯 División';
          powerUpColor = const Color(0xFF2196F3);
          break;
      }
      
      _drawText(
        canvas,
        powerUpText,
        Vector2(0, 90),
        powerUpColor,
        18,
      );
    }
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