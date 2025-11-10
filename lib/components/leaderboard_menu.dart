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

    // Fondo gris claro neutral para máxima legibilidad
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFFE0E0E0), // Gris claro
        priority: -10, // Asegurar que esté al fondo
      ),
    );

    // Título con fondo dorado
    final titleBg = RectangleComponent(
      size: Vector2(size.x * 0.7, 80),
      position: Vector2(size.x * 0.15, 20),
      paint: Paint()..color = const Color(0xFFFFD700),
      priority: 0,
    );
    titleBg.add(
      RectangleComponent(
        size: Vector2(size.x * 0.7, 80),
        paint: Paint()
          ..color = const Color(0xFFFFA000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      ),
    );
    add(titleBg);

    add(
      TextComponent(
        text: 'TOP 10 JUGADORES',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
            shadows: [
              Shadow(
                color: Color(0x40000000),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 60),
        priority: 1,
      ),
    );

    // Botón volver
    add(
      LeaderboardButton(
        position: Vector2(size.x / 2, size.y - 60),
        onPressed: onBack,
      ),
    );

    // Mostrar mensaje de carga
    add(
      TextComponent(
        text: 'Cargando...',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2),
        priority: 1,
      ),
    );

    // Cargar puntajes de forma asíncrona
    _loadScores().then((_) {
      // Limpiar mensaje de carga
      children.whereType<TextComponent>().where((c) => c.text == 'Cargando...').forEach((c) => c.removeFromParent());
      _renderScores();
    });
  }

  Future<void> _loadScores() async {
    try {
      print('Cargando scores...'); // Debug
      _scores = await SupabaseService.getTopScores(limit: 10);
      print('Scores cargados: ${_scores.length}'); // Debug
      _isLoading = false;
    } catch (e) {
      print('Error al cargar leaderboard: $e');
      _isLoading = false;
    }
  }

  void _renderScores() {
    if (_isLoading) {
      add(
        TextComponent(
          text: 'Cargando...',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(size.x / 2, size.y / 2),
          priority: 1,
        ),
      );
      return;
    }

    if (_scores.isEmpty) {
      add(
        TextComponent(
          text: 'No hay puntajes aún',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF757575),
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(size.x / 2, size.y / 2 - 20),
          priority: 1,
        ),
      );
      add(
        TextComponent(
          text: '¡Sé el primero en jugar!',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF1976D2),
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(size.x / 2, size.y / 2 + 20),
          priority: 1,
        ),
      );
      return;
    }

    // Renderizar cada score
    double startY = 140;
    for (var i = 0; i < _scores.length; i++) {
      final score = _scores[i];
      final position = i + 1;
      final username = score['username'] ?? 'Anónimo';
      final points = score['score'] ?? 0;
      final stars = score['stars'] ?? 0;

      // Medalla para top 3
      String medal = '';
      Color rankColor = Colors.grey.shade800;
      if (position == 1) {
        medal = '1º ';
        rankColor = const Color(0xFFFFD700);
      } else if (position == 2) {
        medal = '2º ';
        rankColor = const Color(0xFFC0C0C0);
      } else if (position == 3) {
        medal = '3º ';
        rankColor = const Color(0xFFCD7F32);
      }

      final rowY = startY + (i * 55);

      // Fondo de la fila
      final rowBg = RectangleComponent(
        size: Vector2(size.x * 0.8, 45),
        position: Vector2(size.x * 0.1, rowY - 20),
        paint: Paint()..color = position <= 3 
          ? Colors.white.withOpacity(0.95)
          : const Color(0xFFF5F5F5),
        priority: 0,
      );
      rowBg.add(
        RectangleComponent(
          size: Vector2(size.x * 0.8, 45),
          paint: Paint()
            ..color = position <= 3 ? rankColor : Colors.grey.shade400
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        ),
      );
      add(rowBg);

      // Posición
      add(
        TextComponent(
          text: '$medal$position.',
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: position <= 3 ? rankColor : Colors.grey.shade800,
            ),
          ),
          anchor: Anchor.centerLeft,
          position: Vector2(size.x * 0.15, rowY),
          priority: 1,
        ),
      );

      // Nombre
      add(
        TextComponent(
          text: username,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          anchor: Anchor.centerLeft,
          position: Vector2(size.x * 0.28, rowY),
          priority: 1,
        ),
      );

      // Puntos
      add(
        TextComponent(
          text: '$points pts',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6F00),
            ),
          ),
          anchor: Anchor.centerLeft,
          position: Vector2(size.x * 0.6, rowY),
          priority: 1,
        ),
      );

      // Estrellas
      add(
        TextComponent(
          text: '$stars★',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
          anchor: Anchor.centerLeft,
          position: Vector2(size.x * 0.82, rowY),
          priority: 1,
        ),
      );
    }
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
