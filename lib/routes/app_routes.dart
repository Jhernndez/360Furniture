import 'package:flutter/material.dart';

import '../presentation/admin_dashboard/admin_dashboard.dart';
import '../presentation/create_order_screen/create_order_screen.dart';
import '../presentation/excel_conciliation_screen/excel_conciliation_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/order_dashboard/order_dashboard.dart';
import '../presentation/order_detail_screen/order_detail_screen.dart';
import '../presentation/order_list_screen/order_list_screen.dart';
import '../presentation/reports_dashboard_screen/reports_dashboard_screen.dart';
import '../presentation/technician_profile_screen/technician_profile_screen.dart';
import '../presentation/user_management_screen/user_management_screen.dart';

class AppRoutes {
  static const String loginScreen = '/login-screen';
  static const String orderDashboard = '/order-dashboard';
  static const String createOrderScreen = '/create-order-screen';
  static const String orderListScreen = '/order-list-screen';
  static const String orderDetailScreen = '/order-detail-screen';
  static const String technicianProfileScreen = '/technician-profile-screen';
  static const String adminDashboard = '/admin-dashboard';
  static const String reportsDashboardScreen = '/reports-dashboard-screen';
  static const String excelConciliationScreen = '/excel-conciliation-screen';
  static const String userManagementScreen = '/user-management-screen';

  static Map<String, WidgetBuilder> routes = {
    loginScreen: (context) => const LoginScreen(),
    orderDashboard: (context) => const OrderDashboard(),
    createOrderScreen: (context) => const CreateOrderScreen(),
    orderListScreen: (context) => const OrderListScreen(),
    orderDetailScreen: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return OrderDetailScreen(order: args != null ? args['order'] : null);
    },
    technicianProfileScreen: (context) => const TechnicianProfileScreen(),
    adminDashboard: (context) => const AdminDashboard(),
    reportsDashboardScreen: (context) => const ReportsDashboardScreen(),
    excelConciliationScreen: (context) => const ExcelConciliationScreen(),
    userManagementScreen: (context) => const UserManagementScreen(),
  };
}
