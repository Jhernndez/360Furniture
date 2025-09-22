import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AvailabilityStatusWidget extends StatefulWidget {
  final VoidCallback? onChanged;

  const AvailabilityStatusWidget({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  @override
  State<AvailabilityStatusWidget> createState() =>
      _AvailabilityStatusWidgetState();
}

class _AvailabilityStatusWidgetState extends State<AvailabilityStatusWidget>
    with TickerProviderStateMixin {
  bool _isAvailable = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (_isAvailable) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _toggleAvailability(bool value) {
    setState(() {
      _isAvailable = value;
    });

    if (_isAvailable) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    widget.onChanged?.call();
    _showStatusChangeDialog();
  }

  void _showStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: _isAvailable
                      ? AppTheme.successLight
                      : AppTheme.errorLight,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3.w),
              Text(_isAvailable ? 'Now Available' : 'Now Unavailable'),
            ],
          ),
          content: Text(
            _isAvailable
                ? 'You are now available to receive new service orders.'
                : 'You will not receive new service orders until you mark yourself as available.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
                    color: _isAvailable
                        ? AppTheme.successLight.withValues(alpha: 0.1)
                        : AppTheme.errorLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isAvailable ? Icons.check_circle : Icons.do_not_disturb,
                    color: _isAvailable
                        ? AppTheme.successLight
                        : AppTheme.errorLight,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Availability Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: _isAvailable
                    ? AppTheme.successLight.withValues(alpha: 0.1)
                    : AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isAvailable
                      ? AppTheme.successLight.withValues(alpha: 0.3)
                      : AppTheme.errorLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isAvailable ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: _isAvailable
                                ? AppTheme.successLight
                                : AppTheme.errorLight,
                            shape: BoxShape.circle,
                            boxShadow: _isAvailable
                                ? [
                                    BoxShadow(
                                      color: AppTheme.successLight
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _isAvailable ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 5.w,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAvailable ? 'Available for Orders' : 'Unavailable',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _isAvailable
                                        ? AppTheme.successLight
                                        : AppTheme.errorLight,
                                  ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _isAvailable
                              ? 'You will receive new service requests'
                              : 'New orders will not be assigned to you',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _isAvailable
                                        ? AppTheme.successLight
                                        : AppTheme.errorLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isAvailable,
                    onChanged: _toggleAvailability,
                    activeThumbColor: AppTheme.successLight,
                    inactiveThumbColor: AppTheme.errorLight,
                  ),
                ],
              ),
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
                        Icons.schedule,
                        color: AppTheme.primaryLight,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Working Hours',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryLight,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildWorkingHours('Monday - Friday', '8:00 AM - 6:00 PM'),
                  SizedBox(height: 1.h),
                  _buildWorkingHours('Saturday', '9:00 AM - 3:00 PM'),
                  SizedBox(height: 1.h),
                  _buildWorkingHours('Sunday', 'Closed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHours(String day, String hours) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            hours,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
