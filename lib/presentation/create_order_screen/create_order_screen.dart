import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../services/customer_service.dart';
import './widgets/observations_field.dart';
import './widgets/rate_management_section.dart';
import './widgets/service_type_selector.dart';
import './widgets/status_selection_control.dart';
import './widgets/time_tracking_component.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Timer? _autoSaveTimer;

  // Order data
  late TextEditingController _orderNumberController;
  String _orderNumber = '';
  String _selectedServiceType = '';
  double _currentRate = 0.0;
  Duration _serviceDuration = Duration.zero;
  bool _isTimerRunning = false;
  Map<String, String> _customerData = {
    'name': '',
    'phone': '',
    'address': '',
  };
  String? _customerId; // ID del cliente seleccionado o creado
  String _observations = '';
  String _selectedStatus = '';

  // Form state
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _orderNumberController = TextEditingController();
    _generateOrderNumber();
    _startAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _orderNumberController.dispose();
    super.dispose();
  }

  void _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    final generated =
        'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$timestamp';
    setState(() {
      _orderNumber = generated;
      _orderNumberController.text = generated;
    });
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_hasUnsavedChanges && _isFormValid()) {
        _saveDraft();
      }
    });
  }

  void _saveDraft() {
    // Auto-save functionality would be implemented here
    // For now, we'll just reset the unsaved changes flag
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  bool _isFormValid() {
    final isValid = _orderNumberController.text.trim().isNotEmpty &&
        _selectedServiceType.isNotEmpty &&
        _customerData['name']?.isNotEmpty == true &&
        _selectedStatus.isNotEmpty;
    print('[DEBUG] _isFormValid: $isValid');
    print(
        '[DEBUG] Campos: orderNumber=${_orderNumberController.text}, serviceType=$_selectedServiceType, name=${_customerData['name']}, phone=${_customerData['phone']}, address=${_customerData['address']}, status=$_selectedStatus');
    return isValid;
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Unsaved Changes'),
            content: Text(
                'You have unsaved changes. Are you sure you want to leave?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Leave'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorLight,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onServiceTypeSelected(String serviceType) {
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _selectedServiceType = serviceType;
        });
        _markAsChanged();
      }
    });
  }

  void _onRateChanged(double rate) {
    if (_currentRate != rate) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _currentRate = rate;
          });
          _markAsChanged();
        }
      });
    }
  }

  void _onDurationChanged(Duration duration) {
    setState(() {
      _serviceDuration = duration;
    });
    _markAsChanged();
  }

  void _onStartStopTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
    _markAsChanged();
  }

  void _onObservationsChanged(String observations) {
    setState(() {
      _observations = observations;
    });
    _markAsChanged();
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _markAsChanged();
  }

  Future<void> _saveOrder() async {
    print('[DEBUG] _saveOrder llamado');
    if (!_formKey.currentState!.validate()) {
      print('[DEBUG] _formKey no válido');
      return;
    }

    if (!_isFormValid()) {
      print('[DEBUG] _isFormValid es false');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Usar el valor manual del campo
      _orderNumber = _orderNumberController.text.trim();
      final userId = SupabaseService.instance.client.auth.currentUser?.id;
      print('[DEBUG] UID usuario autenticado: $userId');

      // 1. Si no hay _customerId, creamos el cliente primero
      if (_customerId == null) {
        print('[DEBUG] Creando cliente nuevo...');
        final customer = await CustomerService.instance.createCustomer(
          name: _customerData['name'] ?? '',
          phone: _customerData['phone'] ?? '',
          address: _customerData['address'] ?? '',
        );
        _customerId = customer['id'] as String?;
        print('[DEBUG] Cliente creado con id: \\$_customerId');
      }

      final orderData = {
        'order_number': _orderNumber,
        'service_type': _selectedServiceType,
        'rate': _currentRate,
        'duration': _serviceDuration.inMinutes,
        'customer_name': _customerData['name'],
        'customer_phone': _customerData['phone'],
        'customer_address': _customerData['address'],
        'customer_id': _customerId,
        'observations': _observations,
        'status': _selectedStatus,
        'amount': _calculateTotalAmount(),
        'created_at': DateTime.now().toIso8601String(),
        'created_by': userId,
        'technician_id': userId,
      };

      // Guardar en Supabase
      final client = SupabaseService.instance.client;
      await client.from('service_requests').insert(orderData).select().single();

      // Success - navigate back, then show message en contexto anterior
      if (mounted) {
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          final rootContext = Navigator.of(context).context;
          ScaffoldMessenger.of(rootContext).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: Colors.white,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text('Order $_orderNumber created successfully!'),
                  ),
                ],
              ),
              backgroundColor: AppTheme.successLight,
              duration: const Duration(seconds: 2),
            ),
          );
        });
      }
    } catch (e) {
      print('[ERROR] Error al crear orden: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order. Please try again.'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  double _calculateTotalAmount() {
    final hours = _serviceDuration.inMinutes / 60.0;
    return _currentRate * hours;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Create Order'),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          actions: [
            if (_hasUnsavedChanges)
              Container(
                margin: EdgeInsets.only(right: 4.w),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.warningLight,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Draft',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Order Number Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'receipt_long',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Number',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          TextFormField(
                            controller: _orderNumberController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0.5.h, horizontal: 2.w),
                              border: InputBorder.none,
                              hintText: 'Order Number',
                            ),
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.primaryColor,
                            ),
                            onChanged: (val) => _markAsChanged(),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Required'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Type Selection
                        ServiceTypeSelector(
                          selectedServiceType: _selectedServiceType,
                          onServiceTypeSelected: _onServiceTypeSelected,
                        ),
                        SizedBox(height: 4.h),

                        // Rate Management
                        if (_selectedServiceType.isNotEmpty) ...[
                          RateManagementSection(
                            selectedServiceType: _selectedServiceType,
                            currentRate: _currentRate,
                            onRateChanged: _onRateChanged,
                          ),
                          SizedBox(height: 4.h),
                        ],

                        // Time Tracking
                        TimeTrackingComponent(
                          currentDuration: _serviceDuration,
                          isRunning: _isTimerRunning,
                          onDurationChanged: _onDurationChanged,
                          onStartStop: _onStartStopTimer,
                        ),
                        SizedBox(height: 4.h),

                        // Customer Selector Dropdown
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: CustomerService.instance.getAllCustomers(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Text('Error loading customers');
                            }
                            final customers = snapshot.data ?? [];
                            // Mostrar el Dropdown aunque la lista esté vacía
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Cliente',
                                border: OutlineInputBorder(),
                              ),
                              value: _customerId,
                              items: customers.map((customer) {
                                final id = customer['id']?.toString() ?? '';
                                final name = customer['name'] ?? '';
                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (selectedId) {
                                final selected = customers.firstWhere(
                                  (c) => c['id']?.toString() == selectedId,
                                  orElse: () => {},
                                );
                                setState(() {
                                  _customerId = selectedId;
                                  _customerData = {
                                    'name': selected['name'] ?? '',
                                    'phone': selected['phone'] ?? '',
                                    'address': selected['address'] ?? '',
                                  };
                                });
                                _markAsChanged();
                              },
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                              // Si no hay clientes, mostrar hint
                              hint: customers.isEmpty
                                  ? Text('No hay clientes registrados')
                                  : null,
                            );
                          },
                        ),
                        SizedBox(height: 4.h),

                        // Observations
                        ObservationsField(
                          observations: _observations,
                          onObservationsChanged: _onObservationsChanged,
                        ),
                        SizedBox(height: 4.h),

                        // Status Selection
                        StatusSelectionControl(
                          selectedStatus: _selectedStatus,
                          onStatusChanged: _onStatusChanged,
                        ),
                        SizedBox(height: 4.h),

                        // Total Amount Display
                        if (_currentRate > 0 &&
                            _serviceDuration.inMinutes > 0) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.lightTheme.primaryColor
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Service Duration:',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${(_serviceDuration.inMinutes / 60.0).toStringAsFixed(2)} hours',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rate:',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '€${_currentRate.toStringAsFixed(2)}/hour',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 3.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Amount:',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '€${_calculateTotalAmount().toStringAsFixed(2)}',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.lightTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.h),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Save Button
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid() && !_isSaving ? _saveOrder : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      backgroundColor: _isFormValid()
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.surface,
                    ),
                    child: _isSaving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Creating Order...',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'save',
                                color: _isFormValid()
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme.lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                size: 5.w,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Save Order',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  color: _isFormValid()
                                      ? AppTheme
                                          .lightTheme.colorScheme.onPrimary
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
