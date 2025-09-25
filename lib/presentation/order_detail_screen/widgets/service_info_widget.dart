import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ServiceInfoWidget extends StatelessWidget {
  String formatHoursAndMinutes(dynamic value) {
    double hours = 0.0;
    if (value is num) {
      hours = value.toDouble();
    } else if (value is String && double.tryParse(value) != null) {
      hours = double.parse(value);
    }
    final h = hours.truncate();
    final m = ((hours - h) * 60).round();
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  final Map<String, dynamic> orderData;
  final bool isEditing;
  final void Function(String field, dynamic value) onChanged;

  const ServiceInfoWidget({
    super.key,
    required this.orderData,
    required this.isEditing,
    required this.onChanged,
  });

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
    const validTypes = ['leather', 'wood', 'upholstery', 'cleaning'];
    final dropdownValue =
        validTypes.contains(serviceType) ? serviceType : validTypes.first;
    final rateRaw = orderData['rate'];
    final rate = rateRaw is String
        ? double.tryParse(rateRaw) ?? 0.0
        : rateRaw is int
            ? rateRaw.toDouble()
            : (rateRaw as double? ?? 0.0);
    final timeSpentRaw = orderData['timeSpent'];
    final timeSpentFormatted = formatHoursAndMinutes(timeSpentRaw);
    final totalAmountRaw = orderData['totalAmount'];
    final totalAmount = totalAmountRaw is String
        ? double.tryParse(totalAmountRaw) ?? 0.0
        : totalAmountRaw is int
            ? totalAmountRaw.toDouble()
            : (totalAmountRaw as double? ?? 0.0);

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
                            value: dropdownValue,
                            isExpanded: true,
                            items: validTypes
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
                child: _buildInfoItem(
                    'Tiempo Trabajado', timeSpentFormatted.trim(), 'schedule'),
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
