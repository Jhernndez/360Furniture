import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProcessingStatusWidget extends StatelessWidget {
  final String status;
  final List<String> logs;

  const ProcessingStatusWidget({
    super.key,
    required this.status,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Processing',
                  style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryLight.withAlpha(51)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppTheme.primaryLight, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status,
                      style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Processing logs
            if (logs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Processing Logs:',
                style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: logs
                        .map((log) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                                      color: AppTheme.textSecondaryLight,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      log,
                                      style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                                        color: AppTheme.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Progress indicator
            Row(
              children: [
                Icon(Icons.schedule, color: AppTheme.textSecondaryLight, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Please wait while we process your data...',
                  style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                    color: AppTheme.textSecondaryLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}