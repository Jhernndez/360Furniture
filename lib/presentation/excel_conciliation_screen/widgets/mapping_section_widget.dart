import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MappingSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> excelData;
  final Map<String, String> columnMapping;
  final Function(String, String) onMappingUpdate;
  final bool isMappingComplete;

  const MappingSectionWidget({
    super.key,
    required this.excelData,
    required this.columnMapping,
    required this.onMappingUpdate,
    required this.isMappingComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (excelData.isEmpty) return const SizedBox.shrink();

    List<String> excelColumns = excelData.first.keys.toList();
    List<String> systemFields = ['Order ID', 'Amount', 'Date', 'Service Type'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows,
                    color: AppTheme.primaryLight, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Column Mapping',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                ),
                const Spacer(),
                if (isMappingComplete)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Complete',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Match Excel columns to system fields for accurate reconciliation',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),

            const SizedBox(height: 20),

            // Mapping dropdowns
            ...systemFields
                .map((systemField) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight.withAlpha(26),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppTheme.primaryLight.withAlpha(77)),
                              ),
                              child: Text(
                                systemField,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryLight,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.arrow_forward,
                              color: AppTheme.textSecondaryLight),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonFormField<String>(
                                initialValue: columnMapping[systemField],
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  border: InputBorder.none,
                                ),
                                hint: Text(
                                  'Select Excel Column',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: '',
                                    child: Text('-- Select Column --'),
                                  ),
                                  ...excelColumns
                                      .map((column) => DropdownMenuItem(
                                            value: column,
                                            child: Text(
                                              column,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    onMappingUpdate(systemField, value);
                                  }
                                },
                                dropdownColor: Colors.white,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: AppTheme.textSecondaryLight),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),

            // Auto-detection info
            if (columnMapping.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(13),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Auto-detection suggestions applied. Please verify mappings are correct.',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.blue.shade700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
