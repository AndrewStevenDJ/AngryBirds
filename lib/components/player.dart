import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'body_component_with_user_data.dart';
import 'explosion_effect.dart';
import 'shop_menu.dart';

const playerSize = 5.0;

enum PlayerColor {
  pink,
  blue,
  green,
  yellow;

  static PlayerColor get randomColor =>
      PlayerColor.values[Random().nextInt(PlayerColor.values.length)];

  String get fileName =>
      'alien${toString().split('.').last.capitalize}_round.png';
}

class Player extends BodyComponentWithUserData with DragCallbacks, ContactCallbacks {
  Player(Vector2 position, Sprite sprite)
    : _sprite = sprite,
      super(
        renderBody: false,
        bodyDef: BodyDef()
          ..position = position
          ..type = BodyType.static
          ..angularDamping = 0.1
          ..linearDamping = 0.1,
        fixtureDefs: [
          FixtureDef(CircleShape()..radius = playerSize / 2)
            ..restitution = 0.4
            ..density = 0.75
            ..friction = 0.5,
        ],
      );

  final Sprite _sprite;
  PowerUpType? powerUp;
  bool _powerUpUsed = false;

  @override
  Future<void> onLoad() {
    // Agregar componente visual principal
    addAll([
      CustomPainterComponent(
        painter: _DragPainter(this),
        anchor: Anchor.center,
        size: Vector2(playerSize, playerSize),
        position: Vector2(0, 0),
      ),
      SpriteComponent(
        anchor: Anchor.center,
        sprite: _sprite,
        size: Vector2(playerSize, playerSize),
        position: Vector2(0, 0),
      ),
    ]);
    
    // Agregar efecto visual del power-up DESPUÉS del sprite
    if (powerUp != null) {
      _addPowerUpVisual();
    }
    
    return super.onLoad();
  }

  void _addPowerUpVisual() {
    Color effectColor;
    String emoji;
    double sizeMultiplier = 1.0;
    
    switch (powerUp!) {
      case PowerUpType.explosive:
        effectColor = const Color(0xFFFF5722);
        emoji = '💣';
        sizeMultiplier = 1.0;
        break;
      case PowerUpType.heavy:
        effectColor = const Color(0xFF4A148C); // Morado oscuro
        emoji = '🏋️';
        sizeMultiplier = 1.5; // ¡Más grande y pesado!
        break;
      case PowerUpType.splitter:
        effectColor = const Color(0xFF2196F3);
        emoji = '✨';
        sizeMultiplier = 1.0;
        break;
    }
    
    // Para el power-up pesado, hacer el pájaro visualmente más grande
    if (powerUp == PowerUpType.heavy) {
      // Aumentar el tamaño del sprite de forma simple y directa
      final spriteComponent = children.whereType<SpriteComponent>().firstOrNull;
      if (spriteComponent != null) {
        // Cambio directo de tamaño sin efectos complejos
        spriteComponent.scale = Vector2.all(sizeMultiplier);
      }
    }
    
    // Solo para power-ups que NO son heavy: efectos visuales ligeros
    if (powerUp != PowerUpType.heavy) {
      // Círculo de aura brillante
      add(
        CircleComponent(
          radius: playerSize * 0.8,
          paint: Paint()
            ..color = effectColor.withOpacity(0.3)
            ..style = PaintingStyle.fill,
          anchor: Anchor.center,
          priority: -1,
        ),
      );
      
      // Anillo pulsante simple
      final ring = CircleComponent(
        radius: playerSize * 0.6,
        paint: Paint()
          ..color = effectColor.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.4,
        anchor: Anchor.center,
      );
      
      ring.add(
        ScaleEffect.by(
          Vector2.all(1.2),
          EffectController(
            duration: 1.0,
            alternate: true,
            infinite: true,
          ),
        ),
      );
      
      add(ring);
    } else {
      // Para heavy: SOLO un borde simple sin animaciones
      add(
        CircleComponent(
          radius: playerSize * 0.7,
          paint: Paint()
            ..color = effectColor.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
          anchor: Anchor.center,
        ),
      );
    }
    
    // Emoji indicador (sin animación para heavy)
    final textComp = TextComponent(
      text: emoji,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: powerUp == PowerUpType.heavy ? 4.0 : 3.0,
          shadows: [
            Shadow(
              color: Color(0xFF000000),
              offset: Offset(0.2, 0.2),
              blurRadius: 0.5,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, -playerSize * 0.9 * sizeMultiplier),
    );
    
    // Solo animar si NO es heavy
    if (powerUp != PowerUpType.heavy) {
      textComp.add(
        ScaleEffect.by(
          Vector2.all(1.15),
          EffectController(
            duration: 0.7,
            alternate: true,
            infinite: true,
          ),
        ),
      );
    }
    
    add(textComp);
    
    // Efecto especial para splitter: Rastro de clones
    if (powerUp == PowerUpType.splitter) {
      _addTrailEffect();
    }
  }
  
  int _trailCount = 0;
  void _addTrailEffect() {
    // Agregar efecto de rastro de imágenes fantasma (limitado)
    if (_trailCount > 30) return; // Limitar el número de trails
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isMounted && body.bodyType == BodyType.dynamic && _trailCount < 30) {
        _trailCount++;
        final trail = SpriteComponent(
          anchor: Anchor.center,
          sprite: _sprite,
          size: Vector2.all(playerSize * 0.8),
          position: position.clone(),
        );
        
        trail.paint = Paint()..color = const Color(0xFF2196F3).withOpacity(0.4);
        
        trail.add(
          OpacityEffect.fadeOut(
            EffectController(duration: 0.3),
            onComplete: () => trail.removeFromParent(),
          ),
        );
        
        world.add(trail);
        _addTrailEffect(); // Recursivo para efecto continuo (con límite)
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!body.isAwake) {
      removeFromParent();
    }

    if (position.x > camera.visibleWorldRect.right + 10 ||
        position.x < camera.visibleWorldRect.left - 10) {
      removeFromParent();
    }
  }

  Vector2 _dragStart = Vector2.zero();
  Vector2 _dragDelta = Vector2.zero();
  Vector2 get dragDelta => _dragDelta;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (body.bodyType == BodyType.static) {
      _dragStart = event.localPosition;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (body.bodyType == BodyType.static) {
      _dragDelta = event.localEndPosition - _dragStart;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (body.bodyType == BodyType.static) {
      children
          .whereType<CustomPainterComponent>()
          .firstOrNull
          ?.removeFromParent();
      // Configurar propiedades físicas ANTES de cambiar a dynamic
      var impulseMultiplier = 50.0;
      if (powerUp == PowerUpType.heavy) {
        impulseMultiplier = 80.0; // Mucha más fuerza para compensar el peso
        // Configurar densidad y restitución antes de activar
        final fixture = body.fixtures.first;
        body.destroyFixture(fixture);
        body.createFixture(
          FixtureDef(CircleShape()..radius = playerSize / 2)
            ..restitution = 0.2
            ..density = 2.5
            ..friction = 0.5,
        );
      } else if (powerUp == PowerUpType.explosive) {
        impulseMultiplier = 55.0;
      } else if (powerUp == PowerUpType.splitter) {
        impulseMultiplier = 52.0;
      }
      
      body.setType(BodyType.dynamic);
      
      // Efectos visuales después de activar (MUY reducidos)
      if (powerUp == PowerUpType.heavy) {
        // Sin efectos visuales para heavy, solo físicos
      } else if (powerUp == PowerUpType.explosive) {
        // Chispas al lanzar (reducidas)
        for (int i = 0; i < 3; i++) {
          final spark = CircleComponent(
            radius: 0.3,
            paint: Paint()..color = const Color(0xFFFF5722),
            position: position.clone(),
            anchor: Anchor.center,
          );
          
          final angle = (i / 3) * 2 * pi;
          spark.add(
            MoveEffect.by(
              Vector2(cos(angle) * 2.5, sin(angle) * 2.5),
              EffectController(duration: 0.25),
            ),
          );
          spark.add(
            OpacityEffect.fadeOut(
              EffectController(duration: 0.25),
              onComplete: () => spark.removeFromParent(),
            ),
          );
          
          world.add(spark);
        }
      } else if (powerUp == PowerUpType.splitter) {
        // Iniciar efecto de rastro
        _addTrailEffect();
      }
      
      body.applyLinearImpulse(_dragDelta * -impulseMultiplier);
      add(RemoveEffect(delay: 5.0));
      
      // Activar división automáticamente para splitter después de lanzar
      if (powerUp == PowerUpType.splitter) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (isMounted && !_powerUpUsed && body.bodyType == BodyType.dynamic) {
            _powerUpUsed = true;
            _split();
          }
        });
      }
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    
    if (body.bodyType == BodyType.dynamic && !_powerUpUsed) {
      // Si es explosivo, explotar al contacto
      if (powerUp == PowerUpType.explosive) {
        _powerUpUsed = true;
        _explode();
      }
      // Para splitter, NO dividirse al impactar
      // (Se divide automáticamente 0.3s después de lanzar)
      else if (powerUp == PowerUpType.heavy) {
        // Efecto visual de impacto pesado
        _heavyImpactEffect();
      }
    }
  }
  
  void _heavyImpactEffect() {
    // Efecto de onda de choque simple (solo 1)
    final shockwave = CircleComponent(
      radius: playerSize * 0.5,
      paint: Paint()
        ..color = const Color(0xFF4A148C).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
      position: position.clone(),
      anchor: Anchor.center,
    );
    
    shockwave.add(
      ScaleEffect.to(
        Vector2.all(10),
        EffectController(duration: 0.4),
      ),
    );
    shockwave.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.4),
        onComplete: () => shockwave.removeFromParent(),
      ),
    );
    
    world.add(shockwave);
  }

  void _explode() {
    // Crear efecto visual de explosión épico y grande
    world.add(
      ExplosionEffect(
        position: position.clone(),
        radius: 20.0, // Radio más grande
      ),
    );
    
    // Múltiples anillos de explosión
    for (int i = 0; i < 5; i++) {
      final ring = CircleComponent(
        radius: 2.0 + i * 1.5,
        paint: Paint()
          ..color = Color.lerp(
            const Color(0xFFFF5722),
            const Color(0xFFFFEB3B),
            i / 5,
          )!.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
        position: position.clone(),
        anchor: Anchor.center,
      );
      
      Future.delayed(Duration(milliseconds: i * 50), () {
        ring.add(
          ScaleEffect.to(
            Vector2.all(12),
            EffectController(duration: 0.6),
          ),
        );
        ring.add(
          OpacityEffect.fadeOut(
            EffectController(duration: 0.6),
            onComplete: () => ring.removeFromParent(),
          ),
        );
        world.add(ring);
      });
    }
    
    // Chispas explosivas en todas direcciones
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * pi;
      final spark = CircleComponent(
        radius: 0.5,
        paint: Paint()..color = i % 2 == 0 
          ? const Color(0xFFFF5722) 
          : const Color(0xFFFFEB3B),
        position: position.clone(),
        anchor: Anchor.center,
      );
      
      spark.add(
        MoveEffect.by(
          Vector2(cos(angle) * 8, sin(angle) * 8),
          EffectController(duration: 0.5),
        ),
      );
      spark.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.5),
          onComplete: () => spark.removeFromParent(),
        ),
      );
      
      world.add(spark);
    }
    
    // Aplicar fuerza explosiva masiva a objetos cercanos
    final explosionRadius = 20.0;
    final explosionForce = 1200.0; // Más fuerza
    
    for (final otherBody in world.physicsWorld.bodies) {
      if (otherBody.bodyType != BodyType.dynamic) continue;
      if (otherBody == body) continue;
      
      final distance = (otherBody.position - body.position).length;
      
      if (distance < explosionRadius && distance > 0.1) {
        final direction = (otherBody.position - body.position).normalized();
        final forceMagnitude = explosionForce * (1 - distance / explosionRadius);
        otherBody.applyLinearImpulse(direction * forceMagnitude);
        // Agregar rotación para efecto más dramático
        otherBody.applyAngularImpulse(forceMagnitude * 0.1 * (Random().nextBool() ? 1 : -1));
      }
    }
    
    // Eliminar el pájaro después de un delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isMounted) removeFromParent();
    });
  }

  void _split() {
    final currentVelocity = body.linearVelocity;
    final angles = [-0.6, 0.0, 0.6]; // Ángulos de separación más amplios
    
    // Efecto visual de explosión azul brillante
    for (int i = 0; i < 3; i++) {
      final burst = CircleComponent(
        radius: 2.0,
        paint: Paint()
          ..color = const Color(0xFF2196F3).withOpacity(0.8 - i * 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
        position: position.clone(),
        anchor: Anchor.center,
      );
      
      Future.delayed(Duration(milliseconds: i * 50), () {
        burst.add(
          ScaleEffect.to(
            Vector2.all(15),
            EffectController(duration: 0.4),
          ),
        );
        burst.add(
          OpacityEffect.fadeOut(
            EffectController(duration: 0.4),
            onComplete: () => burst.removeFromParent(),
          ),
        );
        world.add(burst);
      });
    }
    
    // Crear 3 mini-pájaros con trayectorias distintas
    for (int i = 0; i < angles.length; i++) {
      final angle = angles[i];
      final cosValue = cos(angle);
      final sinValue = sin(angle);
      final newVelocityX = currentVelocity.x * cosValue - currentVelocity.y * sinValue;
      final newVelocityY = currentVelocity.x * sinValue + currentVelocity.y * cosValue;
      final newVelocity = Vector2(newVelocityX, newVelocityY) * 0.9; // Mantener más velocidad
      
      // Pequeña separación inicial en posición
      final offsetPos = position.clone() + Vector2(
        cos(angle) * 1.5,
        sin(angle) * 1.5,
      );
      
      // Crear mini-pájaro con efecto de estrella
      final miniBird = _MiniPlayer(
        offsetPos,
        _sprite,
        newVelocity,
      );
      
      // Agregar partículas de rastro a cada mini-pájaro
      Future.delayed(Duration(milliseconds: i * 50), () {
        world.add(miniBird);
        
        // Estrella brillante en el momento de la división
        for (int j = 0; j < 8; j++) {
          final sparkAngle = (j / 8) * 2 * pi;
          final sparkle = CircleComponent(
            radius: 0.3,
            paint: Paint()..color = const Color(0xFF64B5F6),
            position: offsetPos.clone(),
            anchor: Anchor.center,
          );
          
          sparkle.add(
            MoveEffect.by(
              Vector2(cos(sparkAngle) * 4, sin(sparkAngle) * 4),
              EffectController(duration: 0.3),
            ),
          );
          sparkle.add(
            OpacityEffect.fadeOut(
              EffectController(duration: 0.3),
              onComplete: () => sparkle.removeFromParent(),
            ),
          );
          
          world.add(sparkle);
        }
      });
    }
    
    // Texto visual "SPLIT!" 
    final splitText = TextComponent(
      text: '✨ SPLIT! ✨',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 3.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2196F3),
          shadows: [
            Shadow(
              color: Color(0xFFFFFFFF),
              offset: Offset(0, 0),
              blurRadius: 1.0,
            ),
          ],
        ),
      ),
      position: position.clone() + Vector2(0, -5),
      anchor: Anchor.center,
    );
    
    splitText.add(
      MoveEffect.by(
        Vector2(0, -3),
        EffectController(duration: 0.6),
      ),
    );
    splitText.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.6),
        onComplete: () => splitText.removeFromParent(),
      ),
    );
    
    world.add(splitText);
    
    removeFromParent();
  }
}

// Mini pájaro para el efecto de división
class _MiniPlayer extends BodyComponent with ContactCallbacks {
  _MiniPlayer(Vector2 position, Sprite sprite, Vector2 velocity)
    : _sprite = sprite,
      super(
        renderBody: false,
        bodyDef: BodyDef()
          ..position = position
          ..type = BodyType.dynamic
          ..linearVelocity = velocity,
        fixtureDefs: [
          FixtureDef(CircleShape()..radius = playerSize / 2.5)
            ..restitution = 0.5
            ..density = 0.65 // Más denso para más impacto
            ..friction = 0.5,
        ],
      );

  final Sprite _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Sprite con aura azul
    add(
      CircleComponent(
        radius: playerSize * 0.4,
        paint: Paint()
          ..color = const Color(0xFF2196F3).withOpacity(0.4)
          ..style = PaintingStyle.fill,
        anchor: Anchor.center,
        priority: -1,
      ),
    );
    
    final spriteComp = SpriteComponent(
      anchor: Anchor.center,
      sprite: _sprite,
      size: Vector2.all(playerSize * 0.7),
      position: Vector2.zero(),
    );
    
    // Efecto de brillo pulsante
    spriteComp.add(
      ScaleEffect.by(
        Vector2.all(1.15),
        EffectController(
          duration: 0.4,
          alternate: true,
          infinite: true,
        ),
      ),
    );
    
    add(spriteComp);
    
    // Rastro de partículas
    _addMiniTrail();
    
    // Auto-remover después de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (isMounted) {
        // Pequeña explosión al desaparecer
        _miniExplosion();
        removeFromParent();
      }
    });
  }
  
  void _addMiniTrail() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (isMounted && body.isAwake) {
        final trail = CircleComponent(
          radius: playerSize * 0.2,
          paint: Paint()..color = const Color(0xFF64B5F6).withOpacity(0.5),
          position: position.clone(),
          anchor: Anchor.center,
        );
        
        trail.add(
          OpacityEffect.fadeOut(
            EffectController(duration: 0.25),
            onComplete: () => trail.removeFromParent(),
          ),
        );
        
        world.add(trail);
        _addMiniTrail(); // Continuar rastro
      }
    });
  }
  
  void _miniExplosion() {
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi;
      final spark = CircleComponent(
        radius: 0.25,
        paint: Paint()..color = const Color(0xFF2196F3),
        position: position.clone(),
        anchor: Anchor.center,
      );
      
      spark.add(
        MoveEffect.by(
          Vector2(cos(angle) * 3, sin(angle) * 3),
          EffectController(duration: 0.3),
        ),
      );
      spark.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.3),
          onComplete: () => spark.removeFromParent(),
        ),
      );
      
      world.add(spark);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Remover si sale de la pantalla o se duerme
    if (position.x > camera.visibleWorldRect.right + 10 ||
        position.x < camera.visibleWorldRect.left - 10 ||
        !body.isAwake) {
      _miniExplosion();
      removeFromParent();
    }
  }
  
  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    
    // Pequeño efecto visual al impactar
    final impact = CircleComponent(
      radius: 1.0,
      paint: Paint()
        ..color = const Color(0xFF2196F3).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4,
      position: position.clone(),
      anchor: Anchor.center,
    );
    
    impact.add(
      ScaleEffect.to(
        Vector2.all(5),
        EffectController(duration: 0.2),
      ),
    );
    impact.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.2),
        onComplete: () => impact.removeFromParent(),
      ),
    );
    
    world.add(impact);
  }
}

extension on String {
  String get capitalize =>
      characters.first.toUpperCase() + characters.skip(1).toLowerCase().join();
}

class _DragPainter extends CustomPainter {
  _DragPainter(this.player);

  final Player player;

  @override
  void paint(Canvas canvas, Size size) {
    if (player.dragDelta != Vector2.zero()) {
      var center = size.center(Offset.zero);
      canvas.drawLine(
        center,
        center + (player.dragDelta * -1).toOffset(),
        Paint()
          ..color = Colors.orange.withAlpha(180)
          ..strokeWidth = 0.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}