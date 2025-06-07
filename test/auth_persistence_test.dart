import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_axis/services/auth_service.dart';
import 'package:metro_axis/models/auth_state.dart';

void main() {
  group('Authentication Persistence Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should save and retrieve auth state correctly', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Create a test auth state
      final testAuthState = AuthState.authenticated(
        phoneNumber: '+1234567890',
        token: 'test_token_123',
      );

      // Save the auth state
      final saveResult = await authService.saveAuthState(testAuthState);
      expect(saveResult, isTrue);

      // Retrieve the auth state
      final retrievedAuthState = await authService.getAuthState();
      
      // Verify the retrieved state matches the saved state
      expect(retrievedAuthState.isAuthenticated, isTrue);
      expect(retrievedAuthState.phoneNumber, equals('+1234567890'));
      expect(retrievedAuthState.token, equals('test_token_123'));
    });

    test('should return initial state when no auth data is stored', () async {
      // Mock SharedPreferences with empty data
      SharedPreferences.setMockInitialValues({});

      final authState = await authService.getAuthState();
      
      expect(authState.isAuthenticated, isFalse);
      expect(authState.phoneNumber, isNull);
      expect(authState.token, isNull);
    });

    test('should verify OTP and save auth state', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      const phoneNumber = '+1234567890';
      const validOtp = '123456';

      // Verify OTP
      final authState = await authService.verifyOtp(phoneNumber, validOtp);
      
      expect(authState, isNotNull);
      expect(authState!.isAuthenticated, isTrue);
      expect(authState.phoneNumber, equals(phoneNumber));
      expect(authState.token, isNotNull);

      // Verify that the auth state was saved
      final retrievedAuthState = await authService.getAuthState();
      expect(retrievedAuthState.isAuthenticated, isTrue);
      expect(retrievedAuthState.phoneNumber, equals(phoneNumber));
    });

    test('should clear auth state on logout', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // First, save an auth state
      final testAuthState = AuthState.authenticated(
        phoneNumber: '+1234567890',
        token: 'test_token_123',
      );
      await authService.saveAuthState(testAuthState);

      // Verify it's saved
      var authState = await authService.getAuthState();
      expect(authState.isAuthenticated, isTrue);

      // Logout
      final logoutResult = await authService.logout();
      expect(logoutResult, isTrue);

      // Verify auth state is cleared
      authState = await authService.getAuthState();
      expect(authState.isAuthenticated, isFalse);
    });

    test('should check authentication status correctly', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Initially should not be authenticated
      var isAuth = await authService.isAuthenticated();
      expect(isAuth, isFalse);

      // Save an authenticated state
      final testAuthState = AuthState.authenticated(
        phoneNumber: '+1234567890',
        token: 'test_token_123',
      );
      await authService.saveAuthState(testAuthState);

      // Now should be authenticated
      isAuth = await authService.isAuthenticated();
      expect(isAuth, isTrue);
    });

    test('should handle invalid OTP correctly', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      const phoneNumber = '+1234567890';
      const invalidOtp = '000000';

      // Verify invalid OTP
      final authState = await authService.verifyOtp(phoneNumber, invalidOtp);
      
      expect(authState, isNull);

      // Verify no auth state was saved
      final retrievedAuthState = await authService.getAuthState();
      expect(retrievedAuthState.isAuthenticated, isFalse);
    });

    test('should validate phone number format', () async {
      const shortPhoneNumber = '123';
      const validPhoneNumber = '1234567890';

      // Test short phone number
      final shortResult = await authService.sendOtp(shortPhoneNumber);
      expect(shortResult, isFalse);

      // Test valid phone number
      final validResult = await authService.sendOtp(validPhoneNumber);
      expect(validResult, isTrue);
    });
  });
}
