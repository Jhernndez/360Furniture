import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimeTrackingComponent extends StatefulWidget {
  final Duration currentDuration;
  final bool isRunning;
  final Function(Duration) onDurationChanged;
  final VoidCallback onStartStop;

  const TimeTrackingComponent({
    Key? key,
    required this.currentDuration,
    required this.isRunning,
    required this.onDurationChanged,
    required this.onStartStop,
  }) : super(key: key);

  @override
  State<TimeTrackingComponent> createState() => _TimeTrackingComponentState();
}

class _TimeTrackingComponentState extends State<TimeTrackingComponent> {
  Timer? _timer;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  bool _isManualAdjustment = false;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController();
    _minutesController = TextEditingController();
    _updateControllers();
  }

  @override
  void didUpdateWidget(TimeTrackingComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDuration != widget.currentDuration &&
        !_isManualAdjustment) {
      _updateControllers();
    }

    if (widget.isRunning && _timer == null) {
      _startTimer();
    } else if (!widget.isRunning && _timer != null) {
      _stopTimer();
    }
  }

  void _updateControllers() {
    final hours = widget.currentDuration.inHours;
    final minutes = widget.currentDuration.inMinutes % 60;

    _hoursController.text = hours.toString().padLeft(2, '0');
    _minutesController.text = minutes.toString().padLeft(2, '0');
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isManualAdjustment) {
        final newDuration = widget.currentDuration + const Duration(seconds: 1);
        widget.onDurationChanged(newDuration);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onManualTimeChange() {
    if (_isManualAdjustment) {
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;

      if (minutes < 60) {
        final newDuration = Duration(hours: hours, minutes: minutes);
        widget.onDurationChanged(newDuration);
      } else {
        _updateControllers();
      }
    }
  }

  void _toggleManualAdjustment() {
    setState(() {
      _isManualAdjustment = !_isManualAdjustment;
      if (!_isManualAdjustment) {
        _updateControllers();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Service Time',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: widget.isRunning ? null : _toggleManualAdjustment,
              icon: CustomIconWidget(
                iconName: _isManualAdjustment ? 'timer' : 'edit',
                color: widget.isRunning
                    ? AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.4)
                    : AppTheme.lightTheme.primaryColor,
                size: 4.w,
              ),
              label: Text(
                _isManualAdjustment ? 'Timer' : 'Manual',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: widget.isRunning
                      ? AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.4)
                      : AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: widget.isRunning
                ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05)
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isRunning
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.outline,
              width: widget.isRunning ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Timer Display
              if (!_isManualAdjustment) ...[
                Text(
                  _formatDuration(widget.currentDuration),
                  style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.isRunning
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ] else ...[
                // Manual Time Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 15.w,
                      child: TextFormField(
                        controller: _hoursController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (_) => _onManualTimeChange(),
                        style: AppTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '00',
                          hintStyle: AppTheme.lightTheme.textTheme.displaySmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ':',
                      style:
                          AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      width: 15.w,
                      child: TextFormField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (_) => _onManualTimeChange(),
                        style: AppTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '00',
                          hintStyle: AppTheme.lightTheme.textTheme.displaySmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'h:m',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 3.h),
              // Start/Stop Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isManualAdjustment ? null : widget.onStartStop,
                  icon: CustomIconWidget(
                    iconName: widget.isRunning ? 'pause' : 'play_arrow',
                    color: _isManualAdjustment
                        ? AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.4)
                        : AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 5.w,
                  ),
                  label: Text(
                    widget.isRunning ? 'Pause Timer' : 'Start Timer',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: _isManualAdjustment
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.4)
                          : AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isManualAdjustment
                        ? AppTheme.lightTheme.colorScheme.surface
                        : (widget.isRunning
                            ? AppTheme.warningLight
                            : AppTheme.lightTheme.primaryColor),
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
