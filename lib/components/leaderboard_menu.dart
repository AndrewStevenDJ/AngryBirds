import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import 'game.dart';

class LeaderboardMenu extends PositionComponent with HasGameReference<MyPhysicsGame> {
  final VoidCallback onBack;
  
  List<Map<String, dynamic>> _scores = [];
  bool _isLoading = true;

  LeaderboardMenu({required this.onBack});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final viewportSize = game.camera.viewport.size;
    size = viewportSize;
    position = Vector2.zero();

    // Fondo
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xDD1A237E),
      ),
    );

    // Botón volver
    add(
      LeaderboardButton(
        position: Vector2(size.x / 2, size.y - 60),
        onPressed: onBack,
      ),
    );

    // Cargar puntajes
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      _scores = await SupabaseService.getTopScores(limit: 10);
      _isLoading = false;
    } catch (e) {
      print('Error al cargar leaderboard: $e');
      _isLoading = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Título
    _drawText(
      canvas,
      '🏆 TOP 10 JUGADORES',
      Vector2(size.x / 2, 60),
      Colors.yellow,
      48,
      FontWeight.bold,
    );

    if (_isLoading) {
      _drawText(
        canvas,
        'Cargando...',
        Vector2(size.x / 2, size.y / 2),
        Colors.white,
        24,
        FontWeight.normal,
      );
      return;
    }

    if (_scores.isEmpty) {
      _drawText(
        canvas,
        'No hay puntajes aún',
        Vector2(size.x / 2, size.y / 2),
        Colors.white70,
        20,
        FontWeight.normal,
      );
      return;
    }

    // Dibujar lista de puntajes
    double startY = 140;
    for (var i = 0; i < _scores.length; i++) {
      final score = _scores[i];
      final position = i + 1;
      final username = score['username'] ?? 'Anónimo';
      final points = score['score'] ?? 0;
      final stars = score['stars'] ?? 0;

      // Medalla para top 3
      String medal = '';
      Color rankColor = Colors.white;
      if (position == 1) {
        medal = '🥇';
        rankColor = const Color(0xFFFFD700);
      } else if (position == 2) {
        medal = '🥈';
        rankColor = const Color(0xFFC0C0C0);
      } else if (position == 3) {
        medal = '🥉';
        rankColor = const Color(0xFFCD7F32);
      }

      // Fondo de la fila
      final rowRect = Rect.fromLTWH(
        size.x * 0.1,
        startY + (i * 50) - 20,
        size.x * 0.8,
        45,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rowRect, const Radius.circular(8)),
        Paint()..color = Colors.black.withOpacity(0.3),
      );

      // Posición
      _drawText(
        canvas,
        '$medal$position.',
        Vector2(size.x * 0.15, startY + (i * 50)),
        rankColor,
        20,
        FontWeight.bold,
      );

      // Nombre de usuario
      _drawText(
        canvas,
        username,
        Vector2(size.x * 0.35, startY + (i * 50)),
        Colors.white,
        20,
        FontWeight.normal,
      );

      // Puntos
      _drawText(
        canvas,
        '$points pts',
        Vector2(size.x * 0.65, startY + (i * 50)),
        Colors.yellow,
        20,
        FontWeight.bold,
      );

      // Estrellas
      _drawText(
        canvas,
        '⭐' * stars,
        Vector2(size.x * 0.85, startY + (i * 50)),
        Colors.yellow,
        18,
        FontWeight.normal,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Vector2 position,
    Color color,
    double fontSize,
    FontWeight weight,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          shadows: const [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
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
        position.y - textPainter.height / 2,
      ),
    );
  }

}

class LeaderboardButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  LeaderboardButton({
    required Vector2 position,
    required this.onPressed,
  }) : super(
          position: position,
          size: Vector2(200, 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fondo
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF607D8B),
      ),
    );

    // Borde
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );

    // Texto
    add(
      TextComponent(
        text: '← VOLVER',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}
