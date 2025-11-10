import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';
import 'package:flutter/material.dart';

import 'background.dart';
import 'brick.dart';
import 'enemy.dart';
import 'exit_button.dart';
import 'game_result_overlay.dart';
import 'ground.dart';
import 'invisible_wall.dart';
import 'main_menu.dart';
import 'player.dart';
import 'score_display.dart';
import 'shop_menu.dart';

class MyPhysicsGame extends Forge2DGame {
  MyPhysicsGame()
    : super(
        gravity: Vector2(0, 10),
        camera: CameraComponent.withFixedResolution(width: 800, height: 600),
      );

  late final XmlSpriteSheet aliens;
  late final XmlSpriteSheet elements;
  late final XmlSpriteSheet tiles;

  int score = 0;
  int playerAttempts = 0;
  final int maxAttempts = 10;
  bool gameEnded = false;
  bool gameStarted = false;
  
  // Sistema de monedas y power-ups
  int coins = 100; // Empezamos con 100 monedas
  PowerUpType? activePowerUp; // Power-up actual equipado

  @override
  FutureOr<void> onLoad() async {
    final backgroundImage = await images.load('colored_grass.png');
    final spriteSheets = await Future.wait([
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_aliens.png',
        xmlPath: 'spritesheet_aliens.xml',
      ),
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_elements.png',
        xmlPath: 'spritesheet_elements.xml',
      ),
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_tiles.png',
        xmlPath: 'spritesheet_tiles.xml',
      ),
    ]);

    aliens = spriteSheets[0];
    elements = spriteSheets[1];
    tiles = spriteSheets[2];

    await world.add(Background(sprite: Sprite(backgroundImage)));

    // Mostrar el menú principal
    camera.viewport.add(MainMenu());

    return super.onLoad();
  }

  Future<void> startGame() async {
    if (gameStarted) return;
    gameStarted = true;

    await addGround();
    await addWalls();
    unawaited(addBricks().then((_) => addEnemies()));
    await addPlayer();

    // Agregar marcador de puntuación
    camera.viewport.add(
      ScoreDisplay(
        getScore: () => score,
        getAttempts: () => playerAttempts,
        maxAttempts: maxAttempts,
        getCoins: () => coins,
        getActivePowerUp: () => activePowerUp,
        position: Vector2(camera.viewport.size.x / 2, 10),
      ),
    );

    // Agregar botón de salir
    camera.viewport.add(
      ExitButton(
        position: Vector2(camera.viewport.size.x - 10, 10),
      ),
    );
  }

  void exitToMenu() {
    // Reiniciar variables
    score = 0;
    playerAttempts = 0;
    gameEnded = false;
    gameStarted = false;
    enemiesFullyAdded = false;

    // Limpiar todos los componentes del mundo excepto el fondo
    final background = world.children.whereType<Background>().firstOrNull;
    world.removeAll(world.children);
    if (background != null) {
      world.add(background);
    }
    
    camera.viewport.removeAll(camera.viewport.children);

    // Mostrar el menú principal
    camera.viewport.add(MainMenu());
  }

  final _random = Random();

  Future<void> addBricks() async {
    for (var i = 0; i < 5; i++) {
      final type = BrickType.randomType;
      final size = BrickSize.randomSize;
      await world.add(
        Brick(
          type: type,
          size: size,
          damage: BrickDamage.some,
          position: Vector2(
            camera.visibleWorldRect.right / 3 +
                (_random.nextDouble() * 5 - 2.5),
            0,
          ),
          sprites: brickFileNames(
            type,
            size,
          ).map((key, filename) => MapEntry(key, elements.getSprite(filename))),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> addPlayer() async {
    final player = Player(
      Vector2(camera.visibleWorldRect.left * 2 / 3, 0),
      aliens.getSprite(PlayerColor.randomColor.fileName),
    );
    
    // Aplicar power-up si está activo
    if (activePowerUp != null) {
      player.powerUp = activePowerUp;
      activePowerUp = null; // Se consume al usarse
    }
    
    await world.add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!gameStarted || gameEnded) return;

    // Verificar si debe aparecer un nuevo jugador
    if (isMounted &&
        world.children.whereType<Player>().isEmpty &&
        world.children.whereType<Enemy>().isNotEmpty &&
        playerAttempts < maxAttempts) {
      playerAttempts++;
      addPlayer();
    }

    // Victoria: todos los enemigos eliminados
    if (isMounted &&
        enemiesFullyAdded &&
        world.children.whereType<Enemy>().isEmpty) {
      _showGameResult(true);
    }

    // Derrota: se acabaron los intentos
    if (isMounted &&
        enemiesFullyAdded &&
        playerAttempts >= maxAttempts &&
        world.children.whereType<Player>().isEmpty &&
        world.children.whereType<Enemy>().isNotEmpty) {
      _showGameResult(false);
    }
  }

  void _showGameResult(bool victory) {
    if (gameEnded) return;
    gameEnded = true;

    final stars = _calculateStars(victory);
    
    camera.viewport.add(
      GameResultOverlay(
        isVictory: victory,
        score: score,
        stars: stars,
        position: camera.viewport.size / 2,
        size: Vector2(
          camera.viewport.size.x * 0.8,
          camera.viewport.size.y * 0.6,
        ),
        onRestart: _restartGame,
      ),
    );
  }

  int _calculateStars(bool victory) {
    if (!victory) return 0;
    
    // 3 estrellas: más de 300 puntos
    // 2 estrellas: más de 200 puntos
    // 1 estrella: 200 puntos o menos
    if (score >= 300) return 3;
    if (score >= 200) return 2;
    return 1;
  }

  void _restartGame() {
    // Reiniciar el juego
    score = 0;
    playerAttempts = 0;
    gameEnded = false;
    gameStarted = false;
    enemiesFullyAdded = false;

    // Limpiar todos los componentes del mundo excepto el fondo
    final background = world.children.whereType<Background>().firstOrNull;
    world.removeAll(world.children);
    if (background != null) {
      world.add(background);
    }
    
    camera.viewport.removeAll(camera.viewport.children);

    // Mostrar el menú principal
    camera.viewport.add(MainMenu());
  }

  var enemiesFullyAdded = false;

  Future<void> addEnemies() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    for (var i = 0; i < 3; i++) {
      await world.add(
        Enemy(
          Vector2(
            camera.visibleWorldRect.right / 3 +
                (_random.nextDouble() * 7 - 3.5),
            (_random.nextDouble() * 3),
          ),
          aliens.getSprite(EnemyColor.randomColor.fileName),
        ),
      );
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    enemiesFullyAdded = true;
  }

  Future<void> addGround() {
    return world.addAll([
      for (
        var x = camera.visibleWorldRect.left;
        x < camera.visibleWorldRect.right + groundSize;
        x += groundSize
      )
        Ground(
          Vector2(x, (camera.visibleWorldRect.height - groundSize) / 2),
          tiles.getSprite('grass.png'),
        ),
    ]);
  }

  Future<void> addWalls() async {
    final wallThickness = 1.0;
    final worldHeight = camera.visibleWorldRect.height;

    await world.addAll([
      // Pared izquierda
      InvisibleWall(
        position: Vector2(camera.visibleWorldRect.left - wallThickness / 2, 0),
        size: Vector2(wallThickness, worldHeight * 2),
      ),
      // Pared derecha
      InvisibleWall(
        position: Vector2(camera.visibleWorldRect.right + wallThickness / 2, 0),
        size: Vector2(wallThickness, worldHeight * 2),
      ),
    ]);
  }
}