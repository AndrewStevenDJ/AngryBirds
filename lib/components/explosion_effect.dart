import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class ExplosionEffect extends PositionComponent {
  ExplosionEffect({
    required Vector2 position,
    double radius = 15.0,
  }) : _maxRadius = radius,
       super(
         position: position,
         anchor: Anchor.center,
         priority: 100,
       );

  final double _maxRadius;
  final _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Círculo de explosión principal
    final mainExplosion = CircleComponent(
      radius: 1.0,
      paint: Paint()
        ..color = const Color(0xFFFF5722)
        ..style = PaintingStyle.fill,
      anchor: Anchor.center,
    );

    // Animar el círculo principal
    mainExplosion.add(
      ScaleEffect.to(
        Vector2.all(_maxRadius),
        EffectController(duration: 0.4, curve: Curves.easeOut),
      ),
    );

    mainExplosion.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.4),
        onComplete: () => removeFromParent(),
      ),
    );

    add(mainExplosion);

    // Anillo exterior
    final outerRing = CircleComponent(
      radius: 1.0,
      paint: Paint()
        ..color = const Color(0xFFFF9800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
      anchor: Anchor.center,
    );

    outerRing.add(
      ScaleEffect.to(
        Vector2.all(_maxRadius * 1.3),
        EffectController(duration: 0.5, curve: Curves.easeOut),
      ),
    );

    outerRing.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5),
      ),
    );

    add(outerRing);

    // Partículas de fuego
    for (var i = 0; i < 12; i++) {
      final angle = (i * 2 * pi / 12) + (_random.nextDouble() * 0.2);
      final speed = 8.0 + _random.nextDouble() * 5.0;
      
      _addFireParticle(angle, speed);
    }
  }

  void _addFireParticle(double angle, double speed) {
    final particle = CircleComponent(
      radius: 0.5 + _random.nextDouble() * 0.5,
      paint: Paint()
        ..color = _random.nextBool() 
            ? const Color(0xFFFF5722) 
            : const Color(0xFFFFD700),
      anchor: Anchor.center,
    );

    final direction = Vector2(cos(angle), sin(angle));
    final distance = speed;

    particle.add(
      MoveEffect.by(
        direction * distance,
        EffectController(duration: 0.3 + _random.nextDouble() * 0.2),
      ),
    );

    particle.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.4),
      ),
    );

    particle.add(
      ScaleEffect.to(
        Vector2.all(0.1),
        EffectController(duration: 0.4),
      ),
    );

    add(particle);
  }
}
