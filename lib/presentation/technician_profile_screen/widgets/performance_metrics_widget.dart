import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../services/performance_service.dart';

class PerformanceMetricsWidget extends StatefulWidget {
  final String? technicianId;

  const PerformanceMetricsWidget({
    Key? key,
    this.technicianId,
  }) : super(key: key);

  @override
  State<PerformanceMetricsWidget> createState() =>
      _PerformanceMetricsWidgetState();
}

class _PerformanceMetricsWidgetState extends State<PerformanceMetricsWidget> {
  final PerformanceService _performanceService = PerformanceService.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _performanceData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _performanceService.getTechnicianPerformanceMetrics(
        technicianId: widget.technicianId,
      );

      if (mounted) {
        setState(() {
          _performanceData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadPerformanceData();
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
                    Icons.analytics,
                    color: Colors.purple,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Performance Metrics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (!_isLoading)
                  IconButton(
                    onPressed: _refreshData,
                    icon: Icon(
                      Icons.refresh,
                      size: 5.w,
                      color: AppTheme.primaryLight,
                    ),
                    tooltip: 'Refresh Data',
                  ),
              ],
            ),
            SizedBox(height: 3.h),
            if (_isLoading)
              _buildLoadingState()
            else if (_error != null)
              _buildErrorState()
            else if (_performanceData != null)
              _buildPerformanceContent()
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(height: 4.h),
        Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryLight,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading performance data...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Failed to load metrics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _error ?? 'Unknown error occurred',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        ElevatedButton(
          onPressed: _refreshData,
          child: const Text('Try Again'),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        SizedBox(height: 2.h),
        Text(
          'No performance data available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildPerformanceContent() {
    final data = _performanceData!;

    return Column(
      children: [
        _buildMetricCard(
          context,
          'Total Orders Completed',
          '${data['totalCompleted'] ?? 0}',
          Icons.check_circle,
          AppTheme.successLight,
          '+${data['monthlyChange'] ?? 0} this month',
        ),
        SizedBox(height: 2.h),
        _buildMetricCard(
          context,
          'Average Rating',
          '${data['averageRating'] ?? 0.0}',
          Icons.star,
          Colors.orange,
          '↑ Based on performance',
        ),
        SizedBox(height: 2.h),
        _buildMetricCard(
          context,
          'Earnings This Month',
          '\$${(data['currentMonthEarnings'] ?? 0.0).toStringAsFixed(0)}',
          Icons.attach_money,
          AppTheme.primaryLight,
          '${data['earningsChangePercentage'] ?? 0.0 >= 0 ? '+' : ''}${data['earningsChangePercentage'] ?? 0.0}% vs last month',
        ),
        SizedBox(height: 2.h),
        _buildMetricCard(
          context,
          'Completion Rate',
          '${data['completionRate'] ?? 0}%',
          Icons.task_alt,
          Colors.teal,
          '${data['incompletedCount'] ?? 0}/${data['totalAssigned'] ?? 0} incomplete',
        ),
        SizedBox(height: 3.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryLight.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppTheme.primaryLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Performance Trend',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryLight,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Live Data',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.successLight,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  SizedBox(width: 1.w),
                  Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: AppTheme.successLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildProgressBar(
                  'Monthly Target Progress',
                  (data['monthlyProgress'] ?? 0.0) / 100,
                  AppTheme.successLight),
              SizedBox(height: 1.5.h),
              _buildProgressBar('Quality Score',
                  (data['qualityScore'] ?? 0.0) / 100, AppTheme.primaryLight),
              SizedBox(height: 1.5.h),
              _buildProgressBar('Customer Satisfaction',
                  (data['customerSatisfaction'] ?? 0.0) / 100, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 0.8.h,
          decoration: BoxDecoration(
            color: AppTheme.borderSubtleLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
