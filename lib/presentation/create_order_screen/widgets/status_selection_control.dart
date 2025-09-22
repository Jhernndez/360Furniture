import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatusSelectionControl extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const StatusSelectionControl({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> statusOptions = [
      {
        'status': 'Complete',
        'icon': 'check_circle',
        'color': AppTheme.successLight,
        'description': 'Service fully completed',
      },
      {
        'status': 'Partial',
        'icon': 'schedule',
        'color': AppTheme.warningLight,
        'description': 'Partially completed',
      },
      {
        'status': 'Report',
        'icon': 'report_problem',
        'color': AppTheme.errorLight,
        'description': 'Issues to report',
      },
      {
        'status': 'cancelled',
        'icon': 'cancel',
        'color': Colors.grey,
        'description': 'Order was cancelled',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),

        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: statusOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedStatus == option['status'];
              final isFirst = index == 0;
              final isLast = index == statusOptions.length - 1;

              return GestureDetector(
                onTap: () => onStatusChanged(option['status'] as String),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (option['color'] as Color).withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: isFirst ? Radius.circular(16) : Radius.zero,
                      topRight: isFirst ? Radius.circular(16) : Radius.zero,
                      bottomLeft: isLast ? Radius.circular(16) : Radius.zero,
                      bottomRight: isLast ? Radius.circular(16) : Radius.zero,
                    ),
                    border: isSelected
                        ? Border.all(
                            color: option['color'] as Color,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Radio Button
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? option['color'] as Color
                                : AppTheme.lightTheme.colorScheme.outline,
                            width: 2,
                          ),
                          color: isSelected
                              ? option['color'] as Color
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 2.w,
                                  height: 2.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 4.w),

                      // Status Icon
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color:
                              (option['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: option['icon'] as String,
                          color: option['color'] as Color,
                          size: 5.w,
                        ),
                      ),
                      SizedBox(width: 4.w),

                      // Status Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['status'] as String,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? option['color'] as Color
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              option['description'] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selection Indicator
                      if (isSelected)
                        CustomIconWidget(
                          iconName: 'check',
                          color: option['color'] as Color,
                          size: 5.w,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Status Information
        if (selectedStatus.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _getStatusColor(selectedStatus).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(selectedStatus).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: _getStatusColor(selectedStatus),
                  size: 4.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _getStatusMessage(selectedStatus),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(selectedStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Complete':
        return AppTheme.successLight;
      case 'Partial':
        return AppTheme.warningLight;
      case 'Report':
        return AppTheme.errorLight;
      case 'cancelled':
        return Colors.grey;
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'Complete':
        return 'Order will be marked as fully completed and ready for billing.';
      case 'Partial':
        return 'Order requires additional work. Schedule follow-up appointment.';
      case 'Report':
        return 'Issues encountered. Admin review required before completion.';
      case 'cancelled':
        return 'Order was cancelled.';
      default:
        return '';
    }
  }
}
