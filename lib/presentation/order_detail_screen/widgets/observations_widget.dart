import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class ObservationsWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isEditing;
  final void Function(String field, dynamic value) onChanged;

  const ObservationsWidget({
    super.key,
    required this.data,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  State<ObservationsWidget> createState() => _ObservationsWidgetState();
}

class _ObservationsWidgetState extends State<ObservationsWidget> {
  bool _isExpanded = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.data['observations'] as String? ?? '');
  }

  @override
  void didUpdateWidget(covariant ObservationsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data['observations'] != oldWidget.data['observations']) {
      _controller.text = widget.data['observations'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observations = widget.data['observations'] as String? ?? '';

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
            children: [
              CustomIconWidget(
                iconName: 'note_alt',
                color: AppTheme.textSecondaryLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Observaciones',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          widget.isEditing
              ? TextField(
                  decoration: InputDecoration(
                    labelText: 'Observaciones',
                    prefixIcon: Icon(Icons.note_alt),
                  ),
                  maxLines: 4,
                  controller: _controller,
                  onChanged: (val) => widget.onChanged('observations', val),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                )
              : observations.isEmpty
                  ? Text(
                      'Sin observaciones.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: AnimatedCrossFade(
                        firstChild: Text(
                          observations,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                        secondChild: Text(
                          observations,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ),
          if (!widget.isEditing && observations.length > 80)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(_isExpanded ? 'Ver menos' : 'Ver más'),
              ),
            ),
        ],
      ),
    );
  }
}
