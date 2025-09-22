import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ServiceSpecializationsWidget extends StatefulWidget {
  final VoidCallback? onChanged;

  const ServiceSpecializationsWidget({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  @override
  State<ServiceSpecializationsWidget> createState() =>
      _ServiceSpecializationsWidgetState();
}

class _ServiceSpecializationsWidgetState
    extends State<ServiceSpecializationsWidget> {
  final Map<String, ServiceSpecialization> _specializations = {
    'Leather': ServiceSpecialization(
      name: 'Leather',
      icon: Icons.chair,
      isSelected: true,
      skillLevel: SkillLevel.expert,
    ),
    'Wood': ServiceSpecialization(
      name: 'Wood',
      icon: Icons.table_restaurant,
      isSelected: true,
      skillLevel: SkillLevel.advanced,
    ),
    'Upholstery': ServiceSpecialization(
      name: 'Upholstery',
      icon: Icons.weekend,
      isSelected: true,
      skillLevel: SkillLevel.intermediate,
    ),
    'Cleaning': ServiceSpecialization(
      name: 'Cleaning',
      icon: Icons.cleaning_services,
      isSelected: false,
      skillLevel: SkillLevel.beginner,
    ),
  };

  void _toggleSpecialization(String key) {
    setState(() {
      _specializations[key]?.isSelected = !_specializations[key]!.isSelected;
    });
    widget.onChanged?.call();
  }

  void _updateSkillLevel(String key, SkillLevel level) {
    setState(() {
      _specializations[key]?.skillLevel = level;
    });
    widget.onChanged?.call();
  }

  Color _getSkillLevelColor(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return AppTheme.warningLight;
      case SkillLevel.intermediate:
        return Colors.blue;
      case SkillLevel.advanced:
        return AppTheme.successLight;
      case SkillLevel.expert:
        return Colors.purple;
    }
  }

  String _getSkillLevelText(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
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
                    color: AppTheme.successLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.build,
                    color: AppTheme.successLight,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Service Specializations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Select your areas of expertise and skill level',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
            SizedBox(height: 3.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _specializations.length,
              itemBuilder: (context, index) {
                final entry = _specializations.entries.elementAt(index);
                final specialization = entry.value;

                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: specialization.isSelected
                        ? AppTheme.primaryLight.withValues(alpha: 0.05)
                        : AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: specialization.isSelected
                          ? AppTheme.primaryLight.withValues(alpha: 0.3)
                          : AppTheme.borderSubtleLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: specialization.isSelected
                                ? AppTheme.primaryLight.withValues(alpha: 0.1)
                                : AppTheme.textDisabledLight
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            specialization.icon,
                            color: specialization.isSelected
                                ? AppTheme.primaryLight
                                : AppTheme.textDisabledLight,
                            size: 6.w,
                          ),
                        ),
                        title: Text(
                          specialization.name,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        trailing: Switch(
                          value: specialization.isSelected,
                          onChanged: (bool value) {
                            _toggleSpecialization(entry.key);
                          },
                        ),
                      ),
                      if (specialization.isSelected) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Skill Level:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getSkillLevelColor(
                                              specialization.skillLevel)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getSkillLevelColor(
                                                specialization.skillLevel)
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      _getSkillLevelText(
                                          specialization.skillLevel),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _getSkillLevelColor(
                                                specialization.skillLevel),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: SkillLevel.values.map((level) {
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          _updateSkillLevel(entry.key, level),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 1.w),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color:
                                              specialization.skillLevel == level
                                                  ? _getSkillLevelColor(level)
                                                  : AppTheme.borderSubtleLight,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getSkillLevelText(level)
                                                .substring(0, 3),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: specialization
                                                              .skillLevel ==
                                                          level
                                                      ? Colors.white
                                                      : AppTheme
                                                          .textSecondaryLight,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10.sp,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum SkillLevel { beginner, intermediate, advanced, expert }

class ServiceSpecialization {
  final String name;
  final IconData icon;
  bool isSelected;
  SkillLevel skillLevel;

  ServiceSpecialization({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.skillLevel,
  });
}
