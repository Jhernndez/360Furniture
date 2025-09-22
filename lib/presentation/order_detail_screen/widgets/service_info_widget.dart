import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ServiceInfoWidget extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final bool isEditing;
  final void Function(String field, dynamic value) onChanged;

  const ServiceInfoWidget({
    Key? key,
    required this.orderData,
    required this.isEditing,
    required this.onChanged,
  }) : super(key: key);

  String _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'leather':
        return 'chair';
      case 'wood':
        return 'carpenter';
      case 'upholstery':
        return 'weekend';
      case 'cleaning':
        return 'cleaning_services';
      default:
        return 'build';
    }
  }

  String _getServiceName(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'leather':
        return 'Cuero';
      case 'wood':
        return 'Madera';
      case 'upholstery':
        return 'Tapicería';
      case 'cleaning':
        return 'Limpieza';
      default:
        return serviceType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceType = orderData['serviceType'] as String? ?? '';
    final rate = orderData['rate'] is String
        ? double.tryParse(orderData['rate']) ?? 0.0
        : (orderData['rate'] as double? ?? 0.0);
    final timeSpent = orderData['timeSpent'] as double? ?? 0.0;
    final totalAmount = orderData['totalAmount'] as double? ?? 0.0;

    return Container(
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getServiceIcon(serviceType),
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Servicio',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    isEditing
                        ? DropdownButton<String>(
                            value: serviceType.isNotEmpty ? serviceType : null,
                            isExpanded: true,
                            items: [
                              'leather',
                              'wood',
                              'upholstery',
                              'cleaning',
                            ]
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(_getServiceName(type)),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                onChanged('serviceType', val ?? ''),
                            hint: Text('Selecciona tipo'),
                          )
                        : Text(
                            _getServiceName(serviceType),
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.textPrimaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: isEditing
                    ? TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Tarifa por Hora',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        controller:
                            TextEditingController(text: rate.toString()),
                        onChanged: (val) =>
                            onChanged('rate', double.tryParse(val) ?? 0.0),
                      )
                    : _buildInfoItem('Tarifa por Hora',
                        '\$${rate.toStringAsFixed(2)}', 'attach_money'),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildInfoItem('Tiempo Trabajado',
                    '${timeSpent.toStringAsFixed(1)}h', 'schedule'),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total del Servicio',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, String iconName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.textSecondaryLight,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
