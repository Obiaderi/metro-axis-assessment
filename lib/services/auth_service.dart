import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_state.dart';

class AuthService {
  static const String _authStateKey = 'auth_state';
  static const String _validOtp = '123456'; // Mock OTP for testing
  
  Future<AuthState> getAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authStateJson = prefs.getString(_authStateKey);
      
      if (authStateJson != null) {
        final Map<String, dynamic> json = jsonDecode(authStateJson);
        return AuthState.fromJson(json);
      }
      
      return AuthState.initial();
    } catch (e) {
      return AuthState.initial();
    }
  }
  
  Future<bool> saveAuthState(AuthState authState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authStateJson = jsonEncode(authState.toJson());
      return await prefs.setString(_authStateKey, authStateJson);
    } catch (e) {
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
      await prefs.remove(_authStateKey);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> isAuthenticated() async {
    final authState = await getAuthState();
    return authState.isAuthenticated;
  }
}
