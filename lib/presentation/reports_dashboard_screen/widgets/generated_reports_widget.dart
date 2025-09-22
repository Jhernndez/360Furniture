import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GeneratedReportsWidget extends StatelessWidget {
  final bool isAdmin;
  final Function(Map<String, dynamic>) onReportTap;
  final Function(Map<String, dynamic>) onReportShare;
  final Function(Map<String, dynamic>) onReportExport;
  final Function(Map<String, dynamic>) onReportDelete;

  const GeneratedReportsWidget({
    Key? key,
    required this.isAdmin,
    required this.onReportTap,
    required this.onReportShare,
    required this.onReportExport,
    required this.onReportDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reports = _getGeneratedReports();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder,
                color: Colors.indigo,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Generated Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showSortOptions(context),
              icon: Icon(Icons.sort, size: 4.w),
              label: const Text('Sort'),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'Chronological list of available reports',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
        ),
        SizedBox(height: 3.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(context, report);
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report) {
    final status = report['status'] as ReportStatus;
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Card(
        elevation: 2.0,
        child: InkWell(
          onTap: status == ReportStatus.completed
              ? () => onReportTap(report)
              : null,
          borderRadius: BorderRadius.circular(8),
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
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getReportIcon(report['type']),
                        color: statusColor,
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['name'],
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${report['type']} • ${report['period']}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondaryLight,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(context, status),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    _buildInfoItem(
                      context,
                      Icons.access_time,
                      _formatDateTime(report['createdAt']),
                    ),
                    SizedBox(width: 4.w),
                    _buildInfoItem(
                      context,
                      Icons.folder_outlined,
                      report['size'],
                    ),
                    const Spacer(),
                    if (status == ReportStatus.downloading)
                      SizedBox(
                        width: 6.w,
                        height: 6.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: statusColor,
                          value: report['downloadProgress'],
                        ),
                      ),
                  ],
                ),
                if (status == ReportStatus.completed) ...[
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => onReportShare(report),
                          icon: Icon(Icons.share, size: 4.w),
                          label: const Text('Share'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => onReportExport(report),
                          icon: Icon(Icons.download, size: 4.w),
                          label: const Text('Export'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      IconButton(
                        onPressed: () => onReportDelete(report),
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppTheme.errorLight,
                          size: 5.w,
                        ),
                        tooltip: 'Delete Report',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ReportStatus status) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 1.h,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 4.w,
          color: AppTheme.textSecondaryLight,
        ),
        SizedBox(width: 1.w),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
        ),
      ],
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.textDisabledLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Sort Reports',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Most Recent'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.access_time_filled),
                title: const Text('Oldest First'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('By Type'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('By Size'),
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.completed:
        return AppTheme.successLight;
      case ReportStatus.generating:
        return AppTheme.warningLight;
      case ReportStatus.downloading:
        return AppTheme.primaryLight;
      case ReportStatus.failed:
        return AppTheme.errorLight;
    }
  }

  String _getStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.completed:
        return 'Ready';
      case ReportStatus.generating:
        return 'Generating';
      case ReportStatus.downloading:
        return 'Downloading';
      case ReportStatus.failed:
        return 'Failed';
    }
  }

  IconData _getReportIcon(String type) {
    switch (type) {
      case 'Performance Summary':
        return Icons.trending_up;
      case 'Financial Overview':
        return Icons.attach_money;
      case 'Service Analysis':
        return Icons.build;
      case 'Customer Insights':
        return Icons.people;
      case 'System Analytics':
        return Icons.dashboard;
      case 'Revenue Analysis':
        return Icons.show_chart;
      default:
        return Icons.description;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  List<Map<String, dynamic>> _getGeneratedReports() {
    return [
      {
        'name': 'Performance Summary - Weekly',
        'type': 'Performance Summary',
        'period': 'Weekly',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'size': '2.5 MB',
        'status': ReportStatus.completed,
      },
      {
        'name': 'Financial Overview - Monthly',
        'type': 'Financial Overview',
        'period': 'Monthly',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'size': '4.2 MB',
        'status': ReportStatus.completed,
      },
      {
        'name': 'Service Analysis - Daily',
        'type': 'Service Analysis',
        'period': 'Daily',
        'createdAt': DateTime.now().subtract(const Duration(minutes: 30)),
        'size': '1.8 MB',
        'status': ReportStatus.generating,
      },
      {
        'name': 'Customer Insights - Weekly',
        'type': 'Customer Insights',
        'period': 'Weekly',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        'size': '3.1 MB',
        'status': ReportStatus.completed,
      },
      if (isAdmin) ...[
        {
          'name': 'System Analytics - Monthly',
          'type': 'System Analytics',
          'period': 'Monthly',
          'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
          'size': '8.7 MB',
          'status': ReportStatus.downloading,
          'downloadProgress': 0.65,
        },
        {
          'name': 'Revenue Analysis - Weekly',
          'type': 'Revenue Analysis',
          'period': 'Weekly',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
          'size': '5.3 MB',
          'status': ReportStatus.failed,
        },
      ],
    ];
  }
}

enum ReportStatus { completed, generating, downloading, failed }
