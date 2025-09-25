import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class ServiceRequestService {
  static ServiceRequestService? _instance;
  static ServiceRequestService get instance =>
      _instance ??= ServiceRequestService._();

  ServiceRequestService._();

  // Get possible status values from Supabase enum
  Future<List<String>> getStatusOptions() async {
    // Usar los valores hardcodeados del enum real
    return ['Complete', 'Partial', 'Report', 'cancelled'];
  }

  SupabaseClient get client => SupabaseService.instance.client;

  // Get all service requests (for admin)
  Future<List<Map<String, dynamic>>> getAllServiceRequests() async {
    // Eliminado bucle sobre 'list' no definido. La lógica correcta está después de obtener la respuesta.
    try {
      final response = await client.from('service_requests').select('''
            *,
            customers(*),
            user_profiles!service_requests_technician_id_fkey(full_name),
            service_photos(*)
          ''').order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      final List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(response);
      // Agregar technician_name a cada registro usando user_profiles['full_name']
      for (final item in list) {
        if (item['user_profiles'] != null &&
            item['user_profiles'] is Map &&
            item['user_profiles']['full_name'] != null) {
          item['technician_name'] = item['user_profiles']['full_name'];
        } else {
          item['technician_name'] = '';
        }
      }
      return list;
    } catch (error) {
      print('Error fetching service requests: $error');
      return [];
    }
  }

  // Get service requests assigned to current user
  Future<List<Map<String, dynamic>>> getMyServiceRequests() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        print('User not authenticated');
        return [];
      }

      final response = await client
          .from('service_requests')
          .select('''
            *,
            customers(*),
            user_profiles!service_requests_technician_id_fkey(full_name),
            service_photos(*)
          ''')
          .or('technician_id.eq.${user.id},created_by.eq.${user.id}')
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching my service requests: $error');
      return [];
    }
  }

  // Get service requests by status
  Future<List<Map<String, dynamic>>> getServiceRequestsByStatus(
      String status) async {
    try {
      final response = await client.from('service_requests').select('''
            *,
            customers(*),
            user_profiles!service_requests_technician_id_fkey(full_name),
            service_photos(*)
          ''').eq('status', status).order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching service requests by status: $error');
      return [];
    }
  }

  // Create new service request with retry mechanism
  Future<Map<String, dynamic>?> createServiceRequest({
    required String customerId,
    String? technicianId,
    required String serviceType,
    required String title,
    String? description,
    String priority = 'medium',
    double? estimatedHours,
    double? hourlyRate,
    DateTime? scheduledDate,
  }) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final data = <String, dynamic>{
        'customer_id': customerId,
        'created_by': user.id,
        'service_type': serviceType,
        'title': title,
        'priority': priority,
      };

      // Only add non-null values
      if (technicianId != null && technicianId.isNotEmpty) {
        data['technician_id'] = technicianId;
      }
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      if (estimatedHours != null && estimatedHours > 0) {
        data['estimated_hours'] = estimatedHours;
      }
      if (hourlyRate != null && hourlyRate > 0) {
        data['hourly_rate'] = hourlyRate;
      }
      if (scheduledDate != null) {
        data['scheduled_date'] = scheduledDate.toIso8601String();
      }

      // Retry mechanism for service request creation
      int retries = 0;
      const maxRetries = 3;

      while (retries < maxRetries) {
        try {
          final response =
              await client.from('service_requests').insert(data).select('''
                *,
                customers(*),
                user_profiles!service_requests_technician_id_fkey(full_name)
              ''').single();

          return Map<String, dynamic>.from(response);
        } catch (e) {
          retries++;
          print('Service request creation attempt $retries failed: $e');

          if (retries >= maxRetries) {
            throw Exception(
                'Failed to create service request after $maxRetries attempts: $e');
          }

          // Wait before retry
          await Future.delayed(Duration(milliseconds: 1000 * retries));
        }
      }

      throw Exception('Failed to create service request');
    } catch (error) {
      print('Error creating service request: $error');
      return null;
    }
  }

  // Update service request
  Future<Map<String, dynamic>?> updateServiceRequest(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('service_requests')
          .update(updates)
          .eq('id', id)
          .select('''
            *,
            customers(*),
            user_profiles!service_requests_technician_id_fkey(full_name)
          ''').single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      print('Error updating service request: $error');
      return null;
    }
  }

  // Update service request status
  Future<void> updateStatus(String id, String status) async {
    final updates = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (status == 'completed') {
      updates['completed_date'] = DateTime.now().toIso8601String();
    }
    try {
      await client.from('service_requests').update(updates).eq('id', id);
      // Supabase devuelve [] si no hay filas afectadas, pero si la orden existe y el estado cambia, la respuesta puede ser vacía pero exitosa
      // Considerar éxito si no hay excepción
      return;
    } catch (error) {
      throw Exception(
          'Supabase error: ${error is PostgrestException ? error.message : error.toString()}');
    }
  }

  // Get service request by ID with null safety
  Future<Map<String, dynamic>?> getServiceRequestById(String id) async {
    try {
      final response = await client.from('service_requests').select('''
            *,
            customers(*),
            user_profiles!service_requests_technician_id_fkey(full_name, email, phone),
            service_photos(*),
            time_tracking(*)
          ''').eq('id', id).maybeSingle();

      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (error) {
      print('Failed to fetch service request: $error');
      return null;
    }
  }

  // Delete service request
  Future<void> deleteServiceRequest(String id) async {
    try {
      await client.from('service_requests').delete().eq('id', id);
    } catch (error) {
      print('Error deleting service request: $error');
    }
  }

  // Get dashboard stats with enhanced null safety
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        return {
          'pending': 0,
          'in_progress': 0,
          'completed': 0,
          'total': 0,
        };
      }

      // Get counts for different statuses with fallback values
      final pendingResponse = await client
          .from('service_requests')
          .select('id')
          .eq('status', 'pending')
          .count();

      final inProgressResponse = await client
          .from('service_requests')
          .select('id')
          .eq('status', 'in_progress')
          .count();

      final completedResponse = await client
          .from('service_requests')
          .select('id')
          .eq('status', 'completed')
          .count();

      final totalResponse =
          await client.from('service_requests').select('id').count();

      return {
        'pending': pendingResponse.count,
        'in_progress': inProgressResponse.count,
        'completed': completedResponse.count,
        'total': totalResponse.count,
      };
    } catch (error) {
      print('Error fetching dashboard stats: $error');
      return {
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
        'total': 0,
      };
    }
  }

  // Real-time subscription for service requests
  Stream<List<Map<String, dynamic>>> getServiceRequestsStream() {
    return client
        .from('service_requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) =>
            data.map((item) => Map<String, dynamic>.from(item)).toList());
  }

  // Real-time subscription for user's service requests
  Stream<List<Map<String, dynamic>>> getMyServiceRequestsStream() {
    final user = client.auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return client
        .from('service_requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .where((item) =>
                item['technician_id'] == user.id ||
                item['created_by'] == user.id)
            .map((item) => Map<String, dynamic>.from(item))
            .toList());
  }
}
