import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ReconciliationSummaryWidget extends StatelessWidget {
  final Map<String, int> summary;

  const ReconciliationSummaryWidget({
    super.key,
    required this.summary,
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
                Icon(Icons.summarize, color: AppTheme.primaryLight, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Reconciliation Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildSummaryCard(
                  'Total Records',
                  '${summary['totalRecords']}',
                  Icons.list_alt,
                  AppTheme.primaryLight,
                ),
                _buildSummaryCard(
                  'Matches Found',
                  '${summary['matchesFound']}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Discrepancies',
                  '${summary['discrepanciesDetected']}',
                  Icons.warning,
                  Colors.red,
                ),
                _buildSummaryCard(
                  'Missing Entries',
                  '${summary['missingEntries']}',
                  Icons.error,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reconciliation Progress',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '${_getSuccessRate()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getSuccessRateColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _getSuccessRate() / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_getSuccessRateColor()),
                  minHeight: 8,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Success Rate:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                      Text(
                        '${_getSuccessRate()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getSuccessRateColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Issues to Review:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                      Text(
                        '${(summary['discrepanciesDetected'] ?? 0) + (summary['missingEntries'] ?? 0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha(77)),
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha(13),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getSuccessRate() {
    int totalRecords = summary['totalRecords'] ?? 1;
    int matchesFound = summary['matchesFound'] ?? 0;
    return totalRecords == 0
        ? 0
        : ((matchesFound / totalRecords) * 100).round();
  }

  Color _getSuccessRateColor() {
    int successRate = _getSuccessRate();
    if (successRate >= 80) return Colors.green;
    if (successRate >= 60) return Colors.orange;
    return Colors.red;
  }
}