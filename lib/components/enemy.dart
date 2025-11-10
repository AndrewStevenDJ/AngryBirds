import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'body_component_with_user_data.dart';
import 'game.dart';

const enemySize = 5.0;

enum EnemyColor {
  pink(color: 'pink', boss: false),
  blue(color: 'blue', boss: false),
  green(color: 'green', boss: false),
  yellow(color: 'yellow', boss: false),
  pinkBoss(color: 'pink', boss: true),
  blueBoss(color: 'blue', boss: true),
  greenBoss(color: 'green', boss: true),
  yellowBoss(color: 'yellow', boss: true);

  final bool boss;
  final String color;

  const EnemyColor({required this.color, required this.boss});

  static EnemyColor get randomColor =>
      EnemyColor.values[Random().nextInt(EnemyColor.values.length)];

  static EnemyColor get randomBossColor {
    final bossColors = [pinkBoss, blueBoss, greenBoss, yellowBoss];
    return bossColors[Random().nextInt(bossColors.length)];
  }

  String get fileName =>
      'alien${color.capitalize}_${boss ? 'suit' : 'square'}.png';
}

class Enemy extends BodyComponentWithUserData with ContactCallbacks {
  final bool isBoss;
  int health; // Vida del enemigo
  
  Enemy(Vector2 position, Sprite sprite, {this.pointValue = 100, this.isBoss = false})
    : health = isBoss ? 3 : 1, // Boss tiene 3 vidas, enemigos normales 1
      super(
        renderBody: false,
        bodyDef: BodyDef()
          ..position = position
          ..type = BodyType.dynamic,
        fixtureDefs: [
          FixtureDef(
            PolygonShape()..setAsBoxXY((isBoss ? enemySize * 2 : enemySize) / 2, (isBoss ? enemySize * 2 : enemySize) / 2),
            friction: 0.3,
            density: isBoss ? 3.0 : 1.0,
          ),
        ],
        children: [
          SpriteComponent(
            anchor: Anchor.center,
            sprite: sprite,
            size: Vector2.all(isBoss ? enemySize * 2 : enemySize),
            position: Vector2(0, 0),
          ),
          if (isBoss)
            TextComponent(
              text: '👑',
              textRenderer: TextPaint(
                style: TextStyle(
                  fontSize: isBoss ? 3.0 : 2.0,
                  fontFamily: 'Arial',
                ),
              ),
              anchor: Anchor.center,
              position: Vector2(0, -(isBoss ? enemySize : enemySize / 2) - 1),
            ),
        ],
      );

  final int pointValue;
  TextComponent? _healthText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Si es boss, agregar indicador de vida
    if (isBoss) {
      _healthText = TextComponent(
        text: '❤️ x$health',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 2.5,
            fontFamily: 'Arial',
            color: Color(0xFFFF0000),
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(0, enemySize + 1.5),
      );
      add(_healthText!);
    }
  }

  void _updateHealthDisplay() {
    if (isBoss && _healthText != null) {
      _healthText!.text = '❤️ x$health';
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    var interceptVelocity =
        (contact.bodyA.linearVelocity - contact.bodyB.linearVelocity).length
            .abs();
    
    // Marcar como golpeado si fue con suficiente fuerza
    if (interceptVelocity > 35) {
      health--; // Reducir vida
      
      if (isBoss) {
        // Actualizar indicador visual de vida
        _updateHealthDisplay();
        print('Boss golpeado! Vida restante: $health');
      }
      
      // Solo eliminar si la vida llega a 0
      if (health <= 0) {
        _hitByPlayer = true;
        
        // Dar puntos y monedas al juego
        final gameInstance = findParent<MyPhysicsGame>();
        if (gameInstance != null) {
          gameInstance.score += pointValue;
          gameInstance.addCoins(isBoss ? 50 : 10); // Boss da 50 monedas, normales 10
        }
        removeFromParent();
      }
    }

    super.beginContact(other, contact);
  }

  bool _hitByPlayer = false;

  @override
  void update(double dt) {
    super.update(dt);

    // Solo eliminar si fue golpeado por el jugador Y salió de la pantalla
    if (_hitByPlayer &&
        (position.x > camera.visibleWorldRect.right + 10 ||
            position.x < camera.visibleWorldRect.left - 10)) {
      removeFromParent();
    }
  }
}

extension on String {
  String get capitalize =>
      characters.first.toUpperCase() + characters.skip(1).toLowerCase().join();
}