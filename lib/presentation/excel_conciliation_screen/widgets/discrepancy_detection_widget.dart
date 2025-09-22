import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DiscrepancyDetectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> discrepancies;

  const DiscrepancyDetectionWidget({
    super.key,
    required this.discrepancies,
  });

  @override
  State<DiscrepancyDetectionWidget> createState() =>
      _DiscrepancyDetectionWidgetState();
}

class _DiscrepancyDetectionWidgetState
    extends State<DiscrepancyDetectionWidget> {
  Set<int> expandedItems = {};

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
                Icon(Icons.warning, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Discrepancies Detected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.discrepancies.length} issues',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Records with mismatched data are highlighted below. Click to expand details.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),

            const SizedBox(height: 16),

            // Discrepancy list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.discrepancies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final discrepancy = widget.discrepancies[index];
                final isExpanded = expandedItems.contains(index);

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withAlpha(77)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red.withAlpha(13),
                  ),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Order: ${discrepancy['orderId']}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryLight,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            discrepancy['type'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        if (expanded) {
                          expandedItems.add(index);
                        } else {
                          expandedItems.remove(index);
                        }
                      });
                    },
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(5),
                          border: Border(
                            top: BorderSide(color: Colors.red.withAlpha(51)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Excel Value:',
                                '\$${discrepancy['excelValue']}'),
                            const SizedBox(height: 8),
                            _buildDetailRow('System Value:',
                                '\$${discrepancy['systemValue']}'),
                            const SizedBox(height: 8),
                            _buildDetailRow('Difference:',
                                '\$${discrepancy['difference']}'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showResolveDialog(
                                        context, discrepancy),
                                    icon: Icon(Icons.build, size: 16),
                                    label: const Text('Auto-Resolve'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.orange,
                                      side: BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showManualReviewDialog(
                                        context, discrepancy),
                                    icon: Icon(Icons.visibility, size: 16),
                                    label: const Text('Manual Review'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      side: BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  void _showResolveDialog(
      BuildContext context, Map<String, dynamic> discrepancy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Resolve Discrepancy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${discrepancy['orderId']}'),
            const SizedBox(height: 8),
            Text(
                'This will automatically adjust minor differences based on predefined rules.'),
            const SizedBox(height: 8),
            Text('Difference: \$${discrepancy['difference']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Discrepancy auto-resolved')),
              );
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showManualReviewDialog(
      BuildContext context, Map<String, dynamic> discrepancy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${discrepancy['orderId']}'),
            const SizedBox(height: 16),
            Text('Excel Value: \$${discrepancy['excelValue']}'),
            const SizedBox(height: 8),
            Text('System Value: \$${discrepancy['systemValue']}'),
            const SizedBox(height: 8),
            Text('Difference: \$${discrepancy['difference']}'),
            const SizedBox(height: 16),
            const Text('Choose the correct value:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Excel value accepted')),
              );
            },
            child: const Text('Use Excel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('System value accepted')),
              );
            },
            child: const Text('Use System'),
          ),
        ],
      ),
    );
  }
}