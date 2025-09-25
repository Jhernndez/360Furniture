import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';

class CustomerDetailsWidget extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final bool isEditing;
  final void Function(String field, dynamic value) onChanged;

  const CustomerDetailsWidget({
    super.key,
    required this.orderData,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  State<CustomerDetailsWidget> createState() => _CustomerDetailsWidgetState();
}

class _CustomerDetailsWidgetState extends State<CustomerDetailsWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.orderData['customerName'] as String? ?? '');
    _phoneController = TextEditingController(
        text: widget.orderData['customerPhone'] as String? ?? '');
    _addressController = TextEditingController(
        text: widget.orderData['customerAddress'] as String? ?? '');
  }

  @override
  void didUpdateWidget(CustomerDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orderData['customerName'] !=
        oldWidget.orderData['customerName']) {
      _nameController.text = widget.orderData['customerName'] as String? ?? '';
    }
    if (widget.orderData['customerPhone'] !=
        oldWidget.orderData['customerPhone']) {
      _phoneController.text =
          widget.orderData['customerPhone'] as String? ?? '';
    }
    if (widget.orderData['customerAddress'] !=
        oldWidget.orderData['customerAddress']) {
      _addressController.text =
          widget.orderData['customerAddress'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _openMaps(String address) async {
    final Uri mapsUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      query: address,
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.orderData['customerName'] as String? ?? '';
    final customerPhone = widget.orderData['customerPhone'] as String? ?? '';
    final customerAddress =
        widget.orderData['customerAddress'] as String? ?? '';

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
          Text(
            'Detalles del Cliente',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          widget.isEditing
              ? TextField(
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                  controller: _nameController,
                  onChanged: (val) => widget.onChanged('customerName', val),
                )
              : _buildDetailRow('Nombre', customerName, 'person', null),
          SizedBox(height: 2.h),
          widget.isEditing
              ? TextField(
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  onChanged: (val) => widget.onChanged('customerPhone', val),
                )
              : _buildDetailRow('Teléfono', customerPhone, 'phone',
                  () => _makePhoneCall(customerPhone)),
          SizedBox(height: 2.h),
          widget.isEditing
              ? TextField(
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  controller: _addressController,
                  onChanged: (val) => widget.onChanged('customerAddress', val),
                )
              : _buildDetailRow('Dirección', customerAddress, 'location_on',
                  () => _openMaps(customerAddress)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    String iconName,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        decoration: onTap != null
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: onTap != null
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : AppTheme.textSecondaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: onTap != null
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.textSecondaryLight,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    value.isNotEmpty ? value : 'No especificado',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: value.isNotEmpty
                          ? AppTheme.textPrimaryLight
                          : AppTheme.textDisabledLight,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
