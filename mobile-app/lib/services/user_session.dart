class UserSession {
  // Stores the currently logged-in user's data
  static Map<String, dynamic>? currentUser;

  // 1. SET SESSION (This fixes your Null Error!) 🛡️
  static void setUser(Map<String, dynamic> userData) {
    // We intercept the raw data from MongoDB and replace any 'null' with safe strings
    currentUser = {
      '_id': userData['_id'] ?? '',
      'name': userData['name'] ?? 'Unknown User',
      'email': userData['email'] ?? '',
      'role': userData['role'] ?? 'student',

      // 👇 The fix for the Profile Screen crash:
      'phone': userData['phone'] ?? 'Not provided',
      'location': userData['location'] ?? 'Location not set',
      'about': userData['about'] ?? 'Hey there! I am using Edunnect.',
      'profileImage': userData['profileImage'] ?? '',
    };
  }

  // 2. CLEAR SESSION (For Logging Out)
  static void clearSession() {
    currentUser = null;
    // Note: If you add SharedPreferences later to keep users logged in
    // after closing the app, you would clear the phone's storage here too.
  }

  // 3. CHECK STATUS (Helper to see if someone is logged in)
  static bool get isLoggedIn => currentUser != null;
}
