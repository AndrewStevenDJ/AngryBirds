import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'game.dart';

class ExitButton extends PositionComponent with TapCallbacks, HasGameReference<MyPhysicsGame> {
  ExitButton({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(50, 50),
          anchor: Anchor.topRight,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fondo circular
    add(
      CircleComponent(
        radius: 25,
        paint: Paint()..color = const Color(0xDDF44336), // Rojo semi-transparente
        anchor: Anchor.center,
        position: size / 2,
      ),
    );

    // Borde
    add(
      CircleComponent(
        radius: 25,
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );

    // Símbolo X
    add(
      TextComponent(
        text: '✕',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 28,
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
        position: size / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.exitToMenu();
  }
}
