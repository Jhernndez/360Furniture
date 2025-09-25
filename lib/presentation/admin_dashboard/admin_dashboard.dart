import '../customer_management/create_customer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../user_management_screen/user_management_screen.dart';
import './widgets/metric_card_widget.dart';
import './widgets/quick_actions_fab_widget.dart';
import './widgets/technician_performance_widget.dart';
import '../../services/supabase_service.dart';
import '../../services/user_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  // Campos de la clase primero
  List<Map<String, dynamic>> _activeTechnicians = [];
  int _totalOrders = 0;
  int _completedOrders = 0;
  bool _isLoadingUsers = true;
  int _totalAdministrators = 0;
  int _selectedTabIndex = 0;
  String _selectedPeriod = 'Weekly';
  late TabController _tabController;

  void _handleAddCustomer() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const CreateCustomerDialog(),
      ),
    );
    // Aquí puedes refrescar la lista de clientes si es necesario
  }

  // Métodos después
  void _navigateToUserManagementAndAdd() {
    // Navigate to user management screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserManagementScreen(),
      ),
    );
  }

  void _handleExportData() {
    Navigator.pushNamed(context, '/reports-dashboard-screen');
  }

  Future<void> _handleTechnicianPay(
      Map<String, dynamic> technician, double amount) async {
    final id = technician['id']?.toString();
    if (id == null) return;
    try {
      final currentPaid =
          (technician['amount_paid'] as num?)?.toDouble() ?? 0.0;
      final newPaid = currentPaid + amount;
      // Actualizar en Supabase usando UserService
      await UserService.updateTechnicianAmountPaid(
          id: id, newAmountPaid: newPaid);
      // Refrescar dashboard
      await _fetchDashboardData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pago registrado correctamente.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el pago: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //conecar supabase

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoadingUsers = true);
    try {
      // Técnicos activos
      final techs = await SupabaseService.instance.client
          .from('user_profiles')
          .select()
          .eq('role', 'technician')
          .eq('is_active', true) as List<dynamic>;
      final techList = techs.map((e) => Map<String, dynamic>.from(e)).toList();

      // Administradores
      final admins = await SupabaseService.instance.client
          .from('user_profiles')
          .select()
          .eq('role', 'admin') as List<dynamic>;
      final adminList =
          admins.map((e) => Map<String, dynamic>.from(e)).toList();

      // Órdenes
      final orders = await SupabaseService.instance.client
          .from('service_requests')
          .select();
      // print('ORDERS FETCHED:');
      // print(orders);
      // Órdenes completadas
      final completed = orders.where((o) => o['status'] == 'completed').length;
      // Suma total de amount de todas las órdenes
      // double totalAmount = 0.0;
      // Suma de órdenes por técnico
      final Map<String, double> technicianOrderSums = {};
      for (final o in orders) {
        final amount = (o['amount'] as num?)?.toDouble() ??
            (o['total_amount'] as num?)?.toDouble() ??
            0.0;
        final techId = o['technician_id']?.toString();
        if (techId != null && techId.isNotEmpty) {
          technicianOrderSums[techId] =
              (technicianOrderSums[techId] ?? 0.0) + amount;
        }
      }
      // print('TOTAL AMOUNT SUM:');
      // print(totalAmount);
      // Añadir suma de órdenes a cada técnico
      final techListWithSums = techList.map((tech) {
        final techId = tech['id']?.toString();
        final Map<String, dynamic> newTech = Map<String, dynamic>.from(tech);
        newTech['orderAmountSum'] = technicianOrderSums[techId] ?? 0.0;
        return newTech;
      }).toList();
      setState(() {
        _activeTechnicians = techListWithSums;
        _totalAdministrators = adminList.length;
        _totalOrders = orders.length;
        _completedOrders = completed;
        _isLoadingUsers = false;
      });
    } catch (e) {
      // print('Error al obtener datos del dashboard: $e');
      setState(() => _isLoadingUsers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildTechniciansTab(),
                  _buildReportsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? QuickActionsFabWidget(
              onAddTechnician: _handleAddTechnician,
              onAddCustomer: _handleAddCustomer,
              onExportData: _handleExportData,
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '360 Furniture Services',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.textSecondaryLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/login-screen'),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    'A',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedTabIndex == 0) ...[
            SizedBox(height: 2.h),
            _buildPeriodSelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ['Weekly', 'Monthly'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color:
                        isSelected ? Colors.white : AppTheme.textSecondaryLight,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _selectedTabIndex == 0
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
            text: 'Dashboard',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'people',
              color: _selectedTabIndex == 1
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
            text: 'Technicians',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'assessment',
              color: _selectedTabIndex == 2
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
            text: 'Reports',
          ),
        ],
        labelColor: AppTheme.primaryLight,
        unselectedLabelColor: AppTheme.textSecondaryLight,
        indicatorColor: AppTheme.primaryLight,
        labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildMetricsSection(),
            TechnicianPerformanceWidget(
              technicians: _activeTechnicians,
              onTechnicianTap: _handleTechnicianTap,
              onLongPress: _handleTechnicianLongPress,
              onPay: _handleTechnicianPay,
            ),
            // Puedes agregar RevenueChartWidget y ActivityFeedWidget con datos reales si lo deseas
            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    final completionRate =
        _totalOrders > 0 ? (_completedOrders / _totalOrders * 100) : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCardWidget(
                title: 'Total Orders',
                value: _totalOrders.toString(),
                subtitle: '+12% from last $_selectedPeriod',
                trendIcon: 'trending_up',
                trendColor: AppTheme.successLight,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/order-list-screen',
                  arguments: {
                    'ordersSource': 'supabase',
                  },
                ),
              ),
            ),
            Expanded(
              child: MetricCardWidget(
                title: 'Total Customers',
                value: '${completionRate.toStringAsFixed(1)}%',
                subtitle: '+5.2% from last $_selectedPeriod',
                trendIcon: 'trending_up',
                trendColor: AppTheme.successLight,
                onTap: () {},
              ),
            ),
          ],
        ),
        MetricCardWidget(
          title: 'Total To Pay (USD)',
          value: '\$${_calculateTotalToPay().toStringAsFixed(2)}',
          subtitle: 'Total of Technicians $_selectedPeriod',
          trendIcon: 'trending_up',
          trendColor: AppTheme.successLight,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildTechniciansTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'User Management',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserManagementScreen(),
                    ),
                  ),
                  icon: CustomIconWidget(
                    iconName: 'manage_accounts',
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text('Manage Users'),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Quick Overview Card
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.groups,
                      color: AppTheme.primaryLight,
                      size: 24,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Team Overview',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat('Total Technicians',
                          '${_activeTechnicians.length}', Icons.person),
                    ),
                    Expanded(
                      child: _buildQuickStat(
                          'Total Administrators',
                          _isLoadingUsers
                              ? 'Loading...'
                              : '$_totalAdministrators',
                          Icons.person_outline),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                          'Avg Completion', '91.5%', Icons.trending_up),
                    ),
                    Expanded(
                      child: _buildQuickStat('Total Orders',
                          _totalOrders.toString(), Icons.assignment),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.manage_accounts),
                    label: const Text('Open User Management'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Quick Actions
          Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Add Technician',
                  'Create new technician account',
                  Icons.person_add,
                  AppTheme.primaryLight,
                  () => _navigateToUserManagementAndAdd(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildQuickActionCard(
                  'View All',
                  'Manage all technicians',
                  Icons.list,
                  AppTheme.successLight,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserManagementScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppTheme.primaryLight,
            ),
            SizedBox(width: 2.w),
            Text(
              value,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports & Analytics',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildReportCard(
            'Export Data',
            'Download complete database in Excel format',
            'file_download',
            () => Navigator.pushNamed(context, '/reports-dashboard-screen'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
      String title, String description, String icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Card(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.primaryLight,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          trailing: CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: AppTheme.textSecondaryLight,
            size: 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));
  }

  void _handleTechnicianTap(Map<String, dynamic> technician) {
    // Navigate to technician detail or show profile
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Technician Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${technician['name']}'),
            Text('Email: ${technician['email']}'),
            Text('Phone: ${technician['phone']}'),
            Text('Completion Rate: ${technician['completionRate']}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleTechnicianLongPress(Map<String, dynamic> technician) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'person', color: AppTheme.primaryLight, size: 24),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                _handleTechnicianTap(technician);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'message', color: AppTheme.primaryLight, size: 24),
              title: const Text('Send Message'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'assessment',
                  color: AppTheme.primaryLight,
                  size: 24),
              title: const Text('Generate Individual Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reports-dashboard-screen');
              },
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalToPay() {
    double total = 0.0;
    for (final tech in _activeTechnicians) {
      final orderSum = (tech['orderAmountSum'] as double? ?? 0.0);
      final amountPaid = (tech['amount_paid'] as double? ?? 0.0);
      final pending = orderSum - amountPaid;
      total += pending > 0 ? pending : 0.0;
    }
    return total;
  }

  void _handleAddTechnician() async {
    // Usar el diálogo reutilizable
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const CreateUserDialog(),
      ),
    );
    await _fetchDashboardData();
  }
}

// --- INICIO: Diálogo de creación de usuario reutilizable ---
class CreateUserDialog extends StatefulWidget {
  const CreateUserDialog({super.key});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'technician';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Crear Usuario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingresa el nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingresa el email';
                    }
                    if (!value!.contains('@')) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingresa la contraseña';
                    }
                    if (value!.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'technician', child: Text('Técnico')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('Administrador')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Crear',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService.createTechnician(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? ''
            : _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // print('Error creating user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear usuario: [${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
// --- FIN: Diálogo de creación de usuario reutilizable ---
