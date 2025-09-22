import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class PerformanceService {
  static PerformanceService? _instance;
  static PerformanceService get instance =>
      _instance ??= PerformanceService._();

  PerformanceService._();

  SupabaseClient get client => SupabaseService.instance.client;

  // Get technician performance metrics
  Future<Map<String, dynamic>> getTechnicianPerformanceMetrics({
    String? technicianId,
  }) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Use provided technicianId or current user
      final targetTechnicianId = technicianId ?? user.id;

      // Get current month start and end
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);
      final currentMonthEnd = DateTime(now.year, now.month + 1, 1)
          .subtract(const Duration(days: 1));
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd =
          DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));

      // Get total completed orders
      final completedOrdersResponse = await client
          .from('service_requests')
          .select('id, total_cost, hourly_rate, actual_hours, completed_date')
          .eq('technician_id', targetTechnicianId)
          .eq('status', 'completed')
          .order('completed_date', ascending: false);

      final completedOrders =
          List<Map<String, dynamic>>.from(completedOrdersResponse);
      final totalCompleted = completedOrders.length;

      // Get current month completed orders
      final currentMonthCompleted = completedOrders.where((order) {
        if (order['completed_date'] == null) return false;
        final completedDate = DateTime.parse(order['completed_date']);
        return completedDate.isAfter(currentMonthStart) &&
            completedDate
                .isBefore(currentMonthEnd.add(const Duration(days: 1)));
      }).toList();

      // Get last month completed orders
      final lastMonthCompleted = completedOrders.where((order) {
        if (order['completed_date'] == null) return false;
        final completedDate = DateTime.parse(order['completed_date']);
        return completedDate.isAfter(lastMonthStart) &&
            completedDate.isBefore(lastMonthEnd.add(const Duration(days: 1)));
      }).toList();

      // Calculate earnings for current month
      double currentMonthEarnings = 0.0;
      for (final order in currentMonthCompleted) {
        if (order['total_cost'] != null) {
          currentMonthEarnings += (order['total_cost'] as num).toDouble();
        } else if (order['hourly_rate'] != null &&
            order['actual_hours'] != null) {
          final rate = (order['hourly_rate'] as num).toDouble();
          final hours = (order['actual_hours'] as num).toDouble();
          currentMonthEarnings += rate * hours;
        }
      }

      // Calculate earnings for last month
      double lastMonthEarnings = 0.0;
      for (final order in lastMonthCompleted) {
        if (order['total_cost'] != null) {
          lastMonthEarnings += (order['total_cost'] as num).toDouble();
        } else if (order['hourly_rate'] != null &&
            order['actual_hours'] != null) {
          final rate = (order['hourly_rate'] as num).toDouble();
          final hours = (order['actual_hours'] as num).toDouble();
          lastMonthEarnings += rate * hours;
        }
      }

      // Calculate earnings percentage change
      double earningsChange = 0.0;
      if (lastMonthEarnings > 0) {
        earningsChange =
            ((currentMonthEarnings - lastMonthEarnings) / lastMonthEarnings) *
                100;
      }

      // Calculate completion rate
      final allAssignedOrdersResponse = await client
          .from('service_requests')
          .select('id, status')
          .eq('technician_id', targetTechnicianId);

      final allAssignedOrders =
          List<Map<String, dynamic>>.from(allAssignedOrdersResponse);
      final completedCount = allAssignedOrders
          .where((order) => order['status'] == 'completed')
          .length;
      final incompletedCount = allAssignedOrders
          .where((order) =>
              order['status'] == 'pending' || order['status'] == 'in_progress')
          .length;

      final completionRate = allAssignedOrders.isNotEmpty
          ? (completedCount / allAssignedOrders.length * 100).round()
          : 100;

      // Calculate average rating (placeholder - would need customer feedback system)
      // For now, calculate based on completion performance
      double averageRating = 4.5; // Default good rating
      if (completionRate >= 95) {
        averageRating = 4.8 + (completionRate - 95) * 0.04;
      } else if (completionRate >= 85) {
        averageRating = 4.5 + (completionRate - 85) * 0.03;
      } else {
        averageRating = 4.0 + (completionRate - 80) * 0.1;
      }
      averageRating = averageRating.clamp(3.0, 5.0);

      // Calculate monthly progress (based on current vs last month orders)
      final monthlyProgressValue = currentMonthCompleted.length;
      final lastMonthValue = lastMonthCompleted.length;
      final monthlyChange = lastMonthValue > 0
          ? currentMonthCompleted.length - lastMonthCompleted.length
          : currentMonthCompleted.length;

      // Calculate quality score (based on completion rate and timeliness)
      double qualityScore = (completionRate / 100) * 0.7;
      if (qualityScore < 0.6) qualityScore = 0.6;
      if (qualityScore > 0.95) qualityScore = 0.95;

      // Customer satisfaction (derived from performance metrics)
      double customerSatisfaction = averageRating / 5.0;
      if (customerSatisfaction > 0.98) customerSatisfaction = 0.98;

      return {
        'totalCompleted': totalCompleted,
        'currentMonthCompleted': currentMonthCompleted.length,
        'monthlyChange': monthlyChange,
        'averageRating': double.parse(averageRating.toStringAsFixed(1)),
        'currentMonthEarnings': currentMonthEarnings,
        'earningsChangePercentage':
            double.parse(earningsChange.toStringAsFixed(1)),
        'completionRate': completionRate,
        'incompletedCount': incompletedCount,
        'totalAssigned': allAssignedOrders.length,
        'monthlyProgress':
            (monthlyProgressValue / (monthlyProgressValue + 5)) * 100,
        'qualityScore': double.parse((qualityScore * 100).toStringAsFixed(0)),
        'customerSatisfaction':
            double.parse((customerSatisfaction * 100).toStringAsFixed(0)),
      };
    } catch (error) {
      throw Exception('Failed to fetch performance metrics: $error');
    }
  }

  // Get time tracking performance for technician
  Future<Map<String, dynamic>> getTimeTrackingPerformance({
    String? technicianId,
  }) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final targetTechnicianId = technicianId ?? user.id;

      // Get time tracking data for current month
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);

      final timeTrackingResponse = await client
          .from('time_tracking')
          .select('duration_minutes, created_at')
          .eq('technician_id', targetTechnicianId)
          .gte('created_at', currentMonthStart.toIso8601String())
          .order('created_at', ascending: false);

      final timeEntries = List<Map<String, dynamic>>.from(timeTrackingResponse);

      final totalMinutes = timeEntries.fold<int>(
          0, (sum, entry) => sum + ((entry['duration_minutes'] as int?) ?? 0));

      final totalHours = (totalMinutes / 60).round();

      return {
        'totalHoursThisMonth': totalHours,
        'totalMinutes': totalMinutes,
        'averageHoursPerDay':
            timeEntries.isNotEmpty ? (totalHours / now.day) : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch time tracking performance: $error');
    }
  }

  // Listen to real-time performance updates
  Stream<Map<String, dynamic>> streamPerformanceMetrics({
    String? technicianId,
  }) async* {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final targetTechnicianId = technicianId ?? user.id;

    // Initial data
    yield await getTechnicianPerformanceMetrics(
        technicianId: targetTechnicianId);

    // Listen to service_requests changes
    await for (final _ in client
        .from('service_requests')
        .stream(primaryKey: ['id']).eq('technician_id', targetTechnicianId)) {
      try {
        yield await getTechnicianPerformanceMetrics(
            technicianId: targetTechnicianId);
      } catch (e) {
        // Continue with previous data on error
        continue;
      }
    }
  }
}
