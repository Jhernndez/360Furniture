import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/service_request_service.dart';
import '../../services/user_service.dart';
import './widgets/empty_state.dart';
import './widgets/greeting_header.dart';
import './widgets/order_card.dart';
import './widgets/week_toggle.dart';
import './widgets/weekly_summary_card.dart';

class OrderDashboard extends StatefulWidget {
  const OrderDashboard({Key? key}) : super(key: key);

  @override
  State<OrderDashboard> createState() => _OrderDashboardState();
}

class _OrderDashboardState extends State<OrderDashboard>
    with TickerProviderStateMixin {
  bool _isCurrentWeek = true;

  // Technician/user info
  String technicianName = "";
  DateTime currentDate = DateTime.now();
  bool _profileLoading = true;

  // Real orders data
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndOrders();
    currentDate = DateTime.now();
  }

  Future<void> _fetchProfileAndOrders() async {
    setState(() {
      _profileLoading = true;
    });
    try {
      final userProfile = await UserService.getCurrentUserProfile();
      setState(() {
        technicianName = userProfile?.fullName ?? "";
        _profileLoading = false;
      });
    } catch (e) {
      setState(() {
        technicianName = "";
        _profileLoading = false;
      });
    }
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final orders =
          await ServiceRequestService.instance.getAllServiceRequests();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading orders';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildDashboardTab(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewOrder,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final currentWeekOrders = _getCurrentWeekOrders();
    final weeklyStats = _calculateWeeklyStats(currentWeekOrders);

    if (_profileLoading || _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                GreetingHeader(
                  technicianName: technicianName,
                  currentDate: currentDate,
                ),
                WeeklySummaryCard(
                  totalOrders: weeklyStats['totalOrders'] as int,
                  completedOrders: weeklyStats['completedOrders'] as int,
                  totalEarnings: weeklyStats['totalEarnings'] as double,
                  weekPeriod: _getWeekPeriodLabel(),
                ),
                WeekToggle(
                  isCurrentWeek: _isCurrentWeek,
                  onToggle: _toggleWeek,
                  currentWeekLabel: 'This Week',
                  previousWeekLabel: 'Last Week',
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
          currentWeekOrders.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    onCreateOrder: _createNewOrder,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = currentWeekOrders[index];
                      return OrderCard(
                        order: order,
                        onEdit: () => _editOrder(order),
                        onComplete: () => _completeOrder(order),
                        onAddNotes: () => _addNotes(order),
                        onStatusChange: () => _changeStatus(order),
                        onDuplicate: () => _duplicateOrder(order),
                        onShare: () => _shareOrder(order),
                        onDelete: () => _deleteOrder(order),
                        onTap: () => _viewOrderDetails(order),
                      );
                    },
                    childCount: currentWeekOrders.length,
                  ),
                ),
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCurrentWeekOrders() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    if (_isCurrentWeek) {
      return _orders.where((order) {
        final orderDate = DateTime.tryParse(order['created_at'] ?? '') ?? now;
        return orderDate
                .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            orderDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();
    } else {
      final previousWeekStart = startOfWeek.subtract(const Duration(days: 7));
      final previousWeekEnd = previousWeekStart.add(const Duration(days: 6));

      return _orders.where((order) {
        final orderDate = DateTime.tryParse(order['created_at'] ?? '') ?? now;
        return orderDate
                .isAfter(previousWeekStart.subtract(const Duration(days: 1))) &&
            orderDate.isBefore(previousWeekEnd.add(const Duration(days: 1)));
      }).toList();
    }
  }

  Map<String, dynamic> _calculateWeeklyStats(
      List<Map<String, dynamic>> orders) {
    final totalOrders = orders.length;
    final completedOrders = orders.where((order) {
      final status = (order['status'] as String?)?.toLowerCase() ?? '';
      return status == 'complete';
    }).length;
    final totalEarnings = orders.fold<double>(0.0,
        (sum, order) => sum + ((order['amount'] as num?)?.toDouble() ?? 0.0));

    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'totalEarnings': totalEarnings,
    };
  }

  String _getWeekPeriodLabel() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    if (_isCurrentWeek) {
      return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
    } else {
      final previousWeekStart = startOfWeek.subtract(const Duration(days: 7));
      final previousWeekEnd = previousWeekStart.add(const Duration(days: 6));
      return '${previousWeekStart.day}/${previousWeekStart.month} - ${previousWeekEnd.day}/${previousWeekEnd.month}';
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchOrders();
    HapticFeedback.lightImpact();
  }

  void _toggleWeek() {
    setState(() {
      _isCurrentWeek = !_isCurrentWeek;
    });
  }

  void _createNewOrder() {
    Navigator.pushNamed(context, '/create-order-screen');
  }

  void _editOrder(Map<String, dynamic> order) {
    // TODO: Implement edit for real orders if needed
    Navigator.pushNamed(
      context,
      '/order-detail-screen',
      arguments: {'orderId': order['id'], 'mode': 'edit'},
    );
  }

  void _completeOrder(Map<String, dynamic> order) {
    final orderId = order['id']?.toString();
    if (orderId == null) return;
    // Actualiza la UI localmente primero para mejor experiencia
    setState(() {
      final idx = _orders.indexWhere((o) => o['id']?.toString() == orderId);
      if (idx != -1) {
        _orders[idx]['status'] = 'Complete';
      }
    });
    ServiceRequestService.instance
        .updateStatus(orderId, 'Complete')
        .then((_) async {
      await _fetchOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orden marcada como completada'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error al completar la orden: ' + (e?.toString() ?? '')),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _addNotes(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Notes'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter your observations...',
          ),
          maxLines: 3,
          onChanged: (value) {
            // Handle notes input
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notes added successfully')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changeStatus(Map<String, dynamic> order) {
    // TODO: Implement status change for real data (update in Supabase)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Change status not implemented for real data')),
    );
  }

  void _duplicateOrder(Map<String, dynamic> order) {
    // TODO: Implement duplicate order for real data (create new in Supabase)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duplicate order not implemented')),
    );
  }

  void _shareOrder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing order ${order['orderNumber']}')),
    );
  }

  void _deleteOrder(Map<String, dynamic> order) {
    // TODO: Implement delete order for real data (delete from Supabase)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete order not implemented')),
    );
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    Navigator.pushNamed(
      context,
      '/order-detail-screen',
      arguments: {'orderId': order['order_number'], 'mode': 'view'},
    );
  }
}
