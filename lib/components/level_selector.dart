import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'game.dart';

enum LevelDifficulty {
  normal,
  hard,
  boss,
}

class LevelConfig {
  final String name;
  final String description;
  final Color color;
  final String emoji;
  final int enemyCount;
  final int brickCount;
  final bool hasBoss;

  const LevelConfig({
    required this.name,
    required this.description,
    required this.color,
    required this.emoji,
    required this.enemyCount,
    required this.brickCount,
    this.hasBoss = false,
  });
}

const levelConfigs = {
  LevelDifficulty.normal: LevelConfig(
    name: 'NIVEL NORMAL',
    description: 'Perfecto para empezar',
    color: Color(0xFF4CAF50),
    emoji: '😊',
    enemyCount: 3,
    brickCount: 4,
  ),
  LevelDifficulty.hard: LevelConfig(
    name: 'NIVEL DIFÍCIL',
    description: 'Más enemigos y obstáculos',
    color: Color(0xFFFF9800),
    emoji: '😰',
    enemyCount: 4,
    brickCount: 10,
  ),
  LevelDifficulty.boss: LevelConfig(
    name: 'BIG BOSS',
    description: '¡El desafío definitivo!',
    color: Color(0xFFD32F2F),
    emoji: '💀',
    enemyCount: 5,
    brickCount: 18,
    hasBoss: true,
  ),
};

class LevelSelector extends PositionComponent with HasGameReference<MyPhysicsGame> {
  final VoidCallback onBack;

  LevelSelector({required this.onBack});

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
        paint: Paint()..color = const Color(0xDD1976D2),
      ),
    );

    // Título
    add(
      TextComponent(
        text: '🎮 SELECCIONA NIVEL',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y * 0.15),
      ),
    );

    // Botones de niveles
    final startY = size.y * 0.3;
    final spacing = size.y * 0.2;

    var index = 0;
    for (final entry in levelConfigs.entries) {
      add(
        LevelButton(
          difficulty: entry.key,
          config: entry.value,
          position: Vector2(size.x / 2, startY + (index * spacing)),
          onPressed: () => _selectLevel(entry.key),
        ),
      );
      index++;
    }

    // Botón volver
    add(
      BackButton(
        position: Vector2(size.x / 2, size.y * 0.92),
        onPressed: onBack,
      ),
    );
  }

  void _selectLevel(LevelDifficulty difficulty) {
    removeFromParent();
    game.startGame(difficulty: difficulty);
  }
}

class LevelButton extends PositionComponent with TapCallbacks {
  final LevelDifficulty difficulty;
  final LevelConfig config;
  final VoidCallback onPressed;

  LevelButton({
    required this.difficulty,
    required this.config,
    required Vector2 position,
    required this.onPressed,
  }) : super(
          position: position,
          size: Vector2(500, 100),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fondo del botón
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = config.color,
      ),
    );

    // Borde brillante
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      ),
    );

    // Emoji
    add(
      TextComponent(
        text: config.emoji,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 40),
        ),
        anchor: Anchor.centerLeft,
        position: Vector2(20, size.y / 2),
      ),
    );

    // Nombre del nivel
    add(
      TextComponent(
        text: config.name,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        anchor: Anchor.centerLeft,
        position: Vector2(80, size.y * 0.4),
      ),
    );

    // Descripción
    add(
      TextComponent(
        text: config.description,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        anchor: Anchor.centerLeft,
        position: Vector2(80, size.y * 0.65),
      ),
    );

    // Info de enemigos
    add(
      TextComponent(
        text: '🐷 ${config.enemyCount} | 🧱 ${config.brickCount}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        anchor: Anchor.centerRight,
        position: Vector2(size.x - 20, size.y / 2),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Efecto de presión
    add(
      ScaleEffect.by(
        Vector2.all(0.95),
        EffectController(duration: 0.1),
        onComplete: () {
          add(
            ScaleEffect.by(
              Vector2.all(1 / 0.95),
              EffectController(duration: 0.1),
              onComplete: onPressed,
            ),
          );
        },
      ),
    );
  }
}

class BackButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  BackButton({
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
