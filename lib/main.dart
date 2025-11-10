import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'components/game.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Variables de entorno cargadas');
  } catch (e) {
    print('⚠️ Error al cargar .env: $e');
    print('ℹ️ Asegúrate de tener un archivo .env en la raíz del proyecto');
  }
  
  // Inicializar Supabase
  try {
    await SupabaseService.initialize();
    print('✅ Supabase inicializado correctamente');
  } catch (e) {
    print('⚠️ Error al inicializar Supabase: $e');
    print('ℹ️ El juego funcionará sin conexión a la base de datos');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Angry Birds - Forge2D',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final MyPhysicsGame _game;

  @override
  void initState() {
    super.initState();
    _game = MyPhysicsGame();
  }

  @override
  Widget build(BuildContext context) {
    _game.context = context; // Pasar el contexto al juego
    
    return Scaffold(
      body: GameWidget(game: _game),
    );
  }
}
