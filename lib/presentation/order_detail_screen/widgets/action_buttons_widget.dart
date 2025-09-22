import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final VoidCallback onUpdateStatus;
  final VoidCallback onAddPhotos;
  final VoidCallback onGenerateReport;

  const ActionButtonsWidget({
    Key? key,
    required this.orderData,
    required this.onUpdateStatus,
    required this.onAddPhotos,
    required this.onGenerateReport,
  }) : super(key: key);

  Future<void> _shareOrder() async {
    final orderNumber = orderData['orderNumber'] as String? ?? '';
    final customerName = orderData['customerName'] as String? ?? '';
    final serviceType = orderData['serviceType'] as String? ?? '';
    final status = orderData['status'] as String? ?? '';
    final totalAmount = orderData['totalAmount'] as double? ?? 0.0;

    final shareText = '''
📋 Orden de Servicio #$orderNumber

👤 Cliente: $customerName
🔧 Servicio: $serviceType
📊 Estado: $status
💰 Total: \$${totalAmount.toStringAsFixed(2)}

Generado por ServiceTracker Pro
    ''';

    try {
      await Share.share(shareText, subject: 'Orden #$orderNumber');
    } catch (e) {
      debugPrint('Error sharing order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Acciones',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 4.w * 2 - 3.w) / 2,
                child: _buildActionButton(
                  'Actualizar Estado',
                  'update',
                  AppTheme.lightTheme.colorScheme.primary,
                  onUpdateStatus,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 4.w * 2 - 3.w) / 2,
                child: _buildActionButton(
                  'Agregar Fotos',
                  'add_a_photo',
                  AppTheme.successLight,
                  onAddPhotos,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 4.w * 2 - 3.w) / 2,
                child: _buildActionButton(
                  'Compartir Orden',
                  'share',
                  AppTheme.warningLight,
                  _shareOrder,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 4.w * 2 - 3.w) / 2,
                child: _buildActionButton(
                  'Generar Reporte',
                  'description',
                  AppTheme.secondaryLight,
                  onGenerateReport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
