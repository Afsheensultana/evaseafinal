import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static String? token;
  static String? name;
  static String? email;
  static String? role;
  static String? id;
  static String? idToken;

  static Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("session_token", token ?? "");
    await prefs.setString("session_id_token", idToken ?? "");
    await prefs.setString("session_name", name ?? "");
    await prefs.setString("session_email", email ?? "");
    await prefs.setString("session_role", role ?? "");
    await prefs.setString("session_id", id ?? "");
  }

  static Future<bool> restore() async {
    final prefs = await SharedPreferences.getInstance();

    final savedToken = prefs.getString("session_token");
    final savedIdToken = prefs.getString("session_id_token");
    final savedRole = prefs.getString("session_role");

    if (savedToken == null || savedToken.isEmpty || savedRole == null || savedRole.isEmpty) {
      return false;
    }

    token = savedToken;
    idToken = (savedIdToken != null && savedIdToken.isNotEmpty) ? savedIdToken : null;
    name = _nullIfEmpty(prefs.getString("session_name"));
    email = _nullIfEmpty(prefs.getString("session_email"));
    role = savedRole;
    id = _nullIfEmpty(prefs.getString("session_id"));
    return true;
  }

  static String? _nullIfEmpty(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static void clear() {
    token = null;
    name = null;
    email = null;
    role = null;
    id = null;
    idToken = null;

    SharedPreferences.getInstance().then((prefs) {
      prefs.remove("session_token");
      prefs.remove("session_id_token");
      prefs.remove("session_name");
      prefs.remove("session_email");
      prefs.remove("session_role");
      prefs.remove("session_id");
    });
  }
}
