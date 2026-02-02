class UserSession {
  static Map<String, dynamic>? currentUser;

  // Add this method to clear the session
  static void clearSession() {
    currentUser = null;
    // Add any additional cleanup if needed (e.g., remove tokens from storage)
  }

  // ...existing code...
}
