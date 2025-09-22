import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ReportTypeGridWidget extends StatefulWidget {
  final String selectedPeriod;
  final bool isAdmin;
  final Function(String) onReportGenerate;

  const ReportTypeGridWidget({
    Key? key,
    required this.selectedPeriod,
    required this.isAdmin,
    required this.onReportGenerate,
  }) : super(key: key);

  @override
  State<ReportTypeGridWidget> createState() => _ReportTypeGridWidgetState();
}

class _ReportTypeGridWidgetState extends State<ReportTypeGridWidget> {
  String? _generatingReport;

  @override
  Widget build(BuildContext context) {
    final reportTypes = _getAvailableReportTypes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics,
                color: AppTheme.primaryLight,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Report Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Period: ${widget.selectedPeriod}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 0.85,
          ),
          itemCount: reportTypes.length,
          itemBuilder: (context, index) {
            final reportType = reportTypes[index];
            final isGenerating = _generatingReport == reportType.name;

            return _buildReportTypeCard(reportType, isGenerating);
          },
        ),
      ],
    );
  }

  Widget _buildReportTypeCard(ReportTypeModel reportType, bool isGenerating) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: isGenerating ? null : () => _generateReport(reportType),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: reportType.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      reportType.icon,
                      color: reportType.color,
                      size: 6.w,
                    ),
                  ),
                  const Spacer(),
                  if (reportType.isNew)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'NEW',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 8.sp,
                            ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                reportType.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              Text(
                reportType.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  if (reportType.previewMetrics.isNotEmpty) ...[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: reportType.color.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: reportType.color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          reportType.previewMetrics,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: reportType.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                  ],
                  Container(
                    width: 12.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: isGenerating
                          ? AppTheme.textDisabledLight
                          : reportType.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isGenerating
                        ? Center(
                            child: SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.onSurfaceLight,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 5.w,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateReport(ReportTypeModel reportType) async {
    setState(() {
      _generatingReport = reportType.name;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _generatingReport = null;
      });

      widget.onReportGenerate(reportType.name);
    }
  }

  List<ReportTypeModel> _getAvailableReportTypes() {
    final baseReports = [
      ReportTypeModel(
        name: 'Performance Summary',
        description: 'Individual technician performance metrics and KPIs',
        icon: Icons.trending_up,
        color: AppTheme.successLight,
        previewMetrics: '96% completion',
        isNew: false,
      ),
      ReportTypeModel(
        name: 'Financial Overview',
        description: 'Earnings, payments, and financial breakdown',
        icon: Icons.attach_money,
        color: AppTheme.primaryLight,
        previewMetrics: '\$3,420 earned',
        isNew: false,
      ),
      ReportTypeModel(
        name: 'Service Analysis',
        description: 'Service types, duration, and efficiency metrics',
        icon: Icons.build,
        color: Colors.purple,
        previewMetrics: '4.8★ avg rating',
        isNew: false,
      ),
      ReportTypeModel(
        name: 'Customer Insights',
        description: 'Customer satisfaction and feedback analysis',
        icon: Icons.people,
        color: Colors.teal,
        previewMetrics: '92% satisfaction',
        isNew: true,
      ),
    ];

    // Admin-only reports
    if (widget.isAdmin) {
      baseReports.addAll([
        ReportTypeModel(
          name: 'System Analytics',
          description: 'Overall system performance and usage statistics',
          icon: Icons.dashboard,
          color: Colors.indigo,
          previewMetrics: '156 total orders',
          isNew: false,
        ),
        ReportTypeModel(
          name: 'Revenue Analysis',
          description: 'Company-wide revenue trends and projections',
          icon: Icons.show_chart,
          color: Colors.green,
          previewMetrics: '\$28,500 total',
          isNew: false,
        ),
      ]);
    }

    return baseReports;
  }
}

class ReportTypeModel {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String previewMetrics;
  final bool isNew;

  ReportTypeModel({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.previewMetrics,
    this.isNew = false,
  });
}
