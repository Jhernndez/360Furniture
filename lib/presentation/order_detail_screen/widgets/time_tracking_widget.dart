import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimeTrackingWidget extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final Function(double) onTimeChanged;

  const TimeTrackingWidget({
    super.key,
    required this.orderData,
    required this.onTimeChanged,
  });

  @override
  State<TimeTrackingWidget> createState() => _TimeTrackingWidgetState();
}

class _TimeTrackingWidgetState extends State<TimeTrackingWidget> {
  String formatMinutesToHourMin(dynamic value) {
    int totalMinutes = 0;
    if (value is int) {
      totalMinutes = value;
    } else if (value is String && int.tryParse(value) != null) {
      totalMinutes = int.parse(value);
    } else if (value is double) {
      totalMinutes = value.round();
    }
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final timeSpentRaw = widget.orderData['timeSpent'];
    int totalMinutes = 0;
    if (timeSpentRaw is int) {
      totalMinutes = timeSpentRaw;
    } else if (timeSpentRaw is String && int.tryParse(timeSpentRaw) != null) {
      totalMinutes = int.parse(timeSpentRaw);
    } else if (timeSpentRaw is double) {
      totalMinutes = timeSpentRaw.round();
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    _hoursController = TextEditingController(text: hours.toString());
    _minutesController = TextEditingController(text: minutes.toString());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _saveTimeChanges() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final totalHours = hours + (minutes / 60.0);

    setState(() {
      _isEditing = false;
    });

    // Guardar en horas decimales en el modelo, la lógica de minutos se hace en el screen
    widget.onTimeChanged(totalHours);
  }

  void _cancelTimeChanges() {
    final timeSpentRaw = widget.orderData['timeSpent'];
    int totalMinutes = 0;
    if (timeSpentRaw is int) {
      totalMinutes = timeSpentRaw;
    } else if (timeSpentRaw is String && int.tryParse(timeSpentRaw) != null) {
      totalMinutes = int.parse(timeSpentRaw);
    } else if (timeSpentRaw is double) {
      totalMinutes = timeSpentRaw.round();
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    _hoursController.text = hours.toString();
    _minutesController.text = minutes.toString();

    setState(() {
      _isEditing = false;
    });
  }

  String _formatDuration(double hours) {
    final h = hours.truncate();
    final m = ((hours - h) * 60).round();

    if (h == 0) {
      return '${m}m';
    } else if (m == 0) {
      return '${h}h';
    } else {
      return '${h}h ${m}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeSpentRaw = widget.orderData['timeSpent'];
    final timeSpentStr = _formatDuration(timeSpentRaw is num
        ? timeSpentRaw.toDouble()
        : double.tryParse(timeSpentRaw.toString()) ?? 0.0);
    final startTime = widget.orderData['startTime'] as String? ?? '';
    final endTime = widget.orderData['endTime'] as String? ?? '';

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seguimiento de Tiempo',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_isEditing)
                InkWell(
                  onTap: () => setState(() => _isEditing = true),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),

          // Time breakdown section
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                if (startTime.isNotEmpty && endTime.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildTimeInfo('Inicio', startTime, 'play_arrow'),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: _buildTimeInfo('Fin', endTime, 'stop'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Divider(color: AppTheme.borderSubtleLight),
                  SizedBox(height: 2.h),
                ],

                // Total time section
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tiempo Total Trabajado',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          _isEditing
                              ? _buildTimeEditor()
                              : Text(
                                  timeSpentStr,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleLarge
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_isEditing) ...[
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelTimeChanges,
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTimeChanges,
                    child: Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, String iconName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.textSecondaryLight,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          time,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(double timeSpent) {
    return Text(
      _formatDuration(timeSpent),
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        color: AppTheme.lightTheme.colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTimeEditor() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _hoursController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              labelText: 'Horas',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          ':',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: TextFormField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              labelText: 'Minutos',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
