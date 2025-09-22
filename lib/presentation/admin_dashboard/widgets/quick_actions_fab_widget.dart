import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsFabWidget extends StatefulWidget {
  final VoidCallback onAddTechnician;
  final VoidCallback onGenerateReport;
  final VoidCallback onExportData;

  const QuickActionsFabWidget({
    Key? key,
    required this.onAddTechnician,
    required this.onGenerateReport,
    required this.onExportData,
  }) : super(key: key);

  @override
  State<QuickActionsFabWidget> createState() => _QuickActionsFabWidgetState();
}

class _QuickActionsFabWidgetState extends State<QuickActionsFabWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _expandAnimation.value,
              child: Opacity(
                opacity: _expandAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      icon: 'person_add',
                      label: 'Add Technician',
                      onPressed: () {
                        _toggleExpanded();
                        widget.onAddTechnician();
                      },
                    ),
                    SizedBox(height: 1.h),
                    _buildActionButton(
                      icon: 'assessment',
                      label: 'Generate Report',
                      onPressed: () {
                        _toggleExpanded();
                        widget.onGenerateReport();
                      },
                    ),
                    SizedBox(height: 1.h),
                    _buildActionButton(
                      icon: 'file_download',
                      label: 'Export Data',
                      onPressed: () {
                        _toggleExpanded();
                        widget.onExportData();
                      },
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            );
          },
        ),
        FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: AppTheme.primaryLight,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: CustomIconWidget(
              iconName: _isExpanded ? 'close' : 'add',
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        FloatingActionButton.small(
          onPressed: onPressed,
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          elevation: 4,
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.primaryLight,
            size: 20,
          ),
        ),
      ],
    );
  }
}
