import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onEdit;
  final VoidCallback? onComplete;
  final VoidCallback? onAddNotes;
  final VoidCallback? onStatusChange;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const OrderCard({
    Key? key,
    required this.order,
    this.onEdit,
    this.onComplete,
    this.onAddNotes,
    this.onStatusChange,
    this.onDuplicate,
    this.onShare,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String id = order['id']?.toString() ?? '';
    final String orderNumber = order['order_number'] != null
        ? order['order_number'].toString()
        : (order['orderNumber'] != null ? order['orderNumber'].toString() : '');
    final String description = order['description'] ??
        order['service_type'] ??
        order['serviceType'] ??
        '';
    final String serviceType =
        order['service_type'] ?? order['serviceType'] ?? '';
    final String status = order['status'] ?? '';
    final double amount = (order['total_cost'] as num?)?.toDouble() ??
        (order['amount'] as num?)?.toDouble() ??
        0.0;
    final DateTime? createdAt = order['created_at'] != null
        ? DateTime.tryParse(order['created_at'].toString())
        : (order['createdAt'] as DateTime?);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            SlidableAction(
              onPressed: (_) => onComplete?.call(),
              backgroundColor: AppTheme.successLight,
              foregroundColor: Colors.white,
              icon: Icons.check,
              label: 'Complete',
            ),
            SlidableAction(
              onPressed: (_) => onAddNotes?.call(),
              backgroundColor: AppTheme.warningLight,
              foregroundColor: Colors.white,
              icon: Icons.note_add,
              label: 'Notes',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onStatusChange?.call(),
              backgroundColor: AppTheme.secondaryLight,
              foregroundColor: Colors.white,
              icon: Icons.swap_horiz,
              label: 'Status',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _getServiceIcon(serviceType),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderNumber.isNotEmpty
                                      ? '#$orderNumber'
                                      : 'Sin número',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  description,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Cliente debajo del tipo de servicio
                                if (order['customer_name'] != null &&
                                    order['customer_name']
                                        .toString()
                                        .isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.3.h),
                                    child: Text(
                                      order['customer_name'],
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.textSecondaryLight,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                if (order['customer_name'] == null ||
                                    order['customer_name'].toString().isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.3.h),
                                    child: Text(
                                      'Sin cliente',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.textSecondaryLight,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      createdAt != null
                          ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                          : 'No date',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getServiceIcon(String serviceType) {
    String iconName;
    Color iconColor;

    switch (serviceType.toLowerCase()) {
      case 'leather':
        iconName = 'chair';
        iconColor = AppTheme.warningLight;
        break;
      case 'wood':
        iconName = 'carpenter';
        iconColor = AppTheme.successLight;
        break;
      case 'upholstery':
        iconName = 'weekend';
        iconColor = AppTheme.lightTheme.colorScheme.primary;
        break;
      case 'cleaning':
        iconName = 'cleaning_services';
        iconColor = AppTheme.secondaryLight;
        break;
      default:
        iconName = 'build';
        iconColor = AppTheme.textSecondaryLight;
    }

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomIconWidget(
        iconName: iconName,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'complete':
        backgroundColor = AppTheme.successLight;
        textColor = Colors.white;
        break;
      case 'partial':
        backgroundColor = AppTheme.warningLight;
        textColor = Colors.white;
        break;
      case 'pending':
        backgroundColor = AppTheme.secondaryLight;
        textColor = Colors.white;
        break;
      case 'report':
        backgroundColor = AppTheme.errorLight;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = AppTheme.borderSubtleLight;
        textColor = AppTheme.textSecondaryLight;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtleLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Duplicate Order',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                onDuplicate?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.successLight,
                size: 24,
              ),
              title: Text(
                'Share Order',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            if (order['status']?.toLowerCase() != 'completed')
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.errorLight,
                  size: 24,
                ),
                title: Text(
                  'Delete Order',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.errorLight,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
