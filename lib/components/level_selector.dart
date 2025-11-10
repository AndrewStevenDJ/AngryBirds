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

    // Fondo degradado épico
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0D47A1), // Azul oscuro
          Color(0xFF1976D2), // Azul medio
          Color(0xFF42A5F5), // Azul claro
          Color(0xFF1565C0), // Azul medio-oscuro
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    add(
      RectangleComponent(
        size: size,
        paint: gradientPaint,
      ),
    );

    // Efectos de partículas decorativas
    _addDecorativeElements();

    // Panel superior con el título
    add(
      RectangleComponent(
        size: Vector2(size.x, 180),
        paint: Paint()..color = const Color(0x66000000),
      ),
    );

    // Título principal con efecto brillante
    add(
      RectangleComponent(
        size: Vector2(550, 90),
        position: Vector2(size.x / 2 - 275, 45),
        paint: Paint()
          ..color = const Color(0xFFFF6F00)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      ),
    );

    add(
      RectangleComponent(
        size: Vector2(550, 90),
        position: Vector2(size.x / 2 - 275, 45),
        paint: Paint()..color = const Color(0xFF1A237E),
      ),
    );

    add(
      RectangleComponent(
        size: Vector2(550, 90),
        position: Vector2(size.x / 2 - 275, 45),
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      ),
    );

    add(
      TextComponent(
        text: '🎮 SELECCIONA TU DESAFÍO 🎮',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD700),
            shadows: [
              Shadow(
                color: Color(0xFFFF6F00),
                offset: Offset(0, 0),
                blurRadius: 30,
              ),
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(3, 3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 90),
      ),
    );

    // Subtítulo
    add(
      TextComponent(
        text: 'Elige tu nivel de dificultad',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 145),
      ),
    );

    // Botones de niveles con mejor espaciado
    final startY = size.y * 0.32;
    final spacing = size.y * 0.19;

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

    // Botón volver mejorado
    add(
      BackButton(
        position: Vector2(size.x / 2, size.y * 0.93),
        onPressed: onBack,
      ),
    );
  }

  void _addDecorativeElements() {
    // Círculos decorativos flotantes
    final decorPositions = [
      Vector2(50, 200),
      Vector2(size.x - 50, 250),
      Vector2(80, size.y - 150),
      Vector2(size.x - 80, size.y - 200),
    ];

    for (var pos in decorPositions) {
      add(
        CircleComponent(
          radius: 30,
          position: pos,
          paint: Paint()
            ..color = const Color(0x22FFFFFF)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        ),
      );
    }
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

    // Sombra profunda
    add(
      RectangleComponent(
        size: size,
        position: Vector2(5, 5),
        paint: Paint()
          ..color = const Color(0xAA000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      ),
    );

    // Fondo degradado del botón
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          config.color,
          config.color.withOpacity(0.7),
          config.color.withOpacity(0.9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    add(
      RectangleComponent(
        size: size,
        paint: gradientPaint,
      ),
    );

    // Efecto de brillo superior
    add(
      RectangleComponent(
        size: Vector2(size.x, size.y * 0.4),
        paint: Paint()..color = const Color(0x33FFFFFF),
      ),
    );

    // Borde dorado brillante
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      ),
    );

    // Borde interno blanco
    add(
      RectangleComponent(
        size: Vector2(size.x - 10, size.y - 10),
        position: Vector2(5, 5),
        paint: Paint()
          ..color = const Color(0x44FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );

    // Panel del emoji con fondo
    add(
      CircleComponent(
        radius: 40,
        position: Vector2(50, size.y / 2),
        anchor: Anchor.center,
        paint: Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      ),
    );

    add(
      CircleComponent(
        radius: 38,
        position: Vector2(50, size.y / 2),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0x88FFFFFF),
      ),
    );

    // Emoji grande
    add(
      TextComponent(
        text: config.emoji,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 50,
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(50, size.y / 2),
      ),
    );

    // Panel de texto
    final textStartX = 110.0;

    // Nombre del nivel con efecto épico
    add(
      TextComponent(
        text: config.name,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFFFFD700),
                offset: Offset(0, 0),
                blurRadius: 15,
              ),
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        anchor: Anchor.centerLeft,
        position: Vector2(textStartX, size.y * 0.38),
      ),
    );

    // Línea decorativa
    add(
      RectangleComponent(
        size: Vector2(220, 2),
        position: Vector2(textStartX, size.y * 0.5),
        paint: Paint()..color = const Color(0x88FFFFFF),
      ),
    );

    // Descripción mejorada
    add(
      TextComponent(
        text: config.description,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        anchor: Anchor.centerLeft,
        position: Vector2(textStartX, size.y * 0.68),
      ),
    );

    // Panel de estadísticas
    final statsX = size.x - 140;
    
    add(
      RectangleComponent(
        size: Vector2(120, 70),
        position: Vector2(statsX, size.y / 2 - 35),
        paint: Paint()..color = const Color(0x66000000),
      ),
    );

    add(
      RectangleComponent(
        size: Vector2(120, 70),
        position: Vector2(statsX, size.y / 2 - 35),
        paint: Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );

    // Iconos y números
    add(
      TextComponent(
        text: '🐷 ${config.enemyCount}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(statsX + 60, size.y / 2 - 15),
      ),
    );

    add(
      TextComponent(
        text: '🧱 ${config.brickCount}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(statsX + 60, size.y / 2 + 15),
      ),
    );

    // Indicador de BOSS si aplica
    if (config.hasBoss) {
      add(
        RectangleComponent(
          size: Vector2(100, 30),
          position: Vector2(size.x - 110, 10),
          paint: Paint()..color = const Color(0xFFFF0000),
        ),
      );

      add(
        RectangleComponent(
          size: Vector2(100, 30),
          position: Vector2(size.x - 110, 10),
          paint: Paint()
            ..color = const Color(0xFFFFD700)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        ),
      );

      add(
        TextComponent(
          text: '👑 BOSS',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFFFFF),
              shadows: [
                Shadow(
                  color: Color(0xFF000000),
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(size.x - 60, 25),
        ),
      );
    }
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

    // Sombra
    add(
      RectangleComponent(
        size: size,
        position: Vector2(3, 3),
        paint: Paint()
          ..color = const Color(0x88000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      ),
    );

    // Fondo degradado
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF546E7A),
          Color(0xFF37474F),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    add(
      RectangleComponent(
        size: size,
        paint: gradientPaint,
      ),
    );

    // Brillo superior
    add(
      RectangleComponent(
        size: Vector2(size.x, size.y * 0.3),
        paint: Paint()..color = const Color(0x33FFFFFF),
      ),
    );

    // Borde
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      ),
    );

    // Texto
    add(
      TextComponent(
        text: '← VOLVER',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(2, 2),
                blurRadius: 4,
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
