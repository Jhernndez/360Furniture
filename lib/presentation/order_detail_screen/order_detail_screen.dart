import '../../services/service_request_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/customer_details_widget.dart';
import './widgets/observations_widget.dart';
import './widgets/order_header_widget.dart';
import './widgets/photo_attachment_widget.dart';
import './widgets/service_info_widget.dart';
import './widgets/status_management_widget.dart';
import './widgets/time_tracking_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? order;
  const OrderDetailScreen({super.key, this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  void _onChanged(String field, dynamic value) {
    bool shouldUpdateTotal = false;
    setState(() {
      _orderData[field] = value;
      _orderData['lastModified'] = DateTime.now().toIso8601String();
      if (field == 'rate' || field == 'timeSpent') {
        shouldUpdateTotal = true;
      }
    });
    if (shouldUpdateTotal) {
      final rate = (_orderData['rate'] is num)
          ? (_orderData['rate'] as num).toDouble()
          : double.tryParse(_orderData['rate'].toString()) ?? 0.0;
      final time = (_orderData['timeSpent'] is num)
          ? (_orderData['timeSpent'] as num).toDouble()
          : double.tryParse(_orderData['timeSpent'].toString()) ?? 0.0;
      setState(() {
        _orderData['totalAmount'] = rate * time;
      });
      _updateTotalAmountInSupabase(_orderData['id'], _orderData['totalAmount']);
    }
  }

  Future<void> _updateTotalAmountInSupabase(
      dynamic orderId, double totalAmount) async {
    try {
      await ServiceRequestService.instance
          .updateServiceRequest(orderId, {'amount': totalAmount});
    } catch (e) {
      // Manejo de error opcional
    }
  }

  bool _isEditing = false;
  bool _hasBeenEdited = false;
  late Map<String, dynamic> _orderData;
  final ScrollController _scrollController = ScrollController();

  bool _orderNotFound = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? orderId;
      Map<String, dynamic>? orderArg;
      if (args is Map) {
        if (args['order'] != null && args['order'] is Map<String, dynamic>) {
          orderArg = args['order'];
        } else if (args['orderId'] != null) {
          orderId = args['orderId'].toString();
        }
        if (args['mode'] == 'edit') {
          setState(() {
            _isEditing = true;
          });
        }
      }
      if (orderArg != null) {
        setState(() {
          _orderData = Map.from(orderArg!);
        });
      } else if (orderId != null) {
        // Cargar datos reales desde Supabase
        final service = ServiceRequestService.instance;
        final data = await service.getServiceRequestById(orderId);
        if (data != null) {
          // Mapeo de campos reales a los usados en la UI
          setState(() {
            // Map real status to widget-expected values
            String rawStatus = data['status']?.toString() ?? '';
            String mappedStatus;
            switch (rawStatus.toLowerCase()) {
              case 'complete':
              case 'completed':
                mappedStatus = 'Complete';
                break;
              case 'partial':
                mappedStatus = 'Partial';
                break;
              case 'report':
                mappedStatus = 'Report';
                break;
              case 'cancelled':
              case 'canceled':
                mappedStatus = 'cancelled';
                break;
              default:
                mappedStatus = 'Complete'; // fallback to a valid status
            }
            _orderData = {
              "orderNumber": data['order_number']?.toString() ??
                  data['id']?.toString() ??
                  '',
              "id": data['id']?.toString() ?? '',
              "createdDate":
                  data['created_at']?.toString().substring(0, 10) ?? '',
              "status": mappedStatus,
              // Normaliza el tipo de servicio a minúsculas para el Dropdown y la UI
              "serviceType":
                  data['service_type']?.toString().toLowerCase() ?? '',
              // Corrige los campos para que coincidan con la base de datos
              "rate": data['rate'] ?? 0.0,
              // Convierte duration (minutos) a horas decimales
              "timeSpent": (data['duration'] is int && data['duration'] > 12)
                  ? (data['duration'] / 60.0)
                  : (data['duration'] is String &&
                          int.tryParse(data['duration']) != null &&
                          int.parse(data['duration']) > 12)
                      ? (int.parse(data['duration']) / 60.0)
                      : (data['duration'] is num
                          ? data['duration'].toDouble()
                          : double.tryParse(
                                  data['duration']?.toString() ?? '') ??
                              0.0),
              "totalAmount": data['amount'] ?? 0.0,
              "customerName": data['customer_name']?.toString() ?? '',
              "customerPhone": data['customer_phone']?.toString() ?? '',
              "customerAddress": data['customer_address']?.toString() ?? '',
              "observations": (data['observations'] ??
                      data['notes'] ??
                      data['description'] ??
                      '')
                  .toString(),
              "startTime":
                  data['scheduled_date']?.toString().substring(11, 16) ?? '',
              "endTime":
                  data['completed_date']?.toString().substring(11, 16) ?? '',
              "photos":
                  (data['photos'] is List) ? (data['photos'] as List) : [],
              "technicianId": data['technician_id']?.toString() ?? '',
              "technicianName": data['technician_name']?.toString() ?? '',
              "lastModified": data['updated_at']?.toString() ?? '',
              "modificationHistory": (data['modification_history'] is List)
                  ? (data['modification_history'] as List)
                  : [],
            };
          });
        } else {
          setState(() {
            _orderNotFound = true;
          });
        }
      } else {
        setState(() {
          _orderNotFound = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleStatusChanged(String newStatus) async {
    setState(() {
      _orderData['status'] = newStatus;
      _orderData['lastModified'] = DateTime.now().toIso8601String();
    });

    // Add to modification history
    final history = (_orderData['modificationHistory'] as List)
        .cast<Map<String, dynamic>>();
    history.add({
      "timestamp": DateTime.now().toIso8601String(),
      "action": "Estado cambiado a ${_getStatusText(newStatus)}",
      "user": _orderData['technicianName']
    });

    // Actualizar solo el estado en Supabase
    final service = ServiceRequestService.instance;
    final id = _orderData['id'] ??
        _orderData['orderId'] ??
        _orderData['order_number'] ??
        _orderData['orderNumber'];
    if (id != null && id.toString().isNotEmpty) {
      try {
        await service
            .updateServiceRequest(id.toString(), {'status': newStatus});
        _showSuccessMessage('Estado actualizado correctamente');
      } catch (e) {
        _showSuccessMessage('Error al actualizar estado en Supabase');
      }
    } else {
      _showSuccessMessage(
          'No se pudo identificar la orden para actualizar estado');
    }
  }

  void _handleTimeChanged(double newTime) {
    // newTime viene en horas decimales desde el widget
    setState(() {
      _orderData['timeSpent'] = newTime;
      final rate = (_orderData['rate'] is num)
          ? (_orderData['rate'] as num).toDouble()
          : double.tryParse(_orderData['rate'].toString()) ?? 0.0;
      _orderData['totalAmount'] = rate * newTime;
      _orderData['lastModified'] = DateTime.now().toIso8601String();
    });
    // Actualiza el total en Supabase
    _updateTotalAmountInSupabase(_orderData['id'], _orderData['totalAmount']);
    _showSuccessMessage('Tiempo actualizado correctamente');
  }

  void _handlePhotosChanged(List<String> newPhotos) {
    setState(() {
      _orderData['photos'] = newPhotos;
      _orderData['lastModified'] = DateTime.now().toIso8601String();
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
    final normalized = status.toLowerCase().trim();
    switch (normalized) {
      case 'complete':
        return 'Completado';
      case 'partial':
        return 'Parcial';
      case 'report':
        return 'Reporte';
      case 'cancelled':
        return 'Cancelado';
      default:
        // Devuelve el status original capitalizado si no es reconocido
        if (status.isNotEmpty) {
          return status[0].toUpperCase() + status.substring(1);
        }
        return 'Desconocido';
    }
  }

  void _toggleEditMode() {
    if (_hasBeenEdited) return;
    setState(() {
      if (!_isEditing) {
        _isEditing = true;
        _showSuccessMessage('Modo edición activado');
      } else {
        _isEditing = false;
        _hasBeenEdited = true;
        // Guardar cambios en Supabase
        _saveOrderToSupabase();
      }
    });
  }

  Future<void> _saveOrderToSupabase() async {
    final service = ServiceRequestService.instance;
    // Usar siempre el id real de la orden (UUID), no el order_number visible
    final id = _orderData['id'] ??
        _orderData['orderId'] ??
        _orderData['order_number'] ??
        _orderData['orderNumber'];
    if (id == null || id.toString().isEmpty) {
      _showSuccessMessage('No se pudo identificar la orden para guardar');
      return;
    }

    // Validar y normalizar serviceType
    const validServiceTypes = ['Leather', 'Wood', 'Upholstery', 'Cleaning'];
    String serviceType = _orderData['serviceType']?.toString().trim() ?? '';
    // Permitir minúsculas pero guardar con mayúscula inicial
    final normalized = validServiceTypes.firstWhere(
      (t) => t.toLowerCase() == serviceType.toLowerCase(),
      orElse: () => '',
    );
    if (normalized.isEmpty) {
      _showSuccessMessage(
          'Error: Tipo de servicio inválido. Debe ser uno de: Leather, Wood, Upholstery, Cleaning');
      return;
    }

    final updates = <String, dynamic>{
      'customer_name': _orderData['customerName'],
      'customer_phone': _orderData['customerPhone'],
      'customer_address': _orderData['customerAddress'],
      'status': _orderData['status'],
      'service_type': normalized,
      'rate': _orderData['rate'],
      // Guardar duration en minutos (entero, partiendo de horas decimales)
      'duration': ((_orderData['timeSpent'] ?? 0) is num)
          ? ((_orderData['timeSpent'] as num) * 60).round()
          : (double.tryParse(_orderData['timeSpent'].toString()) != null
              ? (double.parse(_orderData['timeSpent'].toString()) * 60).round()
              : 0),
      'amount': _orderData['totalAmount'],
      'observations': _orderData['observations'],
      // Agrega aquí otros campos editables si es necesario
    };
    try {
      final resp = await service.updateServiceRequest(id.toString(), updates);
      if (resp == null) {
        _showSuccessMessage('Error: respuesta nula de Supabase');
      } else if (resp['observations'] != updates['observations']) {
        _showSuccessMessage('Advertencia: Supabase no actualizó observations');
      } else {
        _showSuccessMessage('Cambios guardados en Supabase');
      }
    } catch (e) {
      _showSuccessMessage('Error al guardar en Supabase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orderNotFound) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Orden'),
        ),
        body: Center(
          child: Text(
            'Orden no encontrada o no disponible.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }
    // ...existing code for the real order detail UI...
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
        title: Text(
          'Detalle de Orden',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            onPressed: (_isEditing || !_hasBeenEdited) ? _toggleEditMode : null,
            icon: CustomIconWidget(
              iconName: _isEditing ? 'save' : 'edit',
              color: (_isEditing || !_hasBeenEdited)
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.textDisabledLight,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderHeaderWidget(orderData: _orderData),
              SizedBox(height: 3.h),
              ServiceInfoWidget(
                orderData: _orderData,
                isEditing: _isEditing,
                onChanged: _onChanged,
              ),
              SizedBox(height: 3.h),
              CustomerDetailsWidget(
                orderData: _orderData,
                isEditing: _isEditing,
                onChanged: _onChanged,
              ),
              SizedBox(height: 3.h),
              ObservationsWidget(
                data: _orderData,
                isEditing: _isEditing,
                onChanged: _onChanged,
              ),
              SizedBox(height: 3.h),
              TimeTrackingWidget(
                orderData: _orderData,
                onTimeChanged: _handleTimeChanged,
              ),
              SizedBox(height: 3.h),
              StatusManagementWidget(
                orderData: _orderData,
                onStatusChanged: _handleStatusChanged,
              ),
              SizedBox(height: 3.h),
              PhotoAttachmentWidget(
                existingPhotos: (_orderData['photos'] as List).cast<String>(),
                onPhotosChanged: _handlePhotosChanged,
              ),
              SizedBox(height: 3.h),
              ActionButtonsWidget(
                orderData: _orderData,
                onUpdateStatus: _handleUpdateStatus,
                onAddPhotos: _handleAddPhotos,
                onGenerateReport: _handleGenerateReport,
              ),
              SizedBox(height: 4.h),
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
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ...(_orderData['modificationHistory'] as List)
                          .cast<Map<String, dynamic>>()
                          .map((modification) => Padding(
                                padding: EdgeInsets.only(bottom: 1.h),
                                child: Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'history',
                                      color: AppTheme.textSecondaryLight,
                                      size: 16,
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            modification['action'] as String,
                                            style: AppTheme
                                                .lightTheme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: AppTheme.textPrimaryLight,
                                            ),
                                          ),
                                          Text(
                                            '${modification['user']} - ${DateTime.parse(modification['timestamp']).toString().substring(0, 16)}',
                                            style: AppTheme
                                                .lightTheme.textTheme.bodySmall
                                                ?.copyWith(
                                              color:
                                                  AppTheme.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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
