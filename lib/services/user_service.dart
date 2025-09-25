import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  /// Actualiza el campo amount_paid de un técnico
  static Future<void> updateTechnicianAmountPaid({
    required String id,
    required double newAmountPaid,
  }) async {
    await _supabase.from('user_profiles').update({
      'amount_paid': newAmountPaid,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  static final SupabaseClient _supabase = Supabase.instance.client;

  // Create new technician user (IMPROVED VERSION)
  static Future<UserProfile> createTechnician({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'technician',
  }) async {
    try {
      // Create auth user with metadata (trigger will create profile automatically)
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone.isEmpty ? null : phone,
          'role': role,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      // Wait for trigger to complete and fetch the created profile with retry mechanism
      int retries = 0;
      const maxRetries = 5;
      const retryDelay = Duration(milliseconds: 1000);

      while (retries < maxRetries) {
        try {
          await Future.delayed(retryDelay * (retries + 1));

          final response = await _supabase
              .from('user_profiles')
              .select()
              .eq('id', authResponse.user!.id)
              .single();

          return UserProfile.fromJson(response);
        } catch (e) {
          retries++;
          if (retries >= maxRetries) {
            // If profile doesn't exist after retries, create it manually
            await _createUserProfileManually(
              userId: authResponse.user!.id,
              email: email,
              fullName: fullName,
              phone: phone,
              role: role,
            );

            final response = await _supabase
                .from('user_profiles')
                .select()
                .eq('id', authResponse.user!.id)
                .single();

            return UserProfile.fromJson(response);
          }
        }
      }

      throw Exception('Failed to create user profile after retries');
    } catch (e) {
      throw Exception('Failed to create technician: $e');
    }
  }

  // Helper method to create profile manually if trigger fails
  static Future<void> _createUserProfileManually({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
    required String role,
  }) async {
    await _supabase.from('user_profiles').insert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Update existing technician
  static Future<UserProfile> updateTechnician(
      {required String id,
      String? fullName,
      String? phone,
      bool? isActive,
      String? role,
      String? password}) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updateData['full_name'] = fullName;
    if (phone != null) updateData['phone'] = phone;
    if (isActive != null) updateData['is_active'] = isActive;
    if (role != null) updateData['role'] = role;

    final response = await _supabase
        .from('user_profiles')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

// ✅ Actualizar contraseña si se proporciona
    if (password != null && password.trim().isNotEmpty) {
      await _supabase.auth.admin.updateUserById(
        id,
        attributes: AdminUserAttributes(password: password),
      );
    }

    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (isActive != null) updateData['is_active'] = isActive;
      if (role != null) updateData['role'] = role;

      final response = await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update technician: $e');
    }
  }

  // Get all technicians (IMPROVED VERSION)
  static Future<List<UserProfile>> getAllTechnicians({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('role', 'technician')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((data) => UserProfile.fromJson(data))
          .toList();
    } catch (e) {
      print('Error fetching technicians: $e');
      return [];
    }
  }

  // Get all users (IMPROVED VERSION WITH REAL-TIME SYNC)
  static Future<List<UserProfile>> getAllUsers({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .where((data) => data != null && data['id'] != null)
          .map((data) {
            try {
              return UserProfile.fromJson(data);
            } catch (e) {
              print('Error parsing user profile: $e');
              return null;
            }
          })
          .where((profile) => profile != null)
          .cast<UserProfile>()
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Alias method for backward compatibility
  static Future<List<UserProfile>> getAllUserProfiles({
    bool forceRefresh = false,
  }) async {
    return await getAllUsers(forceRefresh: forceRefresh);
  }

  // Get all users (for admin management)
  static Future<List<UserProfile>> getAllUsersForAdmin() async {
    try {
      final response =
          await _supabase.from('user_profiles').select('*').order('full_name');

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .where((data) => data != null && data['id'] != null)
          .map((data) {
            try {
              return UserProfile.fromJson(data);
            } catch (e) {
              print('Error parsing user profile: $e');
              return null;
            }
          })
          .where((profile) => profile != null)
          .cast<UserProfile>()
          .toList();
    } catch (e) {
      print('Error fetching users for admin: $e');
      return [];
    }
  }

  // Get technician by ID
  static Future<UserProfile?> getTechnicianById(String id) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Failed to fetch technician by ID: $e');
      return null;
    }
  }

  // Delete technician (hard delete)
  static Future<void> deleteTechnician(String id) async {
    try {
      final response =
          await _supabase.from('user_profiles').delete().eq('id', id);

      // Si necesitas verificar algo, puedes imprimir el resultado
      print('Delete response: $response');
    } catch (e) {
      throw Exception('Failed to delete technician: $e');
    }
  }

  static Future<void> updatePassword(String id, String newPassword) async {
    await _supabase
        .from('user_profiles')
        .update({'password': newPassword}).eq('id', id);
  }

  // Get current user profile
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Failed to fetch current user profile: $e');
      return null;
    }
  }

  // Update current user profile
  static Future<UserProfile> updateCurrentUserProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;

      final response = await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Get technician performance metrics
  static Future<Map<String, dynamic>> getTechnicianMetrics(
    String technicianId,
  ) async {
    try {
      final serviceRequests = await _supabase
          .from('service_requests')
          .select('*')
          .eq('technician_id', technicianId);

      final totalOrders = serviceRequests.length;
      final completedOrders =
          serviceRequests.where((r) => r['status'] == 'completed').length;
      final pendingOrders =
          serviceRequests.where((r) => r['status'] == 'pending').length;
      final inProgressOrders =
          serviceRequests.where((r) => r['status'] == 'in_progress').length;
      final completionRate =
          totalOrders > 0 ? (completedOrders / totalOrders * 100) : 0.0;

      return {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'pendingOrders': pendingOrders,
        'inProgressOrders': inProgressOrders,
        'completionRate': completionRate,
        'averageRating': 0.0, // Rating functionality can be added later
      };
    } catch (e) {
      print('Failed to fetch technician metrics: $e');
      return {
        'totalOrders': 0,
        'completedOrders': 0,
        'pendingOrders': 0,
        'inProgressOrders': 0,
        'completionRate': 0.0,
        'averageRating': 0.0,
      };
    }
  }

  // Search technicians
  static Future<List<UserProfile>> searchTechnicians(String query) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('role', 'technician')
          .eq('is_active', true)
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .order('full_name');

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((data) => UserProfile.fromJson(data))
          .toList();
    } catch (e) {
      print('Failed to search technicians: $e');
      return [];
    }
  }

  // Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.isAdmin ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cambiarClaveUsuarioAdmin(
      String userId, String nuevaClave) async {
    final url = Uri.parse(
        'http://10.0.2.2:3000/change-password'); // Cambia localhost si tu backend está en otro host
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'new_password': nuevaClave,
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al cambiar clave (backend): ${response.body}');
      return false;
    }
  }

  // Get dashboard stats for admin
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get all users count by role
      final allUsers = await getAllUsersForAdmin();
      final adminCount = allUsers.where((u) => u.role == 'admin').length;
      final technicianCount =
          allUsers.where((u) => u.role == 'technician').length;

      // Get active/inactive counts
      final activeUsers = allUsers.where((u) => u.isActive).length;
      final inactiveUsers = allUsers.length - activeUsers;

      return {
        'totalUsers': allUsers.length,
        'adminCount': adminCount,
        'technicianCount': technicianCount,
        'activeUsers': activeUsers,
        'inactiveUsers': inactiveUsers,
      };
    } catch (e) {
      print('Failed to fetch dashboard stats: $e');
      return {
        'totalUsers': 0,
        'adminCount': 0,
        'technicianCount': 0,
        'activeUsers': 0,
        'inactiveUsers': 0,
      };
    }
  }

  // Real-time subscription for user profiles
  static Stream<List<UserProfile>> getUserProfilesStream() {
    return _supabase
        .from('user_profiles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .where((item) => item['id'] != null)
            .map((item) {
              try {
                return UserProfile.fromJson(item);
              } catch (e) {
                print('Error parsing user profile in stream: $e');
                return null;
              }
            })
            .where((profile) => profile != null)
            .cast<UserProfile>()
            .toList());
  }

  // Real-time subscription for technicians
  static Stream<List<UserProfile>> getTechniciansStream() {
    return _supabase.from('user_profiles').stream(primaryKey: ['id']).map(
      (data) => data
          .where(
            (item) => item['role'] == 'technician' && item['is_active'] == true,
          )
          .map((item) {
            try {
              return UserProfile.fromJson(item);
            } catch (e) {
              print('Error parsing technician in stream: $e');
              return null;
            }
          })
          .where((profile) => profile != null)
          .cast<UserProfile>()
          .toList(),
    );
  }
}
