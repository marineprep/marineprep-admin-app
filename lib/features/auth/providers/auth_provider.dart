import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<AppUser?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.currentUser;
});

// Auth notifier for managing auth operations
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    final user = _authService.currentUser;
    if (user != null) {
      log('User is already authenticated: ${user.email}');
      state = AsyncValue.data(user);
    } else {
      log('No authenticated user found');
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      log('Starting sign up process for: $email');
      state = const AsyncValue.loading();
      
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        final user = AppUser(
          id: response.user!.id,
          email: response.user!.email ?? '',
          fullName: response.user!.userMetadata?['full_name'] as String?,
          avatarUrl: response.user!.userMetadata?['avatar_url'] as String?,
          createdAt: DateTime.parse(response.user!.createdAt),
          updatedAt: DateTime.parse(response.user!.updatedAt ?? response.user!.createdAt),
        );
        
        log('Sign up successful for: ${user.email}');
        state = AsyncValue.data(user);
      } else {
        log('Sign up failed: No user returned');
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      log('Sign up error: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      log('Starting sign in process for: $email');
      state = const AsyncValue.loading();
      
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = AppUser(
          id: response.user!.id,
          email: response.user!.email ?? '',
          fullName: response.user!.userMetadata?['full_name'] as String?,
          avatarUrl: response.user!.userMetadata?['avatar_url'] as String?,
          createdAt: DateTime.parse(response.user!.createdAt),
          updatedAt: DateTime.parse(response.user!.updatedAt ?? response.user!.createdAt),
        );
        
        log('Sign in successful for: ${user.email}');
        state = AsyncValue.data(user);
      } else {
        log('Sign in failed: No user returned');
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      log('Sign in error: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      log('Starting sign out process');
      state = const AsyncValue.loading();
      
      await _authService.signOut();
      
      log('Sign out successful');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      log('Sign out error: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      log('Starting password reset for: $email');
      await _authService.resetPassword(email);
      log('Password reset email sent successfully');
    } catch (error, stackTrace) {
      log('Password reset error: $error');
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      log('Starting profile update');
      
      final response = await _authService.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      if (response.user != null) {
        final user = AppUser(
          id: response.user!.id,
          email: response.user!.email ?? '',
          fullName: response.user!.userMetadata?['full_name'] as String?,
          avatarUrl: response.user!.userMetadata?['avatar_url'] as String?,
          createdAt: DateTime.parse(response.user!.createdAt),
          updatedAt: DateTime.parse(response.user!.updatedAt ?? response.user!.createdAt),
        );
        
        log('Profile update successful');
        state = AsyncValue.data(user);
      }
    } catch (error, stackTrace) {
      log('Profile update error: $error');
      rethrow;
    }
  }

  void refresh() {
    _initializeAuth();
  }
}
