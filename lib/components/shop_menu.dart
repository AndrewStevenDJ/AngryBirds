import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'game.dart';

enum PowerUpType {
  explosive, // Explosión al impactar
  heavy,     // Más peso y daño
  splitter,  // Se divide en 3 pájaros
}

class PowerUpItem {
  final PowerUpType type;
  final String name;
  final String description;
  final int price;
  final Color color;

  const PowerUpItem({
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
  });
}

class ShopMenu extends PositionComponent with HasGameReference<MyPhysicsGame> {
  final VoidCallback onBack;
  
  static const powerUps = [
    PowerUpItem(
      type: PowerUpType.explosive,
      name: '💣 Explosivo',
      description: 'Causa explosión\nal impactar',
      price: 50,
      color: Color(0xFFFF5722),
    ),
    PowerUpItem(
      type: PowerUpType.heavy,
      name: '⚡ Pesado',
      description: 'Más peso\ny daño',
      price: 30,
      color: Color(0xFF9C27B0),
    ),
    PowerUpItem(
      type: PowerUpType.splitter,
      name: '🎯 División',
      description: 'Se divide\nen 3 pájaros',
      price: 80,
      color: Color(0xFF2196F3),
    ),
  ];

  ShopMenu({required this.onBack});

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
        paint: Paint()..color = const Color(0xDD1A237E), // Azul oscuro
      ),
    );

    // Título
    add(
      TextComponent(
        text: '🛒 TIENDA',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 60),
      ),
    );

    // Mostrar monedas
    add(
      TextComponent(
        text: '💰 Monedas: ${game.coins}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 28,
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
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 120),
      ),
    );

    // Items de la tienda
    final startY = 180.0;
    final itemHeight = 140.0;
    
    for (var i = 0; i < powerUps.length; i++) {
      final powerUp = powerUps[i];
      add(
        ShopItem(
          powerUp: powerUp,
          position: Vector2(size.x / 2, startY + (i * itemHeight)),
          onPurchase: () => _purchasePowerUp(powerUp),
        ),
      );
    }

    // Botón de volver
    add(
      ShopButton(
        text: '← VOLVER',
        position: Vector2(size.x / 2, size.y - 60),
        color: const Color(0xFF607D8B),
        onPressed: onBack,
      ),
    );
  }

  void _purchasePowerUp(PowerUpItem powerUp) {
    if (game.coins >= powerUp.price) {
      game.coins -= powerUp.price;
      game.activePowerUp = powerUp.type;
      
      // Actualizar la vista
      removeFromParent();
      game.camera.viewport.add(ShopMenu(onBack: onBack));
      
      // Mostrar mensaje de compra exitosa
      game.camera.viewport.add(
        PurchaseNotification(
          text: '✓ ${powerUp.name} comprado!',
          position: Vector2(game.camera.viewport.size.x / 2, 100),
        ),
      );
    }
  }
}

class ShopItem extends PositionComponent with TapCallbacks, HasGameReference<MyPhysicsGame> {
  final PowerUpItem powerUp;
  final VoidCallback onPurchase;

  ShopItem({
    required this.powerUp,
    required Vector2 position,
    required this.onPurchase,
  }) : super(
          position: position,
          size: Vector2(500, 120),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final isActive = game.activePowerUp == powerUp.type;
    final canBuy = game.coins >= powerUp.price;

    // Fondo del item
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = isActive
              ? powerUp.color.withOpacity(0.8)
              : (canBuy ? powerUp.color.withOpacity(0.4) : const Color(0x44000000))
          ..style = PaintingStyle.fill,
      ),
    );

    // Borde
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = isActive ? const Color(0xFFFFD700) : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = isActive ? 4 : 2,
      ),
    );

    // Nombre
    add(
      TextComponent(
        text: powerUp.name,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 28,
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
        anchor: Anchor.centerLeft,
        position: Vector2(20, size.y / 2 - 20),
      ),
    );

    // Descripción
    add(
      TextComponent(
        text: powerUp.description,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFCCCCCC),
          ),
        ),
        anchor: Anchor.centerLeft,
        position: Vector2(20, size.y / 2 + 20),
      ),
    );

    // Precio o estado
    final rightText = isActive
        ? 'EQUIPADO'
        : canBuy
            ? '💰 ${powerUp.price}'
            : '🔒 ${powerUp.price}';
    
    add(
      TextComponent(
        text: rightText,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isActive
                ? const Color(0xFFFFD700)
                : canBuy
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF888888),
            shadows: const [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        anchor: Anchor.centerRight,
        position: Vector2(size.x - 20, size.y / 2),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!game.activePowerUp.toString().contains(powerUp.type.toString()) &&
        game.coins >= powerUp.price) {
      onPurchase();
    }
  }
}

class ShopButton extends PositionComponent with TapCallbacks {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  ShopButton({
    required this.text,
    required Vector2 position,
    required this.color,
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
          ..strokeWidth = 2,
      ),
    );

    // Texto
    add(
      TextComponent(
        text: text,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 22,
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
    onPressed();
  }
}

class PurchaseNotification extends PositionComponent {
  final String text;

  PurchaseNotification({
    required this.text,
    required Vector2 position,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      TextComponent(
        text: text,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
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
      ),
    );

    // Auto-remover después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (isMounted) removeFromParent();
    });
  }
}
