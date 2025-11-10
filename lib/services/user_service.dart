import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _usernameKey = 'username';
  static const String _coinsKey = 'coins';

  // Guardar nombre de usuario
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  // Obtener nombre de usuario
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Guardar monedas localmente
  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  // Obtener monedas localmente
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 100; // 100 monedas iniciales
  }

  // Limpiar datos
  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
