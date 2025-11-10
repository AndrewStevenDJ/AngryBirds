import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';
import 'package:flutter/material.dart';

import '../services/user_service.dart';
import 'background.dart';
import 'brick.dart';
import 'enemy.dart';
import 'exit_button.dart';
import 'game_result_overlay.dart';
import 'ground.dart';
import 'invisible_wall.dart';
import 'level_selector.dart';
import 'main_menu.dart';
import 'player.dart';
import 'save_score_dialog.dart';
import 'score_display.dart';
import 'shop_menu.dart';

class MyPhysicsGame extends Forge2DGame with HasGameReference {
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
  
  // BuildContext para mostrar diálogos
  BuildContext? context;
  
  // Configuración del nivel actual
  LevelDifficulty currentDifficulty = LevelDifficulty.normal;
  LevelConfig get currentLevel => levelConfigs[currentDifficulty]!;

  @override
  FutureOr<void> onLoad() async {
    // Cargar monedas guardadas
    await _loadCoins();
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

  Future<void> startGame({LevelDifficulty? difficulty}) async {
    if (gameStarted) return;
    gameStarted = true;
    
    // Establecer dificultad
    if (difficulty != null) {
      currentDifficulty = difficulty;
    }

    await addGround();
    await addWalls();
    
    // Construir todo el nivel instantáneamente sin delays
    await _buildLevelInstantly();
    
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

  // Construir todo el nivel instantáneamente (bloques + enemigos)
  Future<void> _buildLevelInstantly() async {
    final centerX = camera.visibleWorldRect.right * 0.55;
    final groundY = (camera.visibleWorldRect.height - groundSize) / 2;
    
    // Crear todos los bloques sin delay
    switch (currentDifficulty) {
      case LevelDifficulty.normal:
        // Casa simple: Piso + Columnas + Techo
        _addBrickInstant(Vector2(centerX, groundY - 1.75), BrickType.wood, BrickSize.size220x70);
        _addBrickInstant(Vector2(centerX - 5.5, groundY - 6.5), BrickType.stone, BrickSize.size70x220);
        _addBrickInstant(Vector2(centerX + 5.5, groundY - 6.5), BrickType.stone, BrickSize.size70x220);
        _addBrickInstant(Vector2(centerX, groundY - 11.75), BrickType.metal, BrickSize.size220x70);
        break;
        
      case LevelDifficulty.hard:
        // Torres gemelas: Bases cuadradas + Columnas altas + Piso central + Columnas medias + Plataforma + Techo
        // Torre izquierda
        _addBrickInstant(Vector2(centerX - 10.5, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
        _addBrickInstant(Vector2(centerX - 10.5, groundY - 9), BrickType.stone, BrickSize.size70x220);
        // Torre derecha
        _addBrickInstant(Vector2(centerX + 10.5, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
        _addBrickInstant(Vector2(centerX + 10.5, groundY - 9), BrickType.stone, BrickSize.size70x220);
        // Centro
        _addBrickInstant(Vector2(centerX, groundY - 1.75), BrickType.glass, BrickSize.size220x70);
        _addBrickInstant(Vector2(centerX - 3.5, groundY - 5.25), BrickType.wood, BrickSize.size70x140);
        _addBrickInstant(Vector2(centerX + 3.5, groundY - 5.25), BrickType.wood, BrickSize.size70x140);
        _addBrickInstant(Vector2(centerX, groundY - 8.75), BrickType.metal, BrickSize.size220x70);
        _addBrickInstant(Vector2(centerX, groundY - 13.5), BrickType.stone, BrickSize.size220x70);
        break;
        
      case LevelDifficulty.boss:
        // Pirámide escalonada: 4 bases + 4 columnas nivel 1 + plataforma + 2 columnas nivel 2 + plataforma + columna final + techo
        // Nivel 1 - Base ancha (4 bloques cuadrados)
        _addBrickInstant(Vector2(centerX - 10.5, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
        _addBrickInstant(Vector2(centerX - 3.5, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
        _addBrickInstant(Vector2(centerX + 3.5, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
        _addBrickInstant(Vector2(centerX + 10.5, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
        // Columnas nivel 1
        _addBrickInstant(Vector2(centerX - 10.5, groundY - 7), BrickType.stone, BrickSize.size70x140);
        _addBrickInstant(Vector2(centerX - 3.5, groundY - 7), BrickType.stone, BrickSize.size70x140);
        _addBrickInstant(Vector2(centerX + 3.5, groundY - 7), BrickType.stone, BrickSize.size70x140);
        _addBrickInstant(Vector2(centerX + 10.5, groundY - 7), BrickType.stone, BrickSize.size70x140);
        // Plataforma nivel 2
        _addBrickInstant(Vector2(centerX, groundY - 10.5), BrickType.glass, BrickSize.size220x70);
        // Columnas nivel 2
        _addBrickInstant(Vector2(centerX - 3.5, groundY - 13.5), BrickType.metal, BrickSize.size70x140);
        _addBrickInstant(Vector2(centerX + 3.5, groundY - 13.5), BrickType.metal, BrickSize.size70x140);
        // Plataforma nivel 3
        _addBrickInstant(Vector2(centerX, groundY - 17), BrickType.metal, BrickSize.size220x70);
        // Columna final
        _addBrickInstant(Vector2(centerX, groundY - 20), BrickType.stone, BrickSize.size70x140);
        // Techo
        _addBrickInstant(Vector2(centerX, groundY - 22.25), BrickType.stone, BrickSize.size140x70);
        break;
    }
    
    // Delay más largo para que los bloques se asienten completamente
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    // Crear todos los enemigos inmediatamente en sus posiciones finales
    final enemyCount = currentLevel.enemyCount;
    
    for (var i = 0; i < enemyCount; i++) {
      double x, y;
      
      switch (currentDifficulty) {
        case LevelDifficulty.normal:
          // 3 enemigos dentro de la casa entre las columnas
          if (i == 0) {
            x = centerX - 2;
            y = groundY - 4.5;
          } else if (i == 1) {
            x = centerX;
            y = groundY - 4.5;
          } else {
            x = centerX + 2;
            y = groundY - 4.5;
          }
          break;
        
        case LevelDifficulty.hard:
          // 4 enemigos: 2 abajo, 2 en plataforma media
          if (i == 0) {
            x = centerX - 2.5;
            y = groundY - 4.5;
          } else if (i == 1) {
            x = centerX + 2.5;
            y = groundY - 4.5;
          } else if (i == 2) {
            x = centerX - 2.5;
            y = groundY - 11.5;
          } else {
            x = centerX + 2.5;
            y = groundY - 11.5;
          }
          break;
        
        case LevelDifficulty.boss:
          // 5 enemigos distribuidos en la base + Boss en la cima
          if (i == 0) {
            x = centerX - 7;
            y = groundY - 8.5;
          } else if (i == 1) {
            x = centerX - 2;
            y = groundY - 8.5;
          } else if (i == 2) {
            x = centerX + 2;
            y = groundY - 8.5;
          } else if (i == 3) {
            x = centerX + 7;
            y = groundY - 8.5;
          } else {
            // Boss en la plataforma superior
            x = centerX;
            y = groundY - 19.5;
          }
          break;
      }
      
      final isBoss = currentLevel.hasBoss && i == enemyCount - 1;
      final enemyColor = EnemyColor.randomColor;
      final spriteFileName = isBoss ? EnemyColor.randomBossColor.fileName : enemyColor.fileName;
      final points = isBoss ? 500 : 100;
      
      await world.add(
        Enemy(
          Vector2(x, y),
          aliens.getSprite(spriteFileName),
          pointValue: points,
          isBoss: isBoss,
        ),
      );
    }
    
    enemiesFullyAdded = true;
  }

  void _addBrickInstant(Vector2 position, BrickType type, BrickSize size) {
    world.add(
      Brick(
        type: type,
        size: size,
        damage: BrickDamage.none,
        position: position,
        sprites: brickFileNames(
          type,
          size,
        ).map((key, filename) => MapEntry(key, elements.getSprite(filename))),
      ),
    );
  }

  Future<void> addBricks() async {
    // Crear estructuras tipo Angry Birds según el nivel
    switch (currentDifficulty) {
      case LevelDifficulty.normal:
        await _buildSimpleStructure();
        break;
      case LevelDifficulty.hard:
        await _buildMediumStructure();
        break;
      case LevelDifficulty.boss:
        await _buildBossStructure();
        break;
    }
  }

  // Estructura simple para nivel normal - Casa pequeña clásica
  Future<void> _buildSimpleStructure() async {
    final centerX = camera.visibleWorldRect.right * 0.55;
    final groundY = (camera.visibleWorldRect.height - groundSize) / 2;

    // PISO: Base de madera horizontal (220x70)
    await _addBrickSpecific(Vector2(centerX, groundY - 1.75), BrickType.wood, BrickSize.size220x70);

    // COLUMNAS: 2 bloques verticales de piedra (70x220) - Más altos y estables
    await _addBrickSpecific(Vector2(centerX - 5.5, groundY - 7), BrickType.stone, BrickSize.size70x220);
    await _addBrickSpecific(Vector2(centerX + 5.5, groundY - 7), BrickType.stone, BrickSize.size70x220);

    // TECHO: Bloque horizontal de metal (220x70)
    await _addBrickSpecific(Vector2(centerX, groundY - 12.25), BrickType.metal, BrickSize.size220x70);
  }

  // Estructura mediana para nivel difícil - Torre doble simétrica
  Future<void> _buildMediumStructure() async {
    final centerX = camera.visibleWorldRect.right * 0.55;
    final groundY = (camera.visibleWorldRect.height - groundSize) / 2;

    // === TORRE IZQUIERDA ===
    // Base izquierda: bloque cuadrado de madera (140x140)
    await _addBrickSpecific(Vector2(centerX - 10.5, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
    
    // Columna izquierda: bloque vertical alto (70x220)
    await _addBrickSpecific(Vector2(centerX - 10.5, groundY - 9.5), BrickType.stone, BrickSize.size70x220);

    // === TORRE DERECHA (SIMÉTRICA) ===
    // Base derecha: bloque cuadrado de madera (140x140)
    await _addBrickSpecific(Vector2(centerX + 10.5, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
    
    // Columna derecha: bloque vertical alto (70x220)
    await _addBrickSpecific(Vector2(centerX + 10.5, groundY - 9.5), BrickType.stone, BrickSize.size70x220);

    // === CONEXIÓN CENTRAL ===
    // Piso central: bloque horizontal largo (220x70)
    await _addBrickSpecific(Vector2(centerX, groundY - 1.75), BrickType.glass, BrickSize.size220x70);

    // Columnas centrales: bloques verticales (70x140)
    await _addBrickSpecific(Vector2(centerX - 3.5, groundY - 5.25), BrickType.wood, BrickSize.size70x140);
    await _addBrickSpecific(Vector2(centerX + 3.5, groundY - 5.25), BrickType.wood, BrickSize.size70x140);

    // Plataforma media: bloque horizontal (220x70)
    await _addBrickSpecific(Vector2(centerX, groundY - 8.75), BrickType.metal, BrickSize.size220x70);

    // Techo superior: bloque horizontal largo (220x70)
    await _addBrickSpecific(Vector2(centerX, groundY - 14), BrickType.stone, BrickSize.size220x70);
  }

  // Estructura compleja para nivel boss - Castillo piramidal
  Future<void> _buildBossStructure() async {
    final centerX = camera.visibleWorldRect.right * 0.55;
    final groundY = (camera.visibleWorldRect.height - groundSize) / 2;

    // === NIVEL 1 (BASE) - MÁS ANCHO ===
    // Piso base: bloques cuadrados grandes (140x140)
    await _addBrickSpecific(Vector2(centerX - 14, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
    await _addBrickSpecific(Vector2(centerX - 7, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
    await _addBrickSpecific(Vector2(centerX + 7, groundY - 3.5), BrickType.wood, BrickSize.size140x140);
    await _addBrickSpecific(Vector2(centerX + 14, groundY - 3.5), BrickType.wood, BrickSize.size140x140);

    // Columnas nivel 1: bloques verticales (70x140)
    await _addBrickSpecific(Vector2(centerX - 14, groundY - 7), BrickType.stone, BrickSize.size70x140);
    await _addBrickSpecific(Vector2(centerX - 7, groundY - 7), BrickType.stone, BrickSize.size70x140);
    await _addBrickSpecific(Vector2(centerX + 7, groundY - 7), BrickType.stone, BrickSize.size70x140);
    await _addBrickSpecific(Vector2(centerX + 14, groundY - 7), BrickType.stone, BrickSize.size70x140);

    // === NIVEL 2 (MEDIO) - MÁS ESTRECHO ===
    // Plataforma nivel 2: bloque horizontal largo (220x70)
    await _addBrickSpecific(Vector2(centerX, groundY - 10.5), BrickType.glass, BrickSize.size220x70);

    // Columnas nivel 2: bloques verticales (70x140)
    await _addBrickSpecific(Vector2(centerX - 7, groundY - 14), BrickType.metal, BrickSize.size70x140);
    await _addBrickSpecific(Vector2(centerX + 7, groundY - 14), BrickType.metal, BrickSize.size70x140);

    // === NIVEL 3 (CIMA) - MÁS ESTRECHO ===
    // Plataforma nivel 3 para el Boss: bloque horizontal (220x70)
    await _addBrickSpecific(Vector2(centerX, groundY - 17.5), BrickType.metal, BrickSize.size220x70);

    // Columna central final: bloque vertical (70x140)
    await _addBrickSpecific(Vector2(centerX, groundY - 21), BrickType.stone, BrickSize.size70x140);

    // Techo final: bloque horizontal (140x70)
    await _addBrickSpecific(Vector2(centerX, groundY - 22.75), BrickType.stone, BrickSize.size140x70);
  }

  Future<void> _addBrickSpecific(Vector2 position, BrickType type, BrickSize size) async {
    await world.add(
      Brick(
        type: type,
        size: size,
        damage: BrickDamage.none,
        position: position,
        sprites: brickFileNames(
          type,
          size,
        ).map((key, filename) => MapEntry(key, elements.getSprite(filename))),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 80));
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
    
    // Primero mostrar el diálogo de guardar puntaje
    camera.viewport.add(
      SaveScoreDialog(
        score: score,
        stars: stars,
        onComplete: () {
          // Después de guardar, mostrar el overlay de resultado
          for (final dialog in camera.viewport.children.whereType<SaveScoreDialog>().toList()) {
            dialog.removeFromParent();
          }
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
        },
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
    // Esperar 3 segundos para que las estructuras se estabilicen completamente
    await Future<void>.delayed(const Duration(seconds: 3));
    final enemyCount = currentLevel.enemyCount;
    final centerX = camera.visibleWorldRect.right * 0.55;
    final groundY = (camera.visibleWorldRect.height - groundSize) / 2;
    
    for (var i = 0; i < enemyCount; i++) {
      // Posicionar enemigos SOBRE las plataformas (Y más alto para que caigan suavemente)
      double x, y;
      
      switch (currentDifficulty) {
        case LevelDifficulty.normal:
          // 3 enemigos caen desde muy arriba hacia dentro de la casa
          if (i == 0) {
            x = centerX - 2.5;
            y = groundY - 30; // Muy alto, caerán dentro
          } else if (i == 1) {
            x = centerX;
            y = groundY - 30;
          } else {
            x = centerX + 2.5;
            y = groundY - 30;
          }
          break;
        
        case LevelDifficulty.hard:
          // 4 enemigos caen desde muy arriba
          if (i == 0) {
            x = centerX - 3;
            y = groundY - 30;
          } else if (i == 1) {
            x = centerX + 3;
            y = groundY - 30;
          } else if (i == 2) {
            x = centerX - 3;
            y = groundY - 35; // Más alto para el segundo nivel
          } else {
            x = centerX + 3;
            y = groundY - 35;
          }
          break;
        
        case LevelDifficulty.boss:
          // 5 enemigos + boss caen desde muy arriba
          if (i == 0) {
            x = centerX - 10.5;
            y = groundY - 30;
          } else if (i == 1) {
            x = centerX - 3.5;
            y = groundY - 30;
          } else if (i == 2) {
            x = centerX + 3.5;
            y = groundY - 30;
          } else if (i == 3) {
            x = centerX + 10.5;
            y = groundY - 30;
          } else {
            // Boss cae desde MUY alto hacia la cima
            x = centerX;
            y = groundY - 40;
          }
          break;
      }
      
      // Para el nivel boss, el último enemigo es el boss
      final isBoss = currentLevel.hasBoss && i == enemyCount - 1;
      
      // Seleccionar sprite y puntos según si es boss o no
      final enemyColor = EnemyColor.randomColor;
      final spriteFileName = isBoss ? EnemyColor.randomBossColor.fileName : enemyColor.fileName;
      final points = isBoss ? 500 : 100;
      
      await world.add(
        Enemy(
          Vector2(x, y),
          aliens.getSprite(spriteFileName),
          pointValue: points,
          isBoss: isBoss,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 800));
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

  Future<void> _loadCoins() async {
    final savedCoins = await UserService.getCoins();
    coins = savedCoins;
  }

  Future<void> _saveCoins() async {
    await UserService.saveCoins(coins);
  }

  /// Agregar monedas y guardar automáticamente
  void addCoins(int amount) {
    coins += amount;
    _saveCoins();
  }

  /// Remover monedas y guardar automáticamente
  void removeCoins(int amount) {
    coins -= amount;
    _saveCoins();
  }
}