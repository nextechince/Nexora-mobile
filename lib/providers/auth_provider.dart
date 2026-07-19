import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<User?> build() async {
    final authService = ref.watch(authServiceProvider);
    return authService.getCurrentUser();
  }

  Future<void> signInWithPhone(String phone) async {
    final authService = ref.watch(authServiceProvider);
    await authService.signInWithPhone(phone);
  }

  Future<User> verifyOTP(String phone, String otp) async {
    final authService = ref.watch(authServiceProvider);
    final user = await authService.verifyOTP(phone, otp);
    state = AsyncData(user);
    return user;
  }

  Future<void> logout() async {
    final authService = ref.watch(authServiceProvider);
    await authService.logout();
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    final authService = ref.watch(authServiceProvider);
    await authService.deleteAccount();
    state = const AsyncData(null);
  }
}

@riverpod
bool isLoggedIn(AuthStateRef ref) {
  final auth = ref.watch(authStateProvider);
  return auth.value != null;
}

@riverpod
User? currentUser(AuthStateRef ref) {
  final auth = ref.watch(authStateProvider);
  return auth.value;
}