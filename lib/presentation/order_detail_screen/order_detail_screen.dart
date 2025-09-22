import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/customer_details_widget.dart';
import './widgets/observations_widget.dart';
import './widgets/order_header_widget.dart';
import './widgets/photo_attachment_widget.dart';
import './widgets/service_info_widget.dart';
import './widgets/status_management_widget.dart';
import './widgets/time_tracking_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String _snakeToCamel(String s) {
    return s.replaceAllMapped(RegExp(r'_([a-z])'), (m) => m[1]!.toUpperCase());
  }

  Map<String, dynamic> _mapOrderData(Map<String, dynamic> data) {
    final mapped = <String, dynamic>{};
    data.forEach((key, value) {
      mapped[_snakeToCamel(key)] = value;
    });
    // Alias para compatibilidad con widgets
    mapped['orderNumber'] =
        mapped['orderNumber'] ?? mapped['order_number'] ?? '';
    mapped['serviceType'] =
        mapped['serviceType'] ?? mapped['service_type'] ?? '';
    mapped['customerName'] =
        mapped['customerName'] ?? mapped['customer_name'] ?? '';
    mapped['customerPhone'] =
        mapped['customerPhone'] ?? mapped['customer_phone'] ?? '';
    mapped['customerAddress'] =
        mapped['customerAddress'] ?? mapped['customer_address'] ?? '';
    mapped['createdDate'] = mapped['createdDate'] ?? mapped['created_at'] ?? '';
    mapped['rate'] = mapped['rate'] ?? mapped['hourlyRate'] ?? 0.0;
    mapped['timeSpent'] = mapped['timeSpent'] ?? 0.0;
    mapped['totalAmount'] =
        mapped['totalAmount'] ?? mapped['amount'] ?? mapped['totalCost'] ?? 0.0;
    mapped['observations'] = mapped['observations'] ?? '';
    return mapped;
  }

  bool _isEditing = false;
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  String? _orderId;
  bool _didFetch = false;

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      _orderId = args?['orderId']?.toString();
      if (_orderId != null && _orderId!.isNotEmpty) {
        _fetchOrderData();
        _didFetch = true;
      }
    }
  }

  Future<void> _fetchOrderData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await SupabaseService.instance.client
          .from('service_requests')
          .select()
          .eq('order_number', _orderId ?? '')
          .single();
      setState(() {
        _orderData = _mapOrderData(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Error al cargar la orden',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleStatusChanged(String newStatus) {
    if (_orderData == null) return;
    setState(() {
      _orderData!['status'] = newStatus;
      _orderData!['lastModified'] = DateTime.now().toIso8601String();
    });
    // Add to modification history
    final history = (_orderData!['modificationHistory'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    history.add({
      "timestamp": DateTime.now().toIso8601String(),
      "action": "Estado cambiado a ${_getStatusText(newStatus)}",
      "user": _orderData!['technicianName'] ?? '',
    });
    _showSuccessMessage('Estado actualizado correctamente');
  }

  void _handleTimeChanged(double newTime) {
    if (_orderData == null) return;
    setState(() {
      _orderData!['timeSpent'] = newTime;
      _orderData!['totalAmount'] = newTime * (_orderData!['rate'] as double);
      _orderData!['lastModified'] = DateTime.now().toIso8601String();
    });
    _showSuccessMessage('Tiempo actualizado correctamente');
  }

  void _handlePhotosChanged(List<String> newPhotos) {
    if (_orderData == null) return;
    setState(() {
      _orderData!['photos'] = newPhotos;
      _orderData!['lastModified'] = DateTime.now().toIso8601String();
    });
    _showSuccessMessage('Fotos actualizadas correctamente');
  }

  void _handleUpdateStatus() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent * 0.6,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleAddPhotos() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent * 0.8,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleGenerateReport() {
    _showSuccessMessage('Generando reporte...');
    // Simulate report generation
    Future.delayed(const Duration(seconds: 2), () {
      _showSuccessMessage('Reporte generado exitosamente');
    });
  }

  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successLight,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completado';
      case 'in_progress':
        return 'En Progreso';
      case 'pending':
        return 'Pendiente';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (_isEditing) {
      _showSuccessMessage('Modo edición activado');
    } else {
      _showSuccessMessage('Cambios guardados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        title: _isLoading
            ? const Text('Cargando...')
            : Text(
                _orderData?['orderNumber'] != null
                    ? 'Orden ${_orderData!['orderNumber']}'
                    : 'Detalle de Orden',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
        actions: [
          IconButton(
            onPressed: _toggleEditMode,
            icon: CustomIconWidget(
              iconName: _isEditing ? 'save' : 'edit',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orderData == null
                ? Center(
                    child: Text('No se encontró la orden.'),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Header
                        OrderHeaderWidget(orderData: _orderData!),
                        SizedBox(height: 3.h),

                        // Service Information
                        ServiceInfoWidget(
                          orderData: _orderData!,
                          isEditing: _isEditing,
                          onChanged: (field, value) {
                            setState(() {
                              _orderData![field] = value;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Customer Details
                        CustomerDetailsWidget(
                          orderData: _orderData!,
                          isEditing: _isEditing,
                          onChanged: (field, value) {
                            setState(() {
                              _orderData![field] = value;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Observations
                        ObservationsWidget(
                          data: _orderData!,
                          isEditing: _isEditing,
                          onChanged: (field, value) {
                            setState(() {
                              _orderData![field] = value;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Time Tracking
                        TimeTrackingWidget(
                          orderData: _orderData!,
                          onTimeChanged: _handleTimeChanged,
                        ),
                        SizedBox(height: 3.h),

                        // Status Management
                        StatusManagementWidget(
                          orderData: _orderData!,
                          onStatusChanged: _handleStatusChanged,
                        ),
                        SizedBox(height: 3.h),

                        // Photo Attachment
                        PhotoAttachmentWidget(
                          existingPhotos: (_orderData!["photos"] as List?)
                                  ?.cast<String>() ??
                              [],
                          onPhotosChanged: _handlePhotosChanged,
                        ),
                        SizedBox(height: 3.h),

                        // Action Buttons
                        ActionButtonsWidget(
                          orderData: _orderData!,
                          onUpdateStatus: _handleUpdateStatus,
                          onAddPhotos: _handleAddPhotos,
                          onGenerateReport: _handleGenerateReport,
                        ),
                        SizedBox(height: 4.h),

                        // Modification History
                        if (_isEditing) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowLight,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Historial de Modificaciones',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme.textPrimaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                ...((_orderData!["modificationHistory"]
                                                as List?)
                                            ?.cast<Map<String, dynamic>>() ??
                                        [])
                                    .map((modification) => Padding(
                                          padding: EdgeInsets.only(bottom: 1.h),
                                          child: Row(
                                            children: [
                                              CustomIconWidget(
                                                iconName: 'history',
                                                color:
                                                    AppTheme.textSecondaryLight,
                                                size: 16,
                                              ),
                                              SizedBox(width: 2.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      modification['action']
                                                              as String? ??
                                                          '',
                                                      style: AppTheme.lightTheme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: AppTheme
                                                            .textPrimaryLight,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${modification['user'] ?? ''} - ${modification['timestamp'] != null ? DateTime.parse(modification['timestamp']).toString().substring(0, 16) : ''}',
                                                      style: AppTheme.lightTheme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: AppTheme
                                                            .textSecondaryLight,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}
