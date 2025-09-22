import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RevenueChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> revenueData;
  final Function(String) onServiceTypeTap;

  const RevenueChartWidget({
    Key? key,
    required this.revenueData,
    required this.onServiceTypeTap,
  }) : super(key: key);

  @override
  State<RevenueChartWidget> createState() => _RevenueChartWidgetState();
}

class _RevenueChartWidgetState extends State<RevenueChartWidget> {
  int touchedIndex = -1;

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
                iconName: 'pie_chart',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Revenue by Service Type',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          widget.revenueData.isEmpty
              ? _buildEmptyState()
              : SizedBox(
                  height: 30.h,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _buildPieChartSections(),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        flex: 2,
                        child: _buildLegend(),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colors = [
      AppTheme.primaryLight,
      AppTheme.successLight,
      AppTheme.warningLight,
      AppTheme.errorLight,
    ];

    return widget.revenueData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: (data['amount'] as double? ?? 0.0),
        title:
            '${((data['amount'] as double? ?? 0.0) / _getTotalAmount() * 100).toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = [
      AppTheme.primaryLight,
      AppTheme.successLight,
      AppTheme.warningLight,
      AppTheme.errorLight,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.revenueData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;

        return GestureDetector(
          onTap: () =>
              widget.onServiceTypeTap(data['serviceType']?.toString() ?? ''),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 0.5.h),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['serviceType']?.toString() ?? 'Unknown',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '\$${(data['amount'] as double? ?? 0.0).toStringAsFixed(0)}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: 30.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'pie_chart_outline',
            color: AppTheme.textDisabledLight,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Revenue Data',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Complete some orders to see revenue breakdown',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textDisabledLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _getTotalAmount() {
    return widget.revenueData
        .fold(0.0, (sum, item) => sum + (item['amount'] as double? ?? 0.0));
  }
}
