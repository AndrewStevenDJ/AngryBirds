import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'game.dart';
import 'shop_menu.dart';

class MainMenu extends PositionComponent with TapCallbacks, HasGameReference<MyPhysicsGame> {
  late final TextComponent _titleText;
  late final TextComponent _subtitleText;
  late final PlayButton _playButton;
  bool _isLoading = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Obtener el tamaño del viewport
    final viewportSize = game.camera.viewport.size;
    size = viewportSize;
    position = Vector2.zero();

    // Fondo semi-transparente sobre el juego
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xDD87CEEB), // Azul cielo semi-transparente
      ),
    );

    // Título principal con efecto de escala pulsante
    _titleText = TextComponent(
      text: 'ANGRY BIRDS',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFFFFF),
          shadows: [
            Shadow(
              color: const Color(0xFF000000),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            Shadow(
              color: const Color(0xFFFF0000),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.25),
    );
    
    // Efecto de pulsación en el título
    _titleText.add(
      ScaleEffect.by(
        Vector2.all(1.1),
        EffectController(
          duration: 1.5,
          alternate: true,
          infinite: true,
        ),
      ),
    );
    add(_titleText);

    // Subtítulo
    _subtitleText = TextComponent(
      text: 'Forge2D Edition',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
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
      position: Vector2(size.x / 2, size.y * 0.35),
    );
    add(_subtitleText);

    // Mostrar monedas
    add(
      TextComponent(
        text: '💰 ${game.coins}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        anchor: Anchor.topRight,
        position: Vector2(size.x - 20, 20),
      ),
    );

    // Botón de jugar
    _playButton = PlayButton(
      position: Vector2(size.x / 2, size.y * 0.55),
      onPressed: _startGame,
    );
    add(_playButton);

    // Botón de tienda
    add(
      MenuButton(
        text: '🛒 TIENDA',
        position: Vector2(size.x / 2, size.y * 0.7),
        color: const Color(0xFF673AB7),
        onPressed: _openShop,
      ),
    );

    // Instrucciones
    add(
      TextComponent(
        text: 'Arrastra el pájaro y suéltalo para lanzar',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18,
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
        position: Vector2(size.x / 2, size.y * 0.8),
      ),
    );

    // Créditos
    add(
      TextComponent(
        text: '¡Destruye todos los cerditos!',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFFFDD00),
            fontWeight: FontWeight.bold,
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
        position: Vector2(size.x / 2, size.y * 0.88),
      ),
    );
  }

  void _startGame() {
    if (_isLoading) return;
    _isLoading = true;

    // Simplemente remover y empezar el juego
    removeFromParent();
    game.startGame();
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
}

class MenuButton extends PositionComponent with TapCallbacks {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  MenuButton({
    required this.text,
    required Vector2 position,
    required this.color,
    required this.onPressed,
  }) : super(
          position: position,
          size: Vector2(280, 70),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fondo
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = color,
      ),
    );

    // Borde
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      ),
    );

    // Texto
    add(
      TextComponent(
        text: text,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
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

class PlayButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  late final RectangleComponent _background;
  late final TextComponent _text;

  PlayButton({
    required Vector2 position,
    required this.onPressed,
  }) : super(
          position: position,
          size: Vector2(280, 80),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fondo del botón con gradiente simulado (múltiples rectángulos)
    _background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.fill,
      children: [
        RectangleComponent(
          size: size,
          paint: Paint()
            ..color = const Color(0xFF66BB6A)
            ..style = PaintingStyle.fill,
        ),
      ],
    );
    add(_background);

    // Borde del botón
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF2E7D32)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      ),
    );

    // Texto del botón
    _text = TextComponent(
      text: '▶ JUGAR',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
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
    );
    add(_text);

    // Efecto de flotación
    add(
      MoveEffect.by(
        Vector2(0, -10),
        EffectController(
          duration: 1.2,
          alternate: true,
          infinite: true,
        ),
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

  @override
  void onTapUp(TapUpEvent event) {}

  @override
  void onTapCancel(TapCancelEvent event) {}
}
