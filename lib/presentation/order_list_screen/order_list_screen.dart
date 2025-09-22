import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/service_request_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/order_card_widget.dart';
import './widgets/search_bar_widget.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  Map<String, dynamic> _activeFilters = {};
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  String _sortBy = 'Date';
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSupabaseOrders();
      _scrollController.addListener(_onScroll);
    });
  }

  Future<void> _loadSupabaseOrders() async {
    setState(() {
      _isLoading = true;
    });
    final orders = await ServiceRequestService.instance.getAllServiceRequests();
    _allOrders = orders;
    _filteredOrders = List.from(_allOrders);
    setState(() {
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  void _loadMoreOrders() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more orders
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allOrders);

    // Búsqueda unificada por nombre de cliente (customer_name o customerName)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final searchLower = _searchQuery.toLowerCase();
        final customerName =
            order['customer_name'] ?? order['customerName'] ?? '';
        return (order['order_number'] as String?)
                    ?.toLowerCase()
                    .contains(searchLower) ==
                true ||
            (customerName as String).toLowerCase().contains(searchLower) ||
            (order['serviceType'] as String?)
                    ?.toLowerCase()
                    .contains(searchLower) ==
                true ||
            (order['status'] as String?)?.toLowerCase().contains(searchLower) ==
                true;
      }).toList();
    }

    // Apply active filters
    if (_activeFilters.containsKey('service_type')) {
      filtered = filtered
          .where((order) =>
              order['service_type'] == _activeFilters['service_type'])
          .toList();
    }

    if (_activeFilters.containsKey('status')) {
      filtered = filtered
          .where((order) => order['status'] == _activeFilters['status'])
          .toList();
    }

    if (_activeFilters.containsKey('dateRange')) {
      final DateTimeRange range = _activeFilters['dateRange'];
      filtered = filtered.where((order) {
        final orderDate = order['createdAt'] as DateTime;
        return orderDate.isAfter(range.start.subtract(Duration(days: 1))) &&
            orderDate.isBefore(range.end.add(Duration(days: 1)));
      }).toList();
    }

    if (_activeFilters.containsKey('minAmount') ||
        _activeFilters.containsKey('maxAmount')) {
      final double minAmount = _activeFilters['minAmount']?.toDouble() ?? 0.0;
      final double maxAmount =
          _activeFilters['maxAmount']?.toDouble() ?? double.infinity;
      filtered = filtered.where((order) {
        final amount = (order['amount'] as num).toDouble();
        return amount >= minAmount && amount <= maxAmount;
      }).toList();
    }

    // Apply sorting
    _sortOrders(filtered);

    setState(() {
      _filteredOrders = filtered;
    });
  }

  void _sortOrders(List<Map<String, dynamic>> orders) {
    switch (_sortBy) {
      case 'Date':
        orders.sort((a, b) =>
            (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
        break;
      case 'Amount':
        orders
            .sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
        break;
      case 'Status':
        orders.sort(
            (a, b) => (a['status'] as String).compareTo(b['status'] as String));
        break;
      case 'Customer Name':
        final getName = (Map<String, dynamic> o) =>
            (o['customer_name'] ?? o['customerName'] ?? '') as String;
        orders.sort((a, b) => getName(a).compareTo(getName(b)));
        break;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Sort by',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...['Date', 'Amount', 'Status', 'Customer Name']
                .map((option) => ListTile(
                      title: Text(option),
                      trailing: _sortBy == option
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 6.w,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _sortBy = option;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _removeFilter(String filterKey) {
    setState(() {
      _activeFilters.remove(filterKey);
    });
    _applyFilters();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _isLoading = true;
    });
    await _loadSupabaseOrders();
    Fluttertoast.showToast(
      msg: "Orders refreshed successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _navigateToOrderDetail(Map<String, dynamic> order) {
    Navigator.pushNamed(
      context,
      '/order-detail-screen',
      arguments: {'orderId': order['id']},
    );
  }

  void _editOrder(Map<String, dynamic> order) {
    Fluttertoast.showToast(
      msg: "Edit order #${order['order_number']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _duplicateOrder(Map<String, dynamic> order) {
    Navigator.pushNamed(
      context,
      '/create-order-screen',
      arguments: {'duplicateFrom': order},
    );
  }

  void _shareOrder(Map<String, dynamic> order) {
    Fluttertoast.showToast(
      msg: "Share order #${order['order_number']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _changeOrderStatus(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Status'),
        content: Text('Change status for order #${order['order_number']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Status updated successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Order'),
        content: Text(
            'Are you sure you want to delete order #${order['order_number']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allOrders.removeWhere((o) => o['id'] == order['id']);
              });
              _applyFilters();
              Fluttertoast.showToast(
                msg: "Order deleted successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Orders',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          if (_isOffline)
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: CustomIconWidget(
                iconName: 'cloud_off',
                color: Colors.orange,
                size: 6.w,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Search orders, customers...',
            onChanged: _onSearchChanged,
            onFilterTap: _showFilterBottomSheet,
            recentSearches: _recentSearches,
          ),

          // Active Filters
          if (_activeFilters.isNotEmpty)
            Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _activeFilters.entries.map((entry) {
                  String label = '';
                  switch (entry.key) {
                    case 'serviceType':
                      label = entry.value;
                      break;
                    case 'status':
                      label = entry.value;
                      break;
                    case 'dateRange':
                      final range = entry.value as DateTimeRange;
                      label =
                          'Date: ${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}';
                      break;
                    case 'minAmount':
                    case 'maxAmount':
                      if (_activeFilters.containsKey('minAmount') &&
                          _activeFilters.containsKey('maxAmount')) {
                        label =
                            'Amount: \$${_activeFilters['minAmount']?.round()}-\$${_activeFilters['maxAmount']?.round()}';
                      }
                      break;
                  }

                  if (label.isEmpty ||
                      (entry.key == 'maxAmount' &&
                          _activeFilters.containsKey('minAmount'))) {
                    return SizedBox.shrink();
                  }

                  return FilterChipWidget(
                    label: label,
                    isSelected: true,
                    onRemove: () => _removeFilter(entry.key),
                  );
                }).toList(),
              ),
            ),

          // Orders List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  )
                : _filteredOrders.isEmpty
                    ? EmptyStateWidget(
                        title:
                            _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                                ? 'No orders found'
                                : 'No orders yet',
                        subtitle: _searchQuery.isNotEmpty ||
                                _activeFilters.isNotEmpty
                            ? 'Try adjusting your search or filters'
                            : 'Create your first service order to get started',
                        buttonText:
                            _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                                ? 'Clear Filters'
                                : 'Create Order',
                        onButtonPressed: () {
                          if (_searchQuery.isNotEmpty ||
                              _activeFilters.isNotEmpty) {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _activeFilters.clear();
                            });
                            _applyFilters();
                          } else {
                            Navigator.pushNamed(
                                context, '/create-order-screen');
                          }
                        },
                        iconName:
                            _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                                ? 'search_off'
                                : 'add_business',
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshOrders,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount:
                              _filteredOrders.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredOrders.length) {
                              return Container(
                                padding: EdgeInsets.all(4.w),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              );
                            }

                            final order = _filteredOrders[index];
                            return OrderCardWidget(
                              order: order,
                              onTap: () => _navigateToOrderDetail(order),
                              onEdit: () => _editOrder(order),
                              onDuplicate: () => _duplicateOrder(order),
                              onShare: () => _shareOrder(order),
                              onStatusChange: () => _changeOrderStatus(order),
                              onDelete: () => _deleteOrder(order),
                              onAddToFavorites: () {
                                Fluttertoast.showToast(
                                  msg: "Added to favorites",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                              onExport: () {
                                Fluttertoast.showToast(
                                  msg: "Exporting order...",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                              onContactCustomer: () {
                                final customerName = order['customer_name'] ??
                                    order['customerName'] ??
                                    'Unknown Customer';
                                Fluttertoast.showToast(
                                  msg: "Contacting $customerName...",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-order-screen'),
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 7.w,
        ),
      ),
    );
  }
}
