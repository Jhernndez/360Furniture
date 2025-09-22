import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GreetingHeader extends StatelessWidget {
  final String technicianName;
  final DateTime currentDate;
  final VoidCallback? onProfileTap;

  const GreetingHeader({
    Key? key,
    required this.technicianName,
    required this.currentDate,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String greeting = _getGreeting();
    final String formattedDate =
        '${currentDate.day}/${currentDate.month}/${currentDate.year}';
    // Hora local de USA (Eastern Time por defecto)
    final usaTime = currentDate.toUtc().add(const Duration(hours: -4));
    final hour = usaTime.hour % 12 == 0 ? 12 : usaTime.hour % 12;
    final minute = usaTime.minute.toString().padLeft(2, '0');
    final ampm = usaTime.hour < 12 ? 'a.m.' : 'p.m.';
    final formattedTime = '$hour:$minute $ampm';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$greeting, ',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        technicianName,
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'calendar_today',
                      color: AppTheme.textSecondaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      formattedDate,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.access_time,
                        color: AppTheme.textSecondaryLight, size: 16),
                    SizedBox(width: 1.w),
                    Text(
                      formattedTime,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                icon: Icon(Icons.logout, color: AppTheme.errorLight, size: 24),
                tooltip: 'Cerrar sesión',
                onPressed: () async {
                  // Aquí va la lógica de logout (ejemplo para Supabase)
                  // await SupabaseService.instance.client.auth.signOut();
                  Navigator.of(context).pushReplacementNamed('/login-screen');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
