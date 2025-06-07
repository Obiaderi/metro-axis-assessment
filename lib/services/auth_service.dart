import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_state.dart';

class AuthService {
  static const String _authStateKey = 'auth_state';
  static const String _validOtp = '123456'; // Mock OTP for testing

  Future<AuthState> getAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authStateJson = prefs.getString(_authStateKey);

      log('Getting auth state from storage: $authStateJson');
      if (authStateJson != null) {
        final Map<String, dynamic> json = jsonDecode(authStateJson);
        final authState = AuthState.fromJson(json);
        log('Loaded auth state - isAuthenticated: ${authState.isAuthenticated}, phone: ${authState.phoneNumber}');
        return authState;
      }

      log('No auth state found in storage, returning initial state');
      return AuthState.initial();
    } catch (e) {
      log('Error loading auth state: $e');
      return AuthState.initial();
    }
  }

  Future<bool> saveAuthState(AuthState authState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authStateJson = jsonEncode(authState.toJson());
      log('Saving auth state to storage: $authStateJson');
      final result = await prefs.setString(_authStateKey, authStateJson);
      log('Auth state save result: $result');
      return result;
    } catch (e) {
      log('Error saving auth state: $e');
      return false;
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    // Mock OTP sending - in real app, this would call an API
    await Future.delayed(const Duration(seconds: 1));

    // Validate phone number format (basic validation)
    if (phoneNumber.length < 10) {
      return false;
    }

    return true;
  }

  Future<AuthState?> verifyOtp(String phoneNumber, String otp) async {
    // Mock OTP verification
    await Future.delayed(const Duration(seconds: 1));

    if (otp == _validOtp) {
      final authState = AuthState.authenticated(
        phoneNumber: phoneNumber,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      await saveAuthState(authState);
      return authState;
    }

    return null;
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      log('Logging out - removing auth state from storage');
      await prefs.remove(_authStateKey);
      log('Auth state removed successfully');
      return true;
    } catch (e) {
      log('Error during logout: $e');
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    final authState = await getAuthState();
    return authState.isAuthenticated;
  }
}
