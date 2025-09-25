import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RateManagementSection extends StatefulWidget {
  final String selectedServiceType;
  final double currentRate;
  final Function(double) onRateChanged;

  const RateManagementSection({
    Key? key,
    required this.selectedServiceType,
    required this.currentRate,
    required this.onRateChanged,
  }) : super(key: key);

  @override
  State<RateManagementSection> createState() => _RateManagementSectionState();
}

class _RateManagementSectionState extends State<RateManagementSection> {
  late TextEditingController _rateController;
  bool _isManualOverride = false;

  final Map<String, double> _preloadedRates = {
    'Leather': 75.0,
    'Wood': 65.0,
    'Upholstery': 85.0,
    'Cleaning': 45.0,
  };

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController();
    _updateRateDisplay();
  }

  @override
  void didUpdateWidget(RateManagementSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedServiceType != widget.selectedServiceType) {
      _isManualOverride = false;
      _updateRateDisplay();
    }
  }

  void _updateRateDisplay() {
    final preloadedRate = _preloadedRates[widget.selectedServiceType] ?? 0.0;
    final displayRate = _isManualOverride ? widget.currentRate : preloadedRate;
    _rateController.text = displayRate.toStringAsFixed(2);

    if (!_isManualOverride) {
      widget.onRateChanged(preloadedRate);
    }
  }

  void _toggleManualOverride() {
    setState(() {
      _isManualOverride = !_isManualOverride;
      if (!_isManualOverride) {
        _updateRateDisplay();
      }
    });
  }

  void _onRateTextChanged(String value) {
    if (_isManualOverride && value.isNotEmpty) {
      final rate = double.tryParse(value) ?? 0.0;
      widget.onRateChanged(rate);
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
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
              'Service Rate',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _toggleManualOverride,
              icon: CustomIconWidget(
                iconName: _isManualOverride ? 'lock_open' : 'edit',
                color: AppTheme.lightTheme.primaryColor,
                size: 4.w,
              ),
              label: Text(
                _isManualOverride ? 'Use Preset' : 'Manual',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: _isManualOverride
                ? AppTheme.lightTheme.colorScheme.surface
                : AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isManualOverride
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'attach_money',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      enabled: _isManualOverride,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onChanged: _onRateTextChanged,
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _isManualOverride
                            ? AppTheme.lightTheme.colorScheme.onSurface
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'USD/hour',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              if (!_isManualOverride &&
                  widget.selectedServiceType.isNotEmpty) ...[
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'info_outline',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Preset rate for ${widget.selectedServiceType}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
