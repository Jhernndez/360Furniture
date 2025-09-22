import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TechnicianPerformanceWidget extends StatelessWidget {
  final List<Map<String, dynamic>> technicians;
  final Function(Map<String, dynamic>) onTechnicianTap;
  final Function(Map<String, dynamic>) onLongPress;
  final Future<void> Function(Map<String, dynamic> technician, double amount)?
      onPay;

  const TechnicianPerformanceWidget({
    Key? key,
    required this.technicians,
    required this.onTechnicianTap,
    required this.onLongPress,
    this.onPay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
              CustomIconWidget(
                iconName: 'people',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Órdenes por Técnico',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          technicians.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: technicians.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final technician = technicians[index];
                    return _buildTechnicianOrderSumItem(context, technician);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildTechnicianOrderSumItem(
      BuildContext context, Map<String, dynamic> technician) {
    final orderSum = (technician['orderAmountSum'] as double? ?? 0.0);
    final amountPaid = (technician['amount_paid'] as double? ?? 0.0);
    final pending = orderSum - amountPaid;
    final fullName = technician['full_name']?.toString() ?? 'Unknown';
    return GestureDetector(
      onTap: null,
      onLongPress: () => onLongPress(technician),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.borderSubtleLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
              child: Text(
                fullName.isNotEmpty
                    ? fullName.substring(0, 1).toUpperCase()
                    : 'T',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '\$${pending.toStringAsFixed(2)}',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 2.w),
            ElevatedButton(
              onPressed: () async {
                final controller = TextEditingController();
                final result = await showDialog<double>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Pagar a $fullName'),
                      content: TextField(
                        controller: controller,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Monto a pagar',
                          hintText: 'Máximo: ${pending.toStringAsFixed(2)}',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            final value =
                                double.tryParse(controller.text) ?? 0.0;
                            if (value > 0 && value <= pending) {
                              Navigator.of(context).pop(value);
                            }
                          },
                          child: Text('Pagar'),
                        ),
                      ],
                    );
                  },
                );
                if (result != null && onPay != null) {
                  await onPay!(technician, result);
                }
              },
              child: Text('Pagar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'person_add',
            color: AppTheme.textDisabledLight,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Technicians Added',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add technicians to view performance metrics',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textDisabledLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
