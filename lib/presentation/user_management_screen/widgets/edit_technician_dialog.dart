import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../services/user_service.dart';
import '../../../models/user_profile.dart';

class EditTechnicianDialog extends StatefulWidget {
  final UserProfile technician;

  const EditTechnicianDialog({
    Key? key,
    required this.technician,
  }) : super(key: key);

  @override
  State<EditTechnicianDialog> createState() => _EditTechnicianDialogState();
}

class _EditTechnicianDialogState extends State<EditTechnicianDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  UserProfile? _currentUser; // Para saber si es auto-edición

  bool _isLoading = false;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.technician.fullName);
    _phoneController =
        TextEditingController(text: widget.technician.phone ?? '');
    _isActive = widget.technician.isActive;
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 90.w,
        constraints: BoxConstraints(maxHeight: 70.h),
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Technician',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Form
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email (Read-only)
                      TextFormField(
                        initialValue: widget.technician.email,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          suffixIcon: Icon(Icons.lock, size: 16),
                        ),
                        enabled: false,
                      ),

                      SizedBox(height: 3.h),

                      // Full Name
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter full name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),

                      SizedBox(height: 3.h),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Optional',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.trim().length < 10) {
                              return 'Phone number must be at least 10 digits';
                            }
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Leave blank to keep current password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Role (Read-only)
                      TextFormField(
                        initialValue: widget.technician.roleDisplay,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                          suffixIcon: Icon(Icons.lock, size: 16),
                        ),
                        enabled: false,
                      ),

                      SizedBox(height: 3.h),

                      // Active Status
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SwitchListTile(
                          title: const Text('Active Status'),
                          subtitle: Text(_isActive
                              ? 'User is active'
                              : 'User is inactive'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          secondary: Icon(
                            _isActive ? Icons.check_circle : Icons.cancel,
                            color: _isActive
                                ? AppTheme.successLight
                                : AppTheme.errorLight,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateTechnician,
                              child: _isLoading
                                  ? SizedBox(
                                      width: 4.w,
                                      height: 4.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Update'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTechnician() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedTechnician = await UserService.updateTechnician(
        id: widget.technician.id,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        isActive: _isActive,
      );

      if (mounted) {
        Navigator.pop(context, updatedTechnician);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        String errorMessage = 'Failed to update technician';

        // Handle specific errors
        if (e.toString().contains('not found')) {
          errorMessage = 'Technician not found';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'You do not have permission to update this technician';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorLight,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
