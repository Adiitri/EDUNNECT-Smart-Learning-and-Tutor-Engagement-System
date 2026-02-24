class UserSession {
  // Stores the currently logged-in user's data
  static Map<String, dynamic>? currentUser;

  // 1. SET SESSION (This fixes your Null Error!) 🛡️
  static void setUser(Map<String, dynamic> userData) {
    // parse coordinates from a geo field if present
    double lat = 0, lng = 0;
    if (userData['location'] is Map) {
      final coords = userData['location']['coordinates'];
      if (coords is List && coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    }

    // We intercept the raw data from MongoDB and replace any 'null' with safe strings
    currentUser = {
      '_id': userData['_id'] ?? '',
      'name': userData['name'] ?? 'Unknown User',
      'email': userData['email'] ?? '',
      'role': userData['role'] ?? 'student',

      // profile fields
      'phone': userData['phone'] ?? 'Not provided',
      // locationText is the human string; keep backwards compat with 'location'
      'location': userData['locationText'] ?? userData['location'] ?? 'Location not set',
      'latitude': lat,
      'longitude': lng,
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
