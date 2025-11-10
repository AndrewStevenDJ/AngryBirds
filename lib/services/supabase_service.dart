import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    if (_client != null) return;
    
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase no ha sido inicializado. Llama a initialize() primero.');
    }
    return _client!;
  }

  // Guardar puntaje
  static Future<bool> saveScore({
    required String username,
    required int score,
    required int stars,
    required int coins,
  }) async {
    try {
      await client.from(SupabaseConfig.scoresTable).insert({
        'username': username,
        'score': score,
        'stars': stars,
        'coins': coins,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error al guardar puntaje: $e');
      return false;
    }
  }

  // Obtener top 10 puntajes
  static Future<List<Map<String, dynamic>>> getTopScores({int limit = 10}) async {
    try {
      final response = await client
          .from(SupabaseConfig.scoresTable)
          .select()
          .order('score', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener puntajes: $e');
      return [];
    }
  }

  // Obtener puntajes del usuario
  static Future<List<Map<String, dynamic>>> getUserScores(String username) async {
    try {
      final response = await client
          .from(SupabaseConfig.scoresTable)
          .select()
          .eq('username', username)
          .order('score', ascending: false)
          .limit(5);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener puntajes del usuario: $e');
      return [];
    }
  }

  // Guardar/actualizar power-ups del usuario
  static Future<bool> saveUserPowerUps({
    required String username,
    required Map<String, int> powerUps,
  }) async {
    try {
      // Buscar si ya existe el usuario
      final existing = await client
          .from(SupabaseConfig.powerupsTable)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await client
            .from(SupabaseConfig.powerupsTable)
            .update({
              'explosive': powerUps['explosive'] ?? 0,
              'heavy': powerUps['heavy'] ?? 0,
              'splitter': powerUps['splitter'] ?? 0,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('username', username);
      } else {
        // Insertar
        await client.from(SupabaseConfig.powerupsTable).insert({
          'username': username,
          'explosive': powerUps['explosive'] ?? 0,
          'heavy': powerUps['heavy'] ?? 0,
          'splitter': powerUps['splitter'] ?? 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      return true;
    } catch (e) {
      print('Error al guardar power-ups: $e');
      return false;
    }
  }

  // Obtener power-ups del usuario
  static Future<Map<String, int>> getUserPowerUps(String username) async {
    try {
      final response = await client
          .from(SupabaseConfig.powerupsTable)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response != null) {
        return {
          'explosive': response['explosive'] ?? 0,
          'heavy': response['heavy'] ?? 0,
          'splitter': response['splitter'] ?? 0,
        };
      }
      return {'explosive': 0, 'heavy': 0, 'splitter': 0};
    } catch (e) {
      print('Error al obtener power-ups: $e');
      return {'explosive': 0, 'heavy': 0, 'splitter': 0};
    }
  }
}
