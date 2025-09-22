import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AutomatedSchedulingWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onScheduleUpdate;

  const AutomatedSchedulingWidget({
    Key? key,
    required this.onScheduleUpdate,
  }) : super(key: key);

  @override
  State<AutomatedSchedulingWidget> createState() =>
      _AutomatedSchedulingWidgetState();
}

class _AutomatedSchedulingWidgetState extends State<AutomatedSchedulingWidget> {
  List<ScheduleItem> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadExistingSchedules();
  }

  void _loadExistingSchedules() {
    _schedules = [
      ScheduleItem(
        id: '1',
        reportType: 'Performance Summary',
        frequency: 'Weekly',
        time: const TimeOfDay(hour: 9, minute: 0),
        dayOfWeek: 'Monday',
        isEnabled: true,
        lastRun: DateTime.now().subtract(const Duration(days: 7)),
        nextRun: DateTime.now().add(const Duration(days: 0)),
        recipients: ['admin@servicetracker.com', 'manager@servicetracker.com'],
      ),
      ScheduleItem(
        id: '2',
        reportType: 'Financial Overview',
        frequency: 'Monthly',
        time: const TimeOfDay(hour: 8, minute: 30),
        dayOfMonth: 1,
        isEnabled: true,
        lastRun: DateTime.now().subtract(const Duration(days: 30)),
        nextRun:
            DateTime(DateTime.now().year, DateTime.now().month + 1, 1, 8, 30),
        recipients: ['finance@servicetracker.com'],
      ),
      ScheduleItem(
        id: '3',
        reportType: 'Service Analysis',
        frequency: 'Daily',
        time: const TimeOfDay(hour: 18, minute: 0),
        isEnabled: false,
        lastRun: DateTime.now().subtract(const Duration(days: 5)),
        nextRun: null,
        recipients: ['operations@servicetracker.com'],
      ),
    ];
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
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.amber[700],
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Automated Scheduling',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addNewSchedule,
                  icon: Icon(Icons.add, size: 4.w),
                  label: const Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Configure recurring report generation with notification preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
            SizedBox(height: 3.h),
            if (_schedules.isEmpty)
              _buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  final schedule = _schedules[index];
                  return _buildScheduleCard(schedule, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 20.w,
            color: AppTheme.textDisabledLight,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Scheduled Reports',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondaryLight,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Set up automatic report generation and delivery',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _addNewSchedule,
            icon: const Icon(Icons.add_alarm),
            label: const Text('Create Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem schedule, int index) {
    final statusColor =
        schedule.isEnabled ? AppTheme.successLight : AppTheme.textDisabledLight;
    final nextRunText = schedule.nextRun != null
        ? _formatDateTime(schedule.nextRun!)
        : 'Not scheduled';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: schedule.isEnabled
            ? statusColor.withValues(alpha: 0.05)
            : AppTheme.textDisabledLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: schedule.isEnabled
              ? statusColor.withValues(alpha: 0.3)
              : AppTheme.textDisabledLight.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
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
                    _getFrequencyIcon(schedule.frequency),
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
                        schedule.reportType,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${schedule.frequency} • ${_formatTime(schedule.time)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: schedule.isEnabled,
                  onChanged: (bool value) {
                    _toggleSchedule(index, value);
                  },
                  activeThumbColor: AppTheme.successLight,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleScheduleAction(value, index),
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Duplicate'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderSubtleLight,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Next Run', nextRunText, Icons.schedule),
                  SizedBox(height: 1.h),
                  _buildInfoRow(
                    'Last Run',
                    schedule.lastRun != null
                        ? _formatDateTime(schedule.lastRun!)
                        : 'Never',
                    Icons.history,
                  ),
                  SizedBox(height: 1.h),
                  _buildInfoRow(
                    'Recipients',
                    '${schedule.recipients.length} recipient${schedule.recipients.length > 1 ? 's' : ''}',
                    Icons.email,
                  ),
                ],
              ),
            ),
            if (schedule.isEnabled && schedule.nextRun != null) ...[
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _runNow(schedule),
                      icon: Icon(Icons.play_arrow, size: 4.w),
                      label: const Text('Run Now'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _testEmail(schedule),
                      icon: Icon(Icons.email, size: 4.w),
                      label: const Text('Test Email'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 4.w,
          color: AppTheme.textSecondaryLight,
        ),
        SizedBox(width: 2.w),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
        ),
      ],
    );
  }

  void _addNewSchedule() {
    _showScheduleDialog();
  }

  void _toggleSchedule(int index, bool value) {
    setState(() {
      _schedules[index].isEnabled = value;
      if (value) {
        // Calculate next run time
        _schedules[index].nextRun = _calculateNextRun(_schedules[index]);
      } else {
        _schedules[index].nextRun = null;
      }
    });

    widget.onScheduleUpdate({
      'action': 'toggle',
      'schedule': _schedules[index].toMap(),
    });
  }

  void _handleScheduleAction(String action, int index) {
    switch (action) {
      case 'edit':
        _showScheduleDialog(schedule: _schedules[index], index: index);
        break;
      case 'duplicate':
        _duplicateSchedule(index);
        break;
      case 'delete':
        _deleteSchedule(index);
        break;
    }
  }

  void _showScheduleDialog({ScheduleItem? schedule, int? index}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(schedule != null ? 'Edit Schedule' : 'New Schedule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simplified schedule creation form
                Text('Schedule creation form would go here'),
                SizedBox(height: 2.h),
                Text('Features: Report type, frequency, time, recipients'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle save logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Schedule ${schedule != null ? 'updated' : 'created'}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(schedule != null ? 'Update' : 'Create'),
            ),
          ],
        );
      },
    );
  }

  void _duplicateSchedule(int index) {
    final originalSchedule = _schedules[index];
    final newSchedule = ScheduleItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reportType: originalSchedule.reportType,
      frequency: originalSchedule.frequency,
      time: originalSchedule.time,
      dayOfWeek: originalSchedule.dayOfWeek,
      dayOfMonth: originalSchedule.dayOfMonth,
      isEnabled: false,
      lastRun: null,
      nextRun: null,
      recipients: List.from(originalSchedule.recipients),
    );

    setState(() {
      _schedules.add(newSchedule);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schedule duplicated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteSchedule(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Schedule'),
          content: Text(
              'Are you sure you want to delete the ${_schedules[index].reportType} schedule?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _schedules.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Schedule deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _runNow(ScheduleItem schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating ${schedule.reportType} report...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _testEmail(ScheduleItem schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Test email sent to ${schedule.recipients.length} recipient(s)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  DateTime _calculateNextRun(ScheduleItem schedule) {
    final now = DateTime.now();
    switch (schedule.frequency) {
      case 'Daily':
        final nextRun = DateTime(now.year, now.month, now.day,
            schedule.time.hour, schedule.time.minute);
        return nextRun.isBefore(now)
            ? nextRun.add(const Duration(days: 1))
            : nextRun;
      case 'Weekly':
        // Simplified weekly calculation
        return now.add(const Duration(days: 7));
      case 'Monthly':
        return DateTime(now.year, now.month + 1, schedule.dayOfMonth ?? 1,
            schedule.time.hour, schedule.time.minute);
      default:
        return now.add(const Duration(days: 1));
    }
  }

  IconData _getFrequencyIcon(String frequency) {
    switch (frequency) {
      case 'Daily':
        return Icons.today;
      case 'Weekly':
        return Icons.date_range;
      case 'Monthly':
        return Icons.calendar_month;
      default:
        return Icons.schedule;
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(TimeOfDay.fromDateTime(dateTime))}';
  }
}

class ScheduleItem {
  String id;
  String reportType;
  String frequency;
  TimeOfDay time;
  String? dayOfWeek;
  int? dayOfMonth;
  bool isEnabled;
  DateTime? lastRun;
  DateTime? nextRun;
  List<String> recipients;

  ScheduleItem({
    required this.id,
    required this.reportType,
    required this.frequency,
    required this.time,
    this.dayOfWeek,
    this.dayOfMonth,
    required this.isEnabled,
    this.lastRun,
    this.nextRun,
    required this.recipients,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportType': reportType,
      'frequency': frequency,
      'time': '${time.hour}:${time.minute}',
      'dayOfWeek': dayOfWeek,
      'dayOfMonth': dayOfMonth,
      'isEnabled': isEnabled,
      'lastRun': lastRun?.toIso8601String(),
      'nextRun': nextRun?.toIso8601String(),
      'recipients': recipients,
    };
  }
}
