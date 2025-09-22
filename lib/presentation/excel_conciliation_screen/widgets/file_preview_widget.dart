import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilePreviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> excelData;

  const FilePreviewWidget({
    super.key,
    required this.excelData,
  });

  @override
  Widget build(BuildContext context) {
    if (excelData.isEmpty) return const SizedBox.shrink();

    List<String> headers = excelData.first.keys.toList();

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
                Icon(Icons.preview, color: AppTheme.primaryLight, size: 24),
                const SizedBox(width: 8),
                Text(
                  'File Preview',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${excelData.length} rows',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scrollable table
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: WidgetStateColor.resolveWith(
                      (states) => AppTheme.primaryLight.withAlpha(26),
                    ),
                    columns: headers
                        .map((header) => DataColumn(
                              label: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 150),
                                child: Text(
                                  header,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ))
                        .toList(),
                    rows: excelData
                        .take(5)
                        .map((row) => DataRow(
                              cells: headers
                                  .map((header) => DataCell(
                                        Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 150),
                                          child: Text(
                                            row[header]?.toString() ?? '',
                                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                              color: AppTheme.textPrimaryLight,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Showing first 5 rows for verification',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppTheme.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}