import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import './widgets/availability_status_widget.dart';
import './widgets/language_settings_widget.dart';
import './widgets/notification_preferences_widget.dart';
import './widgets/performance_metrics_widget.dart';
import './widgets/personal_info_section_widget.dart';
import './widgets/profile_photo_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/service_specializations_widget.dart';
import './widgets/settings_section_widget.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({Key? key}) : super(key: key);

  @override
  State<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasChanges = false;
  bool _isLoading = false;

  UserProfile? _userProfile;

  void _onProfileChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onSave() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text('Are you sure you want to discard your changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) {
        if (_hasChanges && !didPop) {
          _showDiscardDialog();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('Technician Profile'),
          elevation: 2.0,
          shadowColor: AppTheme.shadowLight,
          actions: [
            // Botón de perfil para cerrar sesión
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Sign Out',
              onPressed: () async {
                // Cerrar sesión (si usas Supabase, Firebase, etc. aquí va el signOut)
                // await SupabaseService.instance.client.auth.signOut();
                // Redirigir a login
                if (Navigator.canPop(context)) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
                Navigator.of(context).pushReplacementNamed('/login-screen');
              },
            ),
            if (_hasChanges)
              IconButton(
                onPressed: _isLoading ? null : _onSave,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )
                    : const Icon(Icons.save),
                tooltip: 'Save Changes',
              ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(2.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Profile Photo Section
                    ProfilePhotoWidget(
                      onChanged: _onProfileChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Personal Information
                    PersonalInfoSectionWidget(
                      onChanged: _onProfileChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Service Specializations
                    ServiceSpecializationsWidget(
                      onChanged: _onProfileChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Performance Metrics - Now with real-time data
                    const PerformanceMetricsWidget(),

                    SizedBox(height: 3.h),

                    // Notification Preferences
                    NotificationPreferencesWidget(
                      onChanged: _onProfileChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Language Settings
                    LanguageSettingsWidget(
                      onChanged: _onProfileChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Availability Status
                    AvailabilityStatusWidget(
                      onChanged: _onProfileChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Recent Activity
                    const RecentActivityWidget(),

                    SizedBox(height: 3.h),

                    // Settings Section
                    SettingsSectionWidget(
                      userProfile: _userProfile ??
                          UserProfile(
                            id: '',
                            email: '',
                            fullName: '',
                            role: 'technician',
                            isActive: true,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                      onProfileUpdated: _onProfileChanged,
                    ),

                    SizedBox(height: 10.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton.extended(
                onPressed: _isLoading ? null : _onSave,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Changes'),
                backgroundColor: _isLoading
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
