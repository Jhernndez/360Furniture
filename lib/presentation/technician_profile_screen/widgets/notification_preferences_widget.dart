import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class NotificationPreferencesWidget extends StatefulWidget {
  final VoidCallback? onChanged;

  const NotificationPreferencesWidget({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  @override
  State<NotificationPreferencesWidget> createState() =>
      _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState
    extends State<NotificationPreferencesWidget> {
  bool _orderUpdates = true;
  bool _paymentConfirmations = true;
  bool _systemAnnouncements = false;

  void _updatePreference(String type, bool value) {
    setState(() {
      switch (type) {
        case 'orders':
          _orderUpdates = value;
          break;
        case 'payments':
          _paymentConfirmations = value;
          break;
        case 'system':
          _systemAnnouncements = value;
          break;
      }
    });
    widget.onChanged?.call();
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
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: Colors.orange,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Notification Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildNotificationTile(
              'Order Updates',
              'New orders, status changes, and completion confirmations',
              Icons.assignment,
              _orderUpdates,
              (value) => _updatePreference('orders', value),
            ),
            SizedBox(height: 2.h),
            _buildNotificationTile(
              'Payment Confirmations',
              'Payment received notifications and earning updates',
              Icons.payment,
              _paymentConfirmations,
              (value) => _updatePreference('payments', value),
            ),
            SizedBox(height: 2.h),
            _buildNotificationTile(
              'System Announcements',
              'App updates, maintenance notices, and company news',
              Icons.campaign,
              _systemAnnouncements,
              (value) => _updatePreference('system', value),
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
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'You can adjust notification timing and frequency in your device settings.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryLight,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: value
            ? AppTheme.successLight.withValues(alpha: 0.05)
            : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.successLight.withValues(alpha: 0.2)
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.successLight.withValues(alpha: 0.1)
                  : AppTheme.textDisabledLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppTheme.successLight : AppTheme.textDisabledLight,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
