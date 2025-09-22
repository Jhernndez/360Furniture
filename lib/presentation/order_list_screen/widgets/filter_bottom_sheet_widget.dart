import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;
  final Function(Map<String, dynamic>)? onApplyFilters;

  const FilterBottomSheetWidget({
    Key? key,
    this.currentFilters,
    this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;
  String? _selectedServiceType;
  String? _selectedStatus;
  RangeValues _amountRange = RangeValues(0, 1000);

  // Usa los valores reales de tu base de datos para los tipos de servicio y estatus
  final List<String> _serviceTypes = [
    'All',
    'leather',
    'wood',
    'upholstery',
    'cleaning',
    // agrega aquí más tipos si existen en tu base
  ];
  final List<String> _statuses = [
    'All',
    'pending',
    'in_progress',
    'completed',
    'cancelled',
    // agrega aquí más estatus si existen en tu base
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters ?? {});
    _selectedServiceType = _filters['service_type'] ?? 'All';
    _selectedStatus = _filters['status'] ?? 'All';
    _amountRange = RangeValues(
      (_filters['minAmount'] ?? 0).toDouble(),
      (_filters['maxAmount'] ?? 1000).toDouble(),
    );
    if (_filters['dateRange'] != null) {
      _selectedDateRange = _filters['dateRange'] as DateTimeRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filter Orders',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Section
                  _buildSectionHeader('Date Range'),
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: _selectDateRange,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'date_range',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 6.w,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            _selectedDateRange != null
                                ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                                : 'Select date range',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: _selectedDateRange != null
                                  ? AppTheme.lightTheme.colorScheme.onSurface
                                  : AppTheme.lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Service Type Section
                  _buildSectionHeader('Service Type'),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _serviceTypes
                        .map((type) => FilterChip(
                              label: Text(type == 'All'
                                  ? 'All'
                                  : type[0].toUpperCase() + type.substring(1)),
                              selected: _selectedServiceType == type,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedServiceType =
                                      selected ? type : 'All';
                                });
                              },
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.surface,
                              selectedColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              checkmarkColor:
                                  AppTheme.lightTheme.colorScheme.onPrimary,
                              labelStyle: AppTheme
                                  .lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: _selectedServiceType == type
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ))
                        .toList(),
                  ),

                  SizedBox(height: 3.h),

                  // Status Section
                  _buildSectionHeader('Status'),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _statuses
                        .map((status) => FilterChip(
                              label: Text(status == 'All'
                                  ? 'All'
                                  : status
                                      .replaceAll('_', ' ')
                                      .split(' ')
                                      .map((w) =>
                                          w[0].toUpperCase() + w.substring(1))
                                      .join(' ')),
                              selected: _selectedStatus == status,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedStatus = selected ? status : 'All';
                                });
                              },
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.surface,
                              selectedColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              checkmarkColor:
                                  AppTheme.lightTheme.colorScheme.onPrimary,
                              labelStyle: AppTheme
                                  .lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: _selectedStatus == status
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ))
                        .toList(),
                  ),

                  SizedBox(height: 3.h),

                  // Amount Range Section
                  _buildSectionHeader('Amount Range'),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${_amountRange.start.round()}',
                              style: AppTheme.lightTheme.textTheme.labelLarge,
                            ),
                            Text(
                              '\$${_amountRange.end.round()}',
                              style: AppTheme.lightTheme.textTheme.labelLarge,
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: _amountRange,
                          min: 0,
                          max: 2000,
                          divisions: 40,
                          onChanged: (values) {
                            setState(() {
                              _amountRange = values;
                            });
                          },
                          activeColor: AppTheme.lightTheme.colorScheme.primary,
                          inactiveColor: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
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
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDateRange = null;
      _selectedServiceType = 'All';
      _selectedStatus = 'All';
      _amountRange = RangeValues(0, 1000);
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_selectedDateRange != null) {
      filters['dateRange'] = _selectedDateRange;
    }

    if (_selectedServiceType != 'All') {
      filters['service_type'] = _selectedServiceType;
    }

    if (_selectedStatus != 'All') {
      filters['status'] = _selectedStatus;
    }

    if (_amountRange.start > 0 || _amountRange.end < 1000) {
      filters['minAmount'] = _amountRange.start;
      filters['maxAmount'] = _amountRange.end;
    }

    widget.onApplyFilters?.call(filters);
    Navigator.pop(context);
  }
}
