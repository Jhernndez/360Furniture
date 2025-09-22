import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../models/user_profile.dart';

class TechnicianCardWidget extends StatelessWidget {
  final UserProfile technician;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewProfile;

  const TechnicianCardWidget({
    Key? key,
    required this.technician,
    required this.onEdit,
    required this.onDelete,
    required this.onViewProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Content
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: technician.isActive
                      ? AppTheme.primaryLight.withValues(alpha: 0.1)
                      : AppTheme.textDisabledLight.withValues(alpha: 0.1),
                  child: Text(
                    technician.fullName.isNotEmpty
                        ? technician.fullName.substring(0, 1).toUpperCase()
                        : 'T',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: technician.isActive
                              ? AppTheme.primaryLight
                              : AppTheme.textDisabledLight,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(width: 4.w),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        technician.fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        technician.roleDisplay,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: technician.isActive
                                  ? AppTheme.primaryLight
                                  : AppTheme.textDisabledLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        technician.role,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: technician.isActive
                                  ? AppTheme.primaryLight
                                  : AppTheme.textDisabledLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        technician.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: technician.isActive
                                  ? AppTheme.textSecondaryLight
                                  : AppTheme.textDisabledLight,
                            ),
                      ),
                      if (technician.phone?.isNotEmpty == true) ...[
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: technician.isActive
                                  ? AppTheme.textSecondaryLight
                                  : AppTheme.textDisabledLight,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              technician.phone!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: technician.isActive
                                        ? AppTheme.textSecondaryLight
                                        : AppTheme.textDisabledLight,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions Menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        onViewProfile();
                        break;
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('View Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: AppTheme.errorLight,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppTheme.errorLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}