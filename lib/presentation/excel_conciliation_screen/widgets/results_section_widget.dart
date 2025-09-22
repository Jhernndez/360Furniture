import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ResultsSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> results;
  final List<Map<String, dynamic>> discrepancies;

  const ResultsSectionWidget({
    super.key,
    required this.results,
    required this.discrepancies,
  });

  @override
  State<ResultsSectionWidget> createState() => _ResultsSectionWidgetState();
}

class _ResultsSectionWidgetState extends State<ResultsSectionWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Set<int> selectedItems = {};
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> successfulMatches =
        widget.results.where((result) => result['status'] == 'match').toList();

    List<Map<String, dynamic>> unresolvedItems = widget.results
        .where((result) => result['status'] == 'missing')
        .toList();

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
                Icon(Icons.analytics, color: AppTheme.primaryLight, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Reconciliation Results',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Results summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResultStat(
                      'Successful', successfulMatches.length, Colors.green),
                  _buildResultStat(
                      'Discrepancies', widget.discrepancies.length, Colors.red),
                  _buildResultStat(
                      'Unresolved', unresolvedItems.length, Colors.orange),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16),
                        const SizedBox(width: 4),
                        Text('Matches'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 16),
                        const SizedBox(width: 4),
                        Text('Issues'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.recommend, size: 16),
                        const SizedBox(width: 4),
                        Text('Actions'),
                      ],
                    ),
                  ),
                ],
                labelColor: AppTheme.primaryLight,
                unselectedLabelColor: AppTheme.textSecondaryLight,
                indicatorColor: AppTheme.primaryLight,
              ),
            ),

            const SizedBox(height: 16),

            // Tab content
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Successful matches tab
                  _buildMatchesList(successfulMatches),

                  // Issues tab
                  _buildIssuesList(unresolvedItems),

                  // Recommended actions tab
                  _buildActionsTab(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: selectedItems.isNotEmpty ? _bulkResolve : null,
                    icon: Icon(Icons.auto_fix_high, size: 16),
                    label: Text('Bulk Resolve (${selectedItems.length})'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateReport,
                    icon: Icon(Icons.download, size: 16),
                    label: const Text('Export Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesList(List<Map<String, dynamic>> matches) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppTheme.textSecondaryLight),
            const SizedBox(height: 16),
            Text(
              'No successful matches found',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text(match['orderId']),
          subtitle: Text(match['details']),
          trailing: Icon(Icons.verified, color: Colors.green, size: 20),
        );
      },
    );
  }

  Widget _buildIssuesList(List<Map<String, dynamic>> issues) {
    if (issues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'No unresolved issues',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Select all checkbox
        CheckboxListTile(
          title: Text('Select All'),
          value: selectAll,
          onChanged: (value) {
            setState(() {
              selectAll = value ?? false;
              if (selectAll) {
                selectedItems =
                    Set.from(List.generate(issues.length, (i) => i));
              } else {
                selectedItems.clear();
              }
            });
          },
        ),
        Divider(),

        // Issues list
        Expanded(
          child: ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              bool isSelected = selectedItems.contains(index);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedItems.add(index);
                    } else {
                      selectedItems.remove(index);
                    }
                    selectAll = selectedItems.length == issues.length;
                  });
                },
                title: Text(issue['orderId']),
                subtitle: Text(issue['details']),
                secondary: Icon(Icons.error_outline, color: Colors.orange),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Actions',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            'Review Discrepancies',
            'Manually review ${widget.discrepancies.length} discrepancies for accuracy',
            Icons.help_outline,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Update System Records',
            'Update system with verified Excel data where appropriate',
            Icons.system_update_alt,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Generate Audit Report',
            'Create comprehensive report for audit trail and compliance',
            Icons.description,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Schedule Follow-up',
            'Set reminder for regular reconciliation checks',
            Icons.schedule,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha(77)),
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    );
  }

  void _bulkResolve() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Resolve'),
        content: Text('Resolve ${selectedItems.length} selected items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedItems.clear();
                selectAll = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Items resolved successfully')),
              );
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Generating reconciliation report...'),
        action: SnackBarAction(
          label: 'Download',
          onPressed: () {
            // In real app, trigger actual report download
          },
        ),
      ),
    );
  }
}