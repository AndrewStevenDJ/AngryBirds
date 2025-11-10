import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'game.dart';
import 'shop_menu.dart';
import 'leaderboard_menu.dart';
import 'level_selector.dart';

class MainMenu extends PositionComponent with TapCallbacks, HasGameReference<MyPhysicsGame> {
  late final TextComponent _titleText;
  late final PlayButton _playButton;
  bool _isLoading = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Obtener el tamaño del viewport
    final viewportSize = game.camera.viewport.size;
    size = viewportSize;
    position = Vector2.zero();

    // Fondo degradado épico
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D47A1), // Azul oscuro profundo
          Color(0xFF1565C0), // Azul medio
          Color(0xFF1976D2), // Azul brillante
          Color(0xFF42A5F5), // Azul celeste
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    add(
      RectangleComponent(
        size: size,
        paint: gradientPaint,
      ),
    );

    // Elementos decorativos de fondo
    _addBackgroundDecoration();

    // Panel del título con efecto de cristal
    final titlePanelY = size.y * 0.15;
    final titlePanelWidth = 600.0;
    final titlePanelHeight = 120.0;
    
    // Sombra del panel
    add(
      RectangleComponent(
        size: Vector2(titlePanelWidth, titlePanelHeight),
        position: Vector2(size.x / 2 - titlePanelWidth / 2, titlePanelY - 5),
        paint: Paint()
          ..color = const Color(0x88000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      ),
    );

    // Panel oscuro con brillo
    add(
      RectangleComponent(
        size: Vector2(titlePanelWidth, titlePanelHeight),
        position: Vector2(size.x / 2 - titlePanelWidth / 2, titlePanelY),
        paint: Paint()
          ..color = const Color(0xFFFF6F00)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      ),
    );

    add(
      RectangleComponent(
        size: Vector2(titlePanelWidth, titlePanelHeight),
        position: Vector2(size.x / 2 - titlePanelWidth / 2, titlePanelY),
        paint: Paint()..color = const Color(0xEE1A237E),
      ),
    );

    // Borde dorado brillante
    add(
      RectangleComponent(
        size: Vector2(titlePanelWidth, titlePanelHeight),
        position: Vector2(size.x / 2 - titlePanelWidth / 2, titlePanelY),
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      ),
    );

    // Borde interno para efecto 3D
    add(
      RectangleComponent(
        size: Vector2(titlePanelWidth - 10, titlePanelHeight - 10),
        position: Vector2(size.x / 2 - titlePanelWidth / 2 + 5, titlePanelY + 5),
        paint: Paint()
          ..color = const Color(0x44FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );

    // Título principal con efecto épico
    _titleText = TextComponent(
      text: '🐦 HAPPY BIRDS 🐦',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 68,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFFD700),
          shadows: [
            Shadow(
              color: Color(0xFFFF0000),
              offset: Offset(0, 0),
              blurRadius: 40,
            ),
            Shadow(
              color: Color(0xFFFFFFFF),
              offset: Offset(0, 0),
              blurRadius: 20,
            ),
            Shadow(
              color: Color(0xFF000000),
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, titlePanelY + 60),
    );
    
    // Efecto de pulsación en el título
    _titleText.add(
      ScaleEffect.by(
        Vector2.all(1.05),
        EffectController(
          duration: 1.8,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
    add(_titleText);

    // Panel de monedas mejorado
    final coinsPanelX = size.x - 180;
    final coinsPanelY = 20.0;

    // Sombra
    add(
      RectangleComponent(
        size: Vector2(160, 60),
        position: Vector2(coinsPanelX, coinsPanelY + 3),
        paint: Paint()
          ..color = const Color(0x88000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      ),
    );

    // Fondo del panel
    add(
      RectangleComponent(
        size: Vector2(160, 60),
        position: Vector2(coinsPanelX, coinsPanelY),
        paint: Paint()
          ..color = const Color(0xFF4CAF50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      ),
    );

    add(
      RectangleComponent(
        size: Vector2(160, 60),
        position: Vector2(coinsPanelX, coinsPanelY),
        paint: Paint()..color = const Color(0xFF1B5E20),
      ),
    );

    // Borde dorado
    add(
      RectangleComponent(
        size: Vector2(160, 60),
        position: Vector2(coinsPanelX, coinsPanelY),
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      ),
    );

    // Brillo superior
    add(
      RectangleComponent(
        size: Vector2(160, 20),
        position: Vector2(coinsPanelX, coinsPanelY),
        paint: Paint()..color = const Color(0x33FFFFFF),
      ),
    );

    // Texto de monedas
    add(
      TextComponent(
        text: '💰 ${game.coins}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD700),
            shadows: [
              Shadow(
                color: Color(0xFFFFFFFF),
                offset: Offset(0, 0),
                blurRadius: 20,
              ),
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(coinsPanelX + 80, coinsPanelY + 30),
      ),
    );

    // Botón de jugar épico
    _playButton = PlayButton(
      position: Vector2(size.x / 2, size.y * 0.52),
      onPressed: _startGame,
    );
    add(_playButton);

    // Botones secundarios en fila
    final buttonY = size.y * 0.67;
    final buttonSpacing = 320.0;
    final centerX = size.x / 2;

    // Botón de tienda
    add(
      MenuButton(
        text: '🛒 TIENDA',
        position: Vector2(centerX - buttonSpacing / 2, buttonY),
        color: const Color(0xFF7B1FA2),
        icon: '🛒',
        onPressed: _openShop,
      ),
    );

    // Botón de ranking
    add(
      MenuButton(
        text: '🏆 RANKING',
        position: Vector2(centerX + buttonSpacing / 2, buttonY),
        color: const Color(0xFFE65100),
        icon: '🏆',
        onPressed: _openLeaderboard,
      ),
    );

    // Panel de instrucciones
    final instructionsY = size.y * 0.82;
    
    add(
      RectangleComponent(
        size: Vector2(500, 80),
        position: Vector2(size.x / 2 - 250, instructionsY),
        paint: Paint()..color = const Color(0x66000000),
      ),
    );

    add(
      RectangleComponent(
        size: Vector2(500, 80),
        position: Vector2(size.x / 2 - 250, instructionsY),
        paint: Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );

    add(
      TextComponent(
        text: '🎯 Arrastra el pájaro y suéltalo',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
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
        position: Vector2(size.x / 2, instructionsY + 25),
      ),
    );

    add(
      TextComponent(
        text: '💥 ¡Destruye todos los cerditos! 💥',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: Color(0xFFFF6F00),
                offset: Offset(0, 0),
                blurRadius: 10,
              ),
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, instructionsY + 55),
      ),
    );

    // Versión del juego
    add(
      TextComponent(
        text: 'v1.0 - Made with Flutter & Flame',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 14,
            color: Color(0x88FFFFFF),
            fontStyle: FontStyle.italic,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y * 0.97),
      ),
    );
  }

  void _addBackgroundDecoration() {
    // Círculos decorativos flotantes
    final decorativeCircles = [
      {'pos': Vector2(60, 120), 'radius': 40.0, 'opacity': 0.15},
      {'pos': Vector2(size.x - 60, 150), 'radius': 50.0, 'opacity': 0.12},
      {'pos': Vector2(80, size.y - 120), 'radius': 45.0, 'opacity': 0.18},
      {'pos': Vector2(size.x - 80, size.y - 150), 'radius': 55.0, 'opacity': 0.14},
      {'pos': Vector2(size.x / 2, size.y - 80), 'radius': 35.0, 'opacity': 0.16},
    ];

    for (var circle in decorativeCircles) {
      final pos = circle['pos'] as Vector2;
      final radius = circle['radius'] as double;
      final opacity = circle['opacity'] as double;

      add(
        CircleComponent(
          radius: radius,
          position: pos,
          paint: Paint()
            ..color = Color(0xFFFFFFFF).withOpacity(opacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
        ),
      );
    }

    // Estrellas decorativas pequeñas
    final stars = [
      Vector2(150, 80),
      Vector2(size.x - 150, 100),
      Vector2(200, size.y / 2),
      Vector2(size.x - 200, size.y / 2 + 50),
    ];

    for (var starPos in stars) {
      add(
        TextComponent(
          text: '✨',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 24,
              shadows: [
                Shadow(
                  color: Color(0xFFFFFFFF),
                  offset: Offset(0, 0),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          position: starPos,
          anchor: Anchor.center,
        )..add(
            MoveEffect.by(
              Vector2(0, -15),
              EffectController(
                duration: 2.5,
                alternate: true,
                infinite: true,
              ),
            ),
          ),
      );
    }
  }

  void _startGame() {
    if (_isLoading) return;
    _isLoading = true;

    // Abrir selector de niveles
    removeFromParent();
    game.camera.viewport.add(
      LevelSelector(
        onBack: () {
          game.camera.viewport.children.whereType<LevelSelector>().forEach((s) => s.removeFromParent());
          game.camera.viewport.add(MainMenu());
        },
      ),
    );
  }

  void _openShop() {
    if (_isLoading) return;
    _isLoading = true;

    removeFromParent();
    game.camera.viewport.add(
      ShopMenu(
        onBack: () {
          game.camera.viewport.children.whereType<ShopMenu>().forEach((s) => s.removeFromParent());
          game.camera.viewport.add(MainMenu());
        },
      ),
    );
  }

  void _openLeaderboard() {
    if (_isLoading) return;
    _isLoading = true;

    removeFromParent();
    game.camera.viewport.add(
      LeaderboardMenu(
        onBack: () {
          game.camera.viewport.children.whereType<LeaderboardMenu>().forEach((l) => l.removeFromParent());
          game.camera.viewport.add(MainMenu());
        },
      ),
    );
  }
}

class MenuButton extends PositionComponent with TapCallbacks {
  final String text;
  final Color color;
  final String icon;
  final VoidCallback onPressed;

  MenuButton({
    required this.text,
    required Vector2 position,
    required this.color,
    required this.icon,
    required this.onPressed,
  }) : super(
          position: position,
          size: Vector2(140, 140),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final center = size / 2;

    // Sombra profunda
    add(
      CircleComponent(
        radius: 70,
        paint: Paint()
          ..color = const Color(0xAA000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
        position: center + Vector2(0, 5),
        anchor: Anchor.center,
      ),
    );

    // Fondo degradado circular
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withOpacity(0.7),
        ],
      ).createShader(Rect.fromCircle(center: Offset(center.x, center.y), radius: 70));

    add(
      CircleComponent(
        radius: 70,
        paint: gradientPaint,
        position: center,
        anchor: Anchor.center,
      ),
    );

    // Brillo superior
    add(
      CircleComponent(
        radius: 65,
        position: center + Vector2(0, -10),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0x33FFFFFF),
      ),
    );

    // Borde dorado
    add(
      CircleComponent(
        radius: 70,
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
        position: center,
        anchor: Anchor.center,
      ),
    );

    // Borde interno
    add(
      CircleComponent(
        radius: 63,
        paint: Paint()
          ..color = const Color(0x44FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
        position: center,
        anchor: Anchor.center,
      ),
    );

    // Icono grande
    add(
      TextComponent(
        text: icon,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 52,
            shadows: [
              Shadow(
                color: Color(0xFFFFFFFF),
                offset: Offset(0, 0),
                blurRadius: 20,
              ),
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: center + Vector2(0, -10),
      ),
    );

    // Texto del botón
    final buttonText = text.replaceAll(icon, '').trim();
    add(
      TextComponent(
        text: buttonText,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
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
        position: center + Vector2(0, 35),
      ),
    );

    // Efecto de flotación
    add(
      MoveEffect.by(
        Vector2(0, -8),
        EffectController(
          duration: 1.5,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Efecto de presión
    add(
      ScaleEffect.by(
        Vector2.all(0.9),
        EffectController(duration: 0.1),
        onComplete: () {
          add(
            ScaleEffect.by(
              Vector2.all(1 / 0.9),
              EffectController(duration: 0.1),
              onComplete: onPressed,
            ),
          );
        },
      ),
    );
  }
}

class PlayButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  PlayButton({
    required Vector2 position,
    required this.onPressed,
  }) : super(
          position: position,
          size: Vector2(380, 100),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Sombra épica
    add(
      RectangleComponent(
        size: size,
        position: Vector2(5, 5),
        paint: Paint()
          ..color = const Color(0xDD000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      ),
    );

    // Resplandor verde brillante
    add(
      RectangleComponent(
        size: Vector2(size.x + 20, size.y + 20),
        position: Vector2(-10, -10),
        paint: Paint()
          ..color = const Color(0xFF4CAF50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      ),
    );

    // Fondo degradado épico
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF66BB6A),
          Color(0xFF4CAF50),
          Color(0xFF388E3C),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    add(
      RectangleComponent(
        size: size,
        paint: gradientPaint,
      ),
    );

    // Brillo superior intenso
    add(
      RectangleComponent(
        size: Vector2(size.x, size.y * 0.35),
        paint: Paint()..color = const Color(0x66FFFFFF),
      ),
    );

    // Borde dorado grueso
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      ),
    );

    // Borde interno brillante
    add(
      RectangleComponent(
        size: Vector2(size.x - 12, size.y - 12),
        position: Vector2(6, 6),
        paint: Paint()
          ..color = const Color(0x88FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      ),
    );

    // Icono de play grande
    add(
      TextComponent(
        text: '▶',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFFFFD700),
                offset: Offset(0, 0),
                blurRadius: 20,
              ),
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x * 0.35, size.y / 2),
      ),
    );

    // Texto del botón
    add(
      TextComponent(
        text: 'JUGAR',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFFFFF),
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: Color(0xFFFFD700),
                offset: Offset(0, 0),
                blurRadius: 25,
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
        position: Vector2(size.x * 0.65, size.y / 2),
      ),
    );

    // Efecto de flotación suave
    add(
      MoveEffect.by(
        Vector2(0, -12),
        EffectController(
          duration: 1.5,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Efecto de pulsación en el brillo
    add(
      ScaleEffect.by(
        Vector2.all(1.05),
        EffectController(
          duration: 1.8,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Efecto de presión épico
    add(
      ScaleEffect.by(
        Vector2.all(0.92),
        EffectController(duration: 0.12),
        onComplete: () {
          add(
            ScaleEffect.by(
              Vector2.all(1 / 0.92),
              EffectController(duration: 0.12),
              onComplete: onPressed,
            ),
          );
        },
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {}

  @override
  void onTapCancel(TapCancelEvent event) {}
}
