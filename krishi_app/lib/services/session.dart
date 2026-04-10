/// Simple in-memory session store.
/// Holds the JWT token and basic user info after login/signup.
class Session {
  static String? token;
  static String? name;
  static String? email;

  static bool get isLoggedIn => token != null;

  static void save({required String t, required String n, required String e}) {
    token = t;
    name  = n;
    email = e;
  }

  static void clear() {
    token = null;
    name  = null;
    email = null;
  }
}
