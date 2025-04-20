import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart'; // Assuming you have AuthService defined

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthProvider, User?>(
  (ref) => AuthProvider(ref.read(authServiceProvider)),
);

class AuthProvider extends StateNotifier<User?> {
  final AuthService _authService;

  AuthProvider(this._authService) : super(_authService.currentUser);

  Future<void> register(String email, String password) async {
    try {
      await _authService.register(email, password);
      state = _authService.currentUser;
    } catch (e) {
      // Handle registration errors (e.g., display error messages)
      print("Registration Error: $e");
      rethrow; // Re-throw the error for the UI to handle
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      state = _authService.currentUser;
    } catch (e) {
      // Handle login errors
      print("Login Error: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = null;
    } catch (e) {
      // Handle logout errors
      print("Logout Error: $e");
      rethrow;
    }
  }

  bool get isAuthenticated => _authService.currentUser != null;
}