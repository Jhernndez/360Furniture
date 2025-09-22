import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/service_request_service.dart';

class StatusManagementWidget extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final Function(String) onStatusChanged;

  const StatusManagementWidget({
    Key? key,
    required this.orderData,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<StatusManagementWidget> createState() => _StatusManagementWidgetState();
}

class _StatusManagementWidgetState extends State<StatusManagementWidget> {
  late String _selectedStatus;
  List<Map<String, dynamic>> _statusOptions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.orderData['status'] as String? ?? 'pending';
    _fetchStatusOptions();
  }

  Future<void> _fetchStatusOptions() async {
    final statuses = await ServiceRequestService.instance.getStatusOptions();
    // Mapeo visual (puedes personalizar los labels e iconos aquí)
    final labelMap = {
      'pending': 'Pendiente',
      'in_progress': 'En Progreso',
      'completed': 'Completado',
      'cancelled': 'Cancelado',
    };
    final iconMap = {
      'pending': 'schedule',
      'in_progress': 'work',
      'completed': 'check_circle',
      'cancelled': 'cancel',
    };
    final colorMap = {
      'pending': AppTheme.secondaryLight,
      'in_progress': AppTheme.warningLight,
      'completed': AppTheme.successLight,
      'cancelled': AppTheme.errorLight,
    };
    setState(() {
      _statusOptions = statuses
          .map((s) => {
                'value': s,
                'label': labelMap[s] ?? s,
                'icon': iconMap[s] ?? 'help',
                'color': colorMap[s] ?? AppTheme.secondaryLight,
              })
          .toList();
      _loading = false;
    });
  }

  Future<void> _showStatusChangeConfirmation(String newStatus) async {
    final statusOption = _statusOptions.firstWhere(
      (option) => option['value'] == newStatus,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.warningLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Confirmar Cambio',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '¿Está seguro de que desea cambiar el estado de la orden a "${statusOption['label']}"?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textSecondaryLight),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusOption['color'] as Color,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _selectedStatus = newStatus;
      });
      widget.onStatusChanged(newStatus);
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
            'Gestión de Estado',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _loading
              ? Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 160,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _statusOptions.length,
                    itemBuilder: (context, index) {
                      final option = _statusOptions[index];
                      final isSelected = _selectedStatus == option['value'];
                      return InkWell(
                        onTap: () {
                          if (!isSelected) {
                            _showStatusChangeConfirmation(
                                option['value'] as String);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (option['color'] as Color)
                                    .withValues(alpha: 0.1)
                                : AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? option['color'] as Color
                                  : AppTheme.borderSubtleLight,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: option['icon'] as String,
                                color: isSelected
                                    ? option['color'] as Color
                                    : AppTheme.textSecondaryLight,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  option['label'] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: isSelected
                                        ? option['color'] as Color
                                        : AppTheme.textSecondaryLight,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                CustomIconWidget(
                                  iconName: 'check',
                                  color: option['color'] as Color,
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
