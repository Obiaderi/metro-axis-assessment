import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState.initial()) {
    _loadAuthState();
  }
  
  Future<void> _loadAuthState() async {
    final authState = await _authService.getAuthState();
    state = authState;
  }
  
  Future<bool> sendOtp(String phoneNumber) async {
    return await _authService.sendOtp(phoneNumber);
  }
  
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    final authState = await _authService.verifyOtp(phoneNumber, otp);
    if (authState != null) {
      state = authState;
      return true;
    }
    return false;
  }
  
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.initial();
  }
}
