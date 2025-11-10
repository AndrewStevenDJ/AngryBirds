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

  String get fileName =>
      'alien${color.capitalize}_${boss ? 'suit' : 'square'}.png';
}

class Enemy extends BodyComponentWithUserData with ContactCallbacks {
  Enemy(Vector2 position, Sprite sprite, {this.pointValue = 100})
    : super(
        renderBody: false,
        bodyDef: BodyDef()
          ..position = position
          ..type = BodyType.dynamic,
        fixtureDefs: [
          FixtureDef(
            PolygonShape()..setAsBoxXY(enemySize / 2, enemySize / 2),
            friction: 0.3,
          ),
        ],
        children: [
          SpriteComponent(
            anchor: Anchor.center,
            sprite: sprite,
            size: Vector2.all(enemySize),
            position: Vector2(0, 0),
          ),
        ],
      );

  final int pointValue;

  @override
  void beginContact(Object other, Contact contact) {
    var interceptVelocity =
        (contact.bodyA.linearVelocity - contact.bodyB.linearVelocity).length
            .abs();
    
    // Marcar como golpeado si fue con suficiente fuerza
    if (interceptVelocity > 35) {
      _hitByPlayer = true;
      
      // Dar puntos y monedas al juego
      final gameInstance = findParent<MyPhysicsGame>();
      if (gameInstance != null) {
        gameInstance.score += pointValue;
        gameInstance.coins += 10; // 10 monedas por enemigo derrotado
      }
      removeFromParent();
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