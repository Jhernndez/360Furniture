import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CustomerInformationForm extends StatefulWidget {
  final Map<String, String> customerData;
  final Function(Map<String, String>) onCustomerDataChanged;

  const CustomerInformationForm({
    Key? key,
    required this.customerData,
    required this.onCustomerDataChanged,
  }) : super(key: key);

  @override
  State<CustomerInformationForm> createState() =>
      _CustomerInformationFormState();
}

class _CustomerInformationFormState extends State<CustomerInformationForm> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.customerData['name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.customerData['phone'] ?? '');
    _addressController =
        TextEditingController(text: widget.customerData['address'] ?? '');
  }

  void _updateCustomerData(String field, String value) {
    final updatedData = Map<String, String>.from(widget.customerData);
    updatedData[field] = value;
    widget.onCustomerDataChanged(updatedData);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Information',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),

        // Customer Name Field
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => _updateCustomerData('name', value),
          decoration: InputDecoration(
            labelText: 'Customer Name *',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 5.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Customer name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        // Phone Number Field
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
            LengthLimitingTextInputFormatter(15),
          ],
          onChanged: (value) => _updateCustomerData('phone', value),
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'phone',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 5.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: '+34 123 456 789',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            if (value.trim().length < 9) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        // Address Field
        TextFormField(
          controller: _addressController,
          textCapitalization: TextCapitalization.words,
          maxLines: 3,
          onChanged: (value) => _updateCustomerData('address', value),
          decoration: InputDecoration(
            labelText: 'Service Address *',
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: 3.w, left: 3.w, right: 3.w),
              child: CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 5.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Enter complete service address',
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Service address is required';
            }
            return null;
          },
        ),
        SizedBox(height: 1.h),

        // Location Suggestion Helper
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.primaryColor,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Include street, number, floor, and any access details',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
