import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class CustomerService {
  static CustomerService? _instance;
  static CustomerService get instance => _instance ??= CustomerService._();

  CustomerService._();

  SupabaseClient get client => SupabaseService.instance.client;

  // Get all customers
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      final response = await client
          .from('customers')
          .select()
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch customers: $error');
    }
  }

  // Get customer by ID
  Future<Map<String, dynamic>?> getCustomerById(String id) async {
    try {
      final response =
          await client.from('customers').select().eq('id', id).single();
      return response;
    } catch (error) {
      print('Failed to fetch customer: $error');
      return null;
    }
  }

  // Create new customer
  Future<Map<String, dynamic>> createCustomer({
    required String name,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'created_by': user.id,
      };

      final response =
          await client.from('customers').insert(data).select().single();
      return response;
    } catch (error) {
      throw Exception('Failed to create customer: $error');
    }
  }

  // Update customer
  Future<Map<String, dynamic>> updateCustomer(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('customers')
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update customer: $error');
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String id) async {
    try {
      await client.from('customers').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete customer: $error');
    }
  }

  // Search customers by name or phone
  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    try {
      final response = await client
          .from('customers')
          .select()
          .or('name.ilike.%$query%,phone.ilike.%$query%')
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search customers: $error');
    }
  }

  // Get customer's service history
  Future<List<Map<String, dynamic>>> getCustomerServiceHistory(
      String customerId) async {
    try {
      final response = await client
          .from('service_requests')
          .select('''
            *,
            user_profiles!service_requests_technician_id_fkey(full_name)
          ''')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch customer service history: $error');
    }
  }
}
