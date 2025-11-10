import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'game.dart';
import 'payment_dialog.dart';

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

    // Fondo degradado
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A237E), // Azul oscuro
          Color(0xFF0D47A1), // Azul medio
          Color(0xFF1565C0), // Azul claro
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    add(
      RectangleComponent(
        size: size,
        paint: gradientPaint,
      ),
    );

    // Panel superior decorativo
    add(
      RectangleComponent(
        size: Vector2(size.x, 160),
        paint: Paint()..color = const Color(0x44000000),
      ),
    );

    // Decoración de esquinas superiores
    _addCornerDecoration();

    // Título con efecto brillante
    add(
      RectangleComponent(
        size: Vector2(400, 70),
        position: Vector2(size.x / 2 - 200, 20),
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      ),
    );

    add(
      RectangleComponent(
        size: Vector2(400, 70),
        position: Vector2(size.x / 2 - 200, 20),
        paint: Paint()..color = const Color(0xFF212121),
      ),
    );

    add(
      TextComponent(
        text: '🛒 TIENDA DE PODER 🛒',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD700),
            shadows: [
              Shadow(
                color: Color(0xFFFF6F00),
                offset: Offset(0, 0),
                blurRadius: 20,
              ),
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 55),
      ),
    );

    // Panel de monedas mejorado
    final coinsX = size.x / 2;
    final coinsY = 110.0;

    // Fondo del contador de monedas
    add(
      RectangleComponent(
        size: Vector2(280, 60),
        position: Vector2(coinsX - 140, coinsY - 30),
        paint: Paint()
          ..color = const Color(0xFF4CAF50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      ),
    );

    add(
      RectangleComponent(
        size: Vector2(280, 60),
        position: Vector2(coinsX - 140, coinsY - 30),
        paint: Paint()..color = const Color(0xFF1B5E20),
      ),
    );

    // Borde dorado
    add(
      RectangleComponent(
        size: Vector2(280, 60),
        position: Vector2(coinsX - 140, coinsY - 30),
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      ),
    );

    add(
      TextComponent(
        text: '💰 ${game.coins}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
            shadows: [
              Shadow(
                color: Color(0xFFFFFFFF),
                offset: Offset(0, 0),
                blurRadius: 15,
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
        position: Vector2(coinsX, coinsY),
      ),
    );

    // Items de la tienda con nuevo diseño
    final startY = 200.0;
    final itemHeight = 160.0;
    
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

    // Botón de volver mejorado
    add(
      ShopButton(
        text: '← VOLVER',
        position: Vector2(size.x / 2, size.y - 70),
        color: const Color(0xFF37474F),
        onPressed: onBack,
      ),
    );
  }

  void _addCornerDecoration() {
    // Decoración esquina superior izquierda
    for (var i = 0; i < 3; i++) {
      add(
        RectangleComponent(
          size: Vector2(60 - (i * 15), 60 - (i * 15)),
          position: Vector2(10 + (i * 8), 10 + (i * 8)),
          paint: Paint()
            ..color = Color(0xFFFFD700).withOpacity(0.3 - (i * 0.1))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ),
      );
    }

    // Decoración esquina superior derecha
    for (var i = 0; i < 3; i++) {
      add(
        RectangleComponent(
          size: Vector2(60 - (i * 15), 60 - (i * 15)),
          position: Vector2(size.x - 70 + (i * 8), 10 + (i * 8)),
          paint: Paint()
            ..color = Color(0xFFFFD700).withOpacity(0.3 - (i * 0.1))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ),
      );
    }
  }

  void _purchasePowerUp(PowerUpItem powerUp) {
    if (game.coins >= powerUp.price) {
      // Compra con monedas
      game.removeCoins(powerUp.price);
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
    } else {
      // No tiene suficientes monedas, abrir diálogo de pago
      _showPaymentDialog(powerUp);
    }
  }

  void _showPaymentDialog(PowerUpItem powerUp) {
    // Calcular precio en dinero real (conversión: 1 moneda = $0.10 USD)
    final realMoneyCost = (powerUp.price * 0.10);
    
    showDialog(
      context: game.buildContext!,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(
        itemName: powerUp.name,
        coinsCost: powerUp.price,
        realMoneyCost: realMoneyCost,
        onPaymentSuccess: () {
          // Pago exitoso, dar el power-up sin cobrar monedas
          game.activePowerUp = powerUp.type;
          
          // Actualizar la vista
          removeFromParent();
          game.camera.viewport.add(ShopMenu(onBack: onBack));
          
          // Mostrar mensaje de compra exitosa
          game.camera.viewport.add(
            PurchaseNotification(
              text: '✓ ${powerUp.name} comprado con tarjeta!',
              position: Vector2(game.camera.viewport.size.x / 2, 100),
            ),
          );
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
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

    // Sombra del item
    add(
      RectangleComponent(
        size: size,
        position: Vector2(4, 4),
        paint: Paint()
          ..color = const Color(0x88000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      ),
    );

    // Fondo degradado del item
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isActive
            ? [
                powerUp.color,
                powerUp.color.withOpacity(0.7),
              ]
            : canBuy
                ? [
                    powerUp.color.withOpacity(0.6),
                    powerUp.color.withOpacity(0.3),
                  ]
                : [
                    const Color(0xFF424242),
                    const Color(0xFF212121),
                  ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    add(
      RectangleComponent(
        size: size,
        paint: gradientPaint,
      ),
    );

    // Efecto brillante si está activo
    if (isActive) {
      add(
        RectangleComponent(
          size: size,
          paint: Paint()
            ..color = const Color(0x44FFFFFF)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
        ),
      );
    }

    // Borde animado
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = isActive ? const Color(0xFFFFD700) : const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isActive ? 5 : 3,
      ),
    );

    // Borde interno para efecto 3D
    add(
      RectangleComponent(
        size: Vector2(size.x - 6, size.y - 6),
        position: Vector2(3, 3),
        paint: Paint()
          ..color = const Color(0x44FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );

    // Icono grande del power-up
    final icon = powerUp.name.split(' ')[0];
    add(
      TextComponent(
        text: icon,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 64,
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
              Shadow(
                color: Color(0xFFFFFFFF),
                offset: Offset(0, 0),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(60, size.y / 2),
      ),
    );

    // Nombre
    add(
      TextComponent(
        text: powerUp.name.split(' ').sublist(1).join(' '),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFFFFF),
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(0, 0),
                blurRadius: 10,
              ),
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        anchor: Anchor.centerLeft,
        position: Vector2(120, size.y / 2 - 25),
      ),
    );

    // Descripción mejorada
    add(
      TextComponent(
        text: powerUp.description,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive || canBuy ? const Color(0xFFE0E0E0) : const Color(0xFF888888),
            shadows: const [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        anchor: Anchor.centerLeft,
        position: Vector2(120, size.y / 2 + 15),
      ),
    );

    // Panel de precio/estado
    final panelWidth = 160.0;
    final panelHeight = 80.0;
    final panelX = size.x - panelWidth - 10;
    final panelY = (size.y - panelHeight) / 2;

    // Precio o estado
    if (isActive) {
      // Badge de equipado
      add(
        RectangleComponent(
          size: Vector2(panelWidth, panelHeight),
          position: Vector2(panelX, panelY),
          paint: Paint()..color = const Color(0xFF4CAF50),
        ),
      );

      add(
        RectangleComponent(
          size: Vector2(panelWidth, panelHeight),
          position: Vector2(panelX, panelY),
          paint: Paint()
            ..color = const Color(0xFFFFD700)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        ),
      );

      add(
        TextComponent(
          text: '✓',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(panelX + panelWidth / 2, panelY + 20),
        ),
      );

      add(
        TextComponent(
          text: 'EQUIPADO',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 16,
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
          position: Vector2(panelX + panelWidth / 2, panelY + 55),
        ),
      );
    } else if (canBuy) {
      // Botón de compra con monedas
      add(
        RectangleComponent(
          size: Vector2(panelWidth, panelHeight),
          position: Vector2(panelX, panelY),
          paint: Paint()
            ..color = const Color(0xFF1B5E20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        ),
      );

      add(
        RectangleComponent(
          size: Vector2(panelWidth, panelHeight),
          position: Vector2(panelX, panelY),
          paint: Paint()..color = const Color(0xFF2E7D32),
        ),
      );

      add(
        RectangleComponent(
          size: Vector2(panelWidth, panelHeight),
          position: Vector2(panelX, panelY),
          paint: Paint()
            ..color = const Color(0xFF4CAF50)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ),
      );

      add(
        TextComponent(
          text: '💰',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 28,
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(panelX + panelWidth / 2, panelY + 22),
        ),
      );

      add(
        TextComponent(
          text: '${powerUp.price}',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
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
          position: Vector2(panelX + panelWidth / 2, panelY + 55),
        ),
      );
    } else {
      // Botón de pago con tarjeta
      final realPrice = (powerUp.price * 0.10).toStringAsFixed(2);

      add(
        RectangleComponent(
          size: Vector2(panelWidth, panelHeight),
          position: Vector2(panelX, panelY),
          paint: Paint()
            ..color = const Color(0xFF0D47A1)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        ),
      );

      add(
        RectangleComponent(
          size: Vector2(panelWidth, panelHeight),
          position: Vector2(panelX, panelY),
          paint: Paint()..color = const Color(0xFF1565C0),
        ),
      );

      add(
        RectangleComponent(
          size: Vector2(panelWidth, panelHeight),
          position: Vector2(panelX, panelY),
          paint: Paint()
            ..color = const Color(0xFF2196F3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ),
      );

      add(
        TextComponent(
          text: '💳',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 28,
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(panelX + panelWidth / 2, panelY + 22),
        ),
      );

      add(
        TextComponent(
          text: '\$$realPrice',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 24,
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
          position: Vector2(panelX + panelWidth / 2, panelY + 55),
        ),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // No hacer nada si ya está equipado
    if (game.activePowerUp == powerUp.type) {
      return;
    }
    
    // Llamar al callback de compra (manejará tanto monedas como pago con tarjeta)
    onPurchase();
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
        text: text,
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
