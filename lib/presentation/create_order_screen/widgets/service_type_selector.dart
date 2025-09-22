import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ServiceTypeSelector extends StatelessWidget {
  final String selectedServiceType;
  final Function(String) onServiceTypeSelected;

  const ServiceTypeSelector({
    Key? key,
    required this.selectedServiceType,
    required this.onServiceTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> serviceTypes = [
      {
        'type': 'Leather',
        'icon': 'chair',
        'color': const Color(0xFF8B4513),
      },
      {
        'type': 'Wood',
        'icon': 'carpenter',
        'color': const Color(0xFF654321),
      },
      {
        'type': 'Upholstery',
        'icon': 'weekend',
        'color': const Color(0xFF4A5568),
      },
      {
        'type': 'Cleaning',
        'icon': 'cleaning_services',
        'color': const Color(0xFF2563EB),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Type',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: serviceTypes.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final service = serviceTypes[index];
              final isSelected = selectedServiceType == service['type'];

              return GestureDetector(
                onTap: () {
                  onServiceTypeSelected(service['type'] as String);
                },
                child: Container(
                  width: 20.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: (service['color'] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: service['icon'] as String,
                          color: service['color'] as Color,
                          size: 6.w,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        service['type'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
