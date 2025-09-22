import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';

class CustomerDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final bool isEditing;
  final void Function(String field, dynamic value) onChanged;

  const CustomerDetailsWidget({
    Key? key,
    required this.orderData,
    required this.isEditing,
    required this.onChanged,
  }) : super(key: key);

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
    final customerName = orderData['customerName'] as String? ?? '';
    final customerPhone = orderData['customerPhone'] as String? ?? '';
    final customerAddress = orderData['customerAddress'] as String? ?? '';

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
          isEditing
              ? TextField(
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                  controller: TextEditingController(text: customerName),
                  onChanged: (val) => onChanged('customerName', val),
                )
              : _buildDetailRow('Nombre', customerName, 'person', null),
          SizedBox(height: 2.h),
          isEditing
              ? TextField(
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  controller: TextEditingController(text: customerPhone),
                  onChanged: (val) => onChanged('customerPhone', val),
                )
              : _buildDetailRow('Teléfono', customerPhone, 'phone',
                  () => _makePhoneCall(customerPhone)),
          SizedBox(height: 2.h),
          isEditing
              ? TextField(
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  controller: TextEditingController(text: customerAddress),
                  onChanged: (val) => onChanged('customerAddress', val),
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
