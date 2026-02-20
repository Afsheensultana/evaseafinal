class AppSession {
  static String? token;
  static String? name;
  static String? role;
  static String? id;
  static String? idToken;

  static void clear() {
    token = null;
    name = null;
    role = null;
    id = null;
    idToken = null;
  }
}
