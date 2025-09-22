import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ObservationsField extends StatefulWidget {
  final String observations;
  final Function(String) onObservationsChanged;

  const ObservationsField({
    Key? key,
    required this.observations,
    required this.onObservationsChanged,
  }) : super(key: key);

  @override
  State<ObservationsField> createState() => _ObservationsFieldState();
}

class _ObservationsFieldState extends State<ObservationsField> {
  late TextEditingController _observationsController;
  late FocusNode _focusNode;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _observationsController = TextEditingController(text: widget.observations);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isExpanded =
            _focusNode.hasFocus || _observationsController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Observations',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Optional',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: TextFormField(
            controller: _observationsController,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.sentences,
            maxLines: _isExpanded ? 5 : 3,
            minLines: _isExpanded ? 3 : 2,
            onChanged: widget.onObservationsChanged,
            decoration: InputDecoration(
              labelText: 'Additional notes or observations',
              hintText:
                  'Describe any special requirements, damage details, or important notes...',
              prefixIcon: Padding(
                padding: EdgeInsets.only(top: 3.w, left: 3.w, right: 3.w),
                child: CustomIconWidget(
                  iconName: 'note_add',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  size: 5.w,
                ),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(top: 2.w, right: 2.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Voice-to-text functionality would be implemented here
                        // For now, we'll show a tooltip
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Voice input feature coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'mic',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 4.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            ),
          ),
        ),
        if (_observationsController.text.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.successLight.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.successLight.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle_outline',
                  color: AppTheme.successLight,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Observations added - ${_observationsController.text.length} characters',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
