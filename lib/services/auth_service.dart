import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp(
    String email,
    String password, {
    String? fullName,
    String? role,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? email.split('@')[0],
          'role': role ?? 'technician',
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Alias for backward compatibility
  static Future<void> logout() async {
    await AuthService.instance.signOut();
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Update user profile
  Future<void> updateProfile({String? fullName, String? phone}) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id);
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }

  // Change password for authenticated user
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // First verify the current password by attempting to sign in
      final email = currentUser!.email!;
      final testResponse = await client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      if (testResponse.user == null) {
        throw Exception('Current password is incorrect');
      }

      // Update password using Supabase Auth API
      final response = await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Failed to update password');
      }
    } catch (error) {
      if (error.toString().contains('Invalid login credentials')) {
        throw Exception('Current password is incorrect');
      }
      throw Exception('Password change failed: $error');
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'https://yourapp.com/reset-password', // Update with your actual redirect URL
      );
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Update password with recovery token
  Future<void> updatePasswordWithToken({
    required String accessToken,
    required String refreshToken,
    required String newPassword,
  }) async {
    try {
      // Set session with the tokens
      await client.auth.setSession(accessToken);

      // Update password
      final response = await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Failed to update password');
      }
    } catch (error) {
      throw Exception('Password update failed: $error');
    }
  }

  // Check if user has specific role
  Future<bool> hasRole(String role) async {
    final profile = await getCurrentUserProfile();
    return profile?['role'] == role;
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    return await hasRole('admin');
  }

  // Check if user is technician
  Future<bool> isTechnician() async {
    return await hasRole('technician');
  }
}
