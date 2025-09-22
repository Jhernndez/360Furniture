import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProfilePhotoWidget extends StatefulWidget {
  final VoidCallback? onChanged;

  const ProfilePhotoWidget({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  String? _selectedImagePath;

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.textDisabledLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Update Profile Photo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppTheme.primaryLight,
                    size: 6.w,
                  ),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () {
                  Navigator.pop(context);
                  _selectFromCamera();
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppTheme.successLight,
                    size: 6.w,
                  ),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectFromGallery();
                },
              ),
              if (_selectedImagePath != null)
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: AppTheme.errorLight,
                      size: 6.w,
                    ),
                  ),
                  title: const Text('Remove Photo'),
                  subtitle: const Text('Use default avatar'),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _selectFromCamera() async {
    // Simulate camera selection
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _selectedImagePath = 'camera_image_path';
    });
    widget.onChanged?.call();
  }

  void _selectFromGallery() async {
    // Simulate gallery selection
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _selectedImagePath = 'gallery_image_path';
    });
    widget.onChanged?.call();
  }

  void _removePhoto() {
    setState(() {
      _selectedImagePath = null;
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.borderSubtleLight,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _selectedImagePath != null
                      ? Container(
                          color: AppTheme.primaryLight.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            size: 15.w,
                            color: AppTheme.primaryLight,
                          ),
                        )
                      : Container(
                          color: AppTheme.backgroundLight,
                          child: Icon(
                            Icons.person_outline,
                            size: 15.w,
                            color: AppTheme.textDisabledLight,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.surfaceLight,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppTheme.onPrimaryLight,
                      size: 5.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Profile Photo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap the camera icon to update',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }
}
