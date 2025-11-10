import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../services/user_service.dart';
import 'game.dart';

class SaveScoreDialog extends PositionComponent with HasGameReference<MyPhysicsGame> {
  final int score;
  final int stars;
  final VoidCallback onComplete;
  
  String _username = '';
  bool _isSaving = false;
  String? _errorMessage;

  SaveScoreDialog({
    required this.score,
    required this.stars,
    required this.onComplete,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final viewportSize = game.camera.viewport.size;
    size = viewportSize;
    position = Vector2.zero();

    // Fondo semi-transparente
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.black.withOpacity(0.8),
      ),
    );

    // Cargar usuario guardado (si existe) para pre-llenar el diálogo
    final savedUsername = await UserService.getUsername();
    _username = savedUsername ?? '';

    // Siempre mostrar el diálogo para confirmar/cambiar el nombre
    _showUsernameDialog();
  }

  void _showUsernameDialog() {
    final context = game.context;
    if (context == null) {
      // Si no hay contexto, usar nombre por defecto
      _username = 'Player${DateTime.now().millisecondsSinceEpoch % 1000}';
      _saveScore();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Pre-llenar con el nombre guardado si existe
        final controller = TextEditingController(text: _username);
        
        return AlertDialog(
          title: const Text(
            '¡Partida Terminada!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Puntaje: $score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Icon(
                    Icons.star,
                    color: index < stars ? Colors.yellow : Colors.grey,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: 'Tu nombre',
                  hintText: 'Ingresa tu nombre de usuario',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  helperText: _username.isNotEmpty ? 'Presiona Enter para usar "$_username"' : null,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.of(dialogContext).pop();
                    _username = value;
                    _saveScore();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _username = 'Anónimo${DateTime.now().millisecondsSinceEpoch % 1000}';
                _saveScore();
              },
              child: const Text('SALTAR'),
            ),
            ElevatedButton(
              onPressed: () {
                final username = controller.text.trim();
                if (username.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  _username = username;
                  _saveScore();
                } else {
                  // Mostrar error
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa un nombre'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('GUARDAR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveScore() async {
    if (_isSaving) return;
    
    _isSaving = true;

    try {
      // Guardar nombre de usuario
      await UserService.saveUsername(_username);
      
      // Guardar puntaje en Supabase
      final success = await SupabaseService.saveScore(
        username: _username,
        score: score,
        stars: stars,
        coins: game.coins,
      );

      if (success) {
        onComplete();
      } else {
        _errorMessage = 'Error al guardar el puntaje';
        _isSaving = false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isSaving = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_username.isEmpty && !_isSaving) {
      // Mostrar mensaje pidiendo nombre
      _drawText(
        canvas,
        '¡Partida Terminada!',
        Vector2(size.x / 2, size.y * 0.3),
        Colors.yellow,
        36,
      );

      _drawText(
        canvas,
        'Puntaje: $score',
        Vector2(size.x / 2, size.y * 0.4),
        Colors.white,
        28,
      );

      _drawText(
        canvas,
        'Ingresa tu nombre para guardar',
        Vector2(size.x / 2, size.y * 0.5),
        Colors.white70,
        20,
      );

      _drawText(
        canvas,
        '(El nombre se pedirá en un diálogo)',
        Vector2(size.x / 2, size.y * 0.6),
        Colors.white54,
        16,
      );
    } else if (_isSaving) {
      _drawText(
        canvas,
        'Guardando puntaje...',
        Vector2(size.x / 2, size.y / 2),
        Colors.yellow,
        28,
      );
    }

    if (_errorMessage != null) {
      _drawText(
        canvas,
        _errorMessage!,
        Vector2(size.x / 2, size.y * 0.7),
        Colors.red,
        20,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Vector2 position,
    Color color,
    double fontSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.x - textPainter.width / 2,
        position.y - textPainter.height / 2,
      ),
    );
  }
}
