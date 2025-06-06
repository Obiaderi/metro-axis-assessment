import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required bool isAuthenticated,
    String? phoneNumber,
    String? token,
    DateTime? lastLogin,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) => _$AuthStateFromJson(json);

  factory AuthState.initial() => const AuthState(
    isAuthenticated: false,
  );

  factory AuthState.authenticated({
    required String phoneNumber,
    required String token,
  }) => AuthState(
    isAuthenticated: true,
    phoneNumber: phoneNumber,
    token: token,
    lastLogin: DateTime.now(),
  );
}
