import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/user.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get current user
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
    );
  }

  // Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      log('Signing up user with email: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
        },
      );

      if (response.user != null) {
        log('User signed up successfully: ${response.user!.email}');
      } else {
        log('Sign up failed: ${response.session}');
      }

      return response;
    } catch (e) {
      log('Error during sign up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      log('Signing in user with email: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        log('User signed in successfully: ${response.user!.email}');
      } else {
        log('Sign in failed: ${response.session}');
      }

      return response;
    } catch (e) {
      log('Error during sign in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      log('Signing out user');
      await _supabase.auth.signOut();
      log('User signed out successfully');
    } catch (e) {
      log('Error during sign out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      log('Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      log('Password reset email sent successfully');
    } catch (e) {
      log('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      log('Updating user profile');
      
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (fullName != null) 'full_name': fullName,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );

      if (response.user != null) {
        log('User profile updated successfully');
      }

      return response;
    } catch (e) {
      log('Error updating user profile: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;
}
