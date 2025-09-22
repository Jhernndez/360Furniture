import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterReportsWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const FilterReportsWidget({
    Key? key,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<FilterReportsWidget> createState() => _FilterReportsWidgetState();
}

class _FilterReportsWidgetState extends State<FilterReportsWidget> {
  DateTimeRange? _dateRange;
  String _selectedReportType = 'All Types';
  String _selectedStatus = 'All Status';

  final List<String> _reportTypes = [
    'All Types',
    'Performance Summary',
    'Financial Overview',
    'Service Analysis',
    'Customer Insights',
    'System Analytics',
    'Revenue Analysis',
  ];

  final List<String> _statusOptions = [
    'All Status',
    'Completed',
    'Generating',
    'Failed',
  ];

  bool get _hasActiveFilters {
    return _dateRange != null ||
        _selectedReportType != 'All Types' ||
        _selectedStatus != 'All Status';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: Colors.purple,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Filter Reports',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (_hasActiveFilters) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${_getActiveFilterCount()} active',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    onPressed: _clearAllFilters,
                    icon: Icon(
                      Icons.clear_all,
                      size: 5.w,
                      color: AppTheme.errorLight,
                    ),
                    tooltip: 'Clear All Filters',
                  ),
                ],
              ],
            ),
            SizedBox(height: 3.h),

            // Date Range Filter
            _buildFilterSection(
              'Date Range',
              Icons.date_range,
              Colors.teal,
              child: InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _dateRange != null
                        ? Colors.teal.withValues(alpha: 0.05)
                        : AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _dateRange != null
                          ? Colors.teal.withValues(alpha: 0.3)
                          : AppTheme.borderSubtleLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _dateRange != null
                            ? Colors.teal
                            : AppTheme.textSecondaryLight,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          _dateRange != null
                              ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                              : 'Select date range',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _dateRange != null
                                        ? Colors.teal
                                        : AppTheme.textSecondaryLight,
                                    fontWeight: _dateRange != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                      if (_dateRange != null)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _dateRange = null;
                            });
                            _notifyFilterChange();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.errorLight,
                            size: 4.w,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Report Type Filter
            _buildFilterSection(
              'Report Type',
              Icons.category,
              AppTheme.primaryLight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: _selectedReportType != 'All Types'
                      ? AppTheme.primaryLight.withValues(alpha: 0.05)
                      : AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedReportType != 'All Types'
                        ? AppTheme.primaryLight.withValues(alpha: 0.3)
                        : AppTheme.borderSubtleLight,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedReportType,
                    items: _reportTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: type == _selectedReportType &&
                                            type != 'All Types'
                                        ? AppTheme.primaryLight
                                        : AppTheme.textPrimaryLight,
                                    fontWeight: type == _selectedReportType
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedReportType = newValue;
                        });
                        _notifyFilterChange();
                      }
                    },
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: _selectedReportType != 'All Types'
                          ? AppTheme.primaryLight
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Status Filter
            _buildFilterSection(
              'Status',
              Icons.info_outline,
              AppTheme.successLight,
              child: Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: _statusOptions.map((status) {
                  final isSelected = _selectedStatus == status;
                  final isAll = status == 'All Status';
                  Color statusColor = AppTheme.successLight;

                  if (!isAll) {
                    switch (status) {
                      case 'Completed':
                        statusColor = AppTheme.successLight;
                        break;
                      case 'Generating':
                        statusColor = AppTheme.warningLight;
                        break;
                      case 'Failed':
                        statusColor = AppTheme.errorLight;
                        break;
                    }
                  }

                  return FilterChip(
                    label: Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? (isAll ? AppTheme.primaryLight : statusColor)
                                : AppTheme.textSecondaryLight,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                      _notifyFilterChange();
                    },
                    backgroundColor: isAll
                        ? AppTheme.backgroundLight
                        : statusColor.withValues(alpha: 0.05),
                    selectedColor: isAll
                        ? AppTheme.primaryLight.withValues(alpha: 0.1)
                        : statusColor.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: isSelected
                          ? (isAll ? AppTheme.primaryLight : statusColor)
                              .withValues(alpha: 0.3)
                          : AppTheme.borderSubtleLight,
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
            ),

            if (_hasActiveFilters) ...[
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.purple,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Filters applied. Showing filtered results below.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.purple,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    IconData icon,
    Color color, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        child,
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.teal,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _notifyFilterChange();
    }
  }

  void _clearAllFilters() {
    setState(() {
      _dateRange = null;
      _selectedReportType = 'All Types';
      _selectedStatus = 'All Status';
    });
    _notifyFilterChange();
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_dateRange != null) count++;
    if (_selectedReportType != 'All Types') count++;
    if (_selectedStatus != 'All Status') count++;
    return count;
  }

  void _notifyFilterChange() {
    final filters = <String, dynamic>{
      if (_dateRange != null) 'dateRange': _dateRange,
      if (_selectedReportType != 'All Types') 'reportType': _selectedReportType,
      if (_selectedStatus != 'All Status') 'status': _selectedStatus,
    };

    widget.onFilterChanged(filters);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
