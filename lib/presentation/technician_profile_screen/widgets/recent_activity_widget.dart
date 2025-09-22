import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recentActivities = _getRecentActivities();

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
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.indigo,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity history
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View all activity coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Last 10 completed orders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
            SizedBox(height: 2.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivities.length,
              itemBuilder: (context, index) {
                final activity = recentActivities[index];
                return _buildActivityTile(context, activity);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, RecentActivity activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: activity.statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity.statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(context, activity),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: activity.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity.icon,
                color: activity.statusColor,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.orderNumber,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    activity.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: activity.statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: activity.statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          activity.status,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: activity.statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        activity.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 4.w,
              color: AppTheme.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, RecentActivity activity) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                margin: EdgeInsets.only(bottom: 3.h),
                decoration: BoxDecoration(
                  color: AppTheme.textDisabledLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: activity.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      activity.icon,
                      color: activity.statusColor,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.orderNumber,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          activity.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              _buildDetailRow(
                  context, 'Status', activity.status, activity.statusColor),
              _buildDetailRow(context, 'Service Type', activity.serviceType,
                  AppTheme.primaryLight),
              _buildDetailRow(context, 'Completion Time',
                  activity.completionTime, AppTheme.textPrimaryLight),
              _buildDetailRow(
                  context, 'Rating', '${activity.rating}★', Colors.orange),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to full order details
                  },
                  child: const Text('View Full Details'),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, Color valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  List<RecentActivity> _getRecentActivities() {
    return [
      RecentActivity(
        orderNumber: '#SR-2025-001',
        description: 'Leather sofa repair - Downtown Office',
        status: 'Completed',
        statusColor: AppTheme.successLight,
        icon: Icons.check_circle,
        timeAgo: '2 hours ago',
        serviceType: 'Leather Repair',
        completionTime: '2.5 hours',
        rating: 4.9,
      ),
      RecentActivity(
        orderNumber: '#SR-2025-002',
        description: 'Wood table restoration - Home Residence',
        status: 'Completed',
        statusColor: AppTheme.successLight,
        icon: Icons.check_circle,
        timeAgo: '1 day ago',
        serviceType: 'Wood Restoration',
        completionTime: '3.0 hours',
        rating: 5.0,
      ),
      RecentActivity(
        orderNumber: '#SR-2025-003',
        description: 'Upholstery cleaning - Corporate Office',
        status: 'Completed',
        statusColor: AppTheme.successLight,
        icon: Icons.check_circle,
        timeAgo: '2 days ago',
        serviceType: 'Upholstery Cleaning',
        completionTime: '1.5 hours',
        rating: 4.8,
      ),
      RecentActivity(
        orderNumber: '#SR-2025-004',
        description: 'Chair repair - Restaurant Chain',
        status: 'Completed',
        statusColor: AppTheme.successLight,
        icon: Icons.check_circle,
        timeAgo: '3 days ago',
        serviceType: 'Wood Repair',
        completionTime: '2.0 hours',
        rating: 4.7,
      ),
      RecentActivity(
        orderNumber: '#SR-2025-005',
        description: 'Leather cleaning - Hotel Suite',
        status: 'Completed',
        statusColor: AppTheme.successLight,
        icon: Icons.check_circle,
        timeAgo: '4 days ago',
        serviceType: 'Leather Cleaning',
        completionTime: '1.8 hours',
        rating: 4.9,
      ),
    ];
  }
}

class RecentActivity {
  final String orderNumber;
  final String description;
  final String status;
  final Color statusColor;
  final IconData icon;
  final String timeAgo;
  final String serviceType;
  final String completionTime;
  final double rating;

  RecentActivity({
    required this.orderNumber,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.timeAgo,
    required this.serviceType,
    required this.completionTime,
    required this.rating,
  });
}
