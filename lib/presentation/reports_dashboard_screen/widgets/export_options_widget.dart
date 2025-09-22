import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../services/report_service.dart';

class ExportOptionsWidget extends StatefulWidget {
  final Function(String format, String reportType) onExport;
  final Map<String, dynamic>? reportData;

  const ExportOptionsWidget({
    Key? key,
    required this.onExport,
    this.reportData,
  }) : super(key: key);

  @override
  State<ExportOptionsWidget> createState() => _ExportOptionsWidgetState();
}

class _ExportOptionsWidgetState extends State<ExportOptionsWidget> {
  String _selectedFormat = 'PDF';
  bool _includeCharts = true;
  bool _includeRawData = false;
  bool _compressFile = true;
  bool _isExporting = false;

  final List<ExportFormat> _exportFormats = [
    ExportFormat(
      name: 'PDF',
      description: 'Portable Document Format - Best for sharing',
      icon: Icons.picture_as_pdf,
      color: Colors.red,
      fileSize: '2-5 MB',
      features: ['Charts', 'Formatted Text', 'Print Ready'],
    ),
    ExportFormat(
      name: 'CSV',
      description: 'Comma Separated Values - Lightweight data',
      icon: Icons.description,
      color: Colors.blue,
      fileSize: '100-500 KB',
      features: ['Raw Data Only', 'Universal Format', 'Lightweight'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevatedLight,
        borderRadius: widget.reportData != null
            ? BorderRadius.vertical(top: Radius.circular(20.0))
            : BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize:
            widget.reportData != null ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (widget.reportData != null) ...[
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.only(top: 2.h, bottom: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.textDisabledLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.file_download,
                        color: Colors.orange,
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      widget.reportData != null
                          ? 'Export Report'
                          : 'Export Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                if (widget.reportData != null) ...[
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: AppTheme.primaryLight,
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.reportData!['name'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                '${widget.reportData!['type']} • ${widget.reportData!['size']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                ],
                Text(
                  'Select Export Format',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 2.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _exportFormats.length,
                  itemBuilder: (context, index) {
                    final format = _exportFormats[index];
                    final isSelected = _selectedFormat == format.name;

                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? format.color.withValues(alpha: 0.05)
                            : AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? format.color.withValues(alpha: 0.3)
                              : AppTheme.borderSubtleLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: format.name,
                        groupValue: _selectedFormat,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedFormat = value;
                            });
                          }
                        },
                        title: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: format.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                format.icon,
                                color: format.color,
                                size: 5.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    format.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    format.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryLight,
                                        ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                          vertical: 0.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: format.color
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          format.fileSize,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: format.color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: Wrap(
                                          spacing: 1.w,
                                          children:
                                              format.features.map((feature) {
                                            return Text(
                                              '• $feature',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: AppTheme
                                                        .textSecondaryLight,
                                                  ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.all(2.w),
                      ),
                    );
                  },
                ),
                SizedBox(height: 3.h),
                if (_selectedFormat != 'CSV') ...[
                  Text(
                    'Export Settings',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  _buildSettingsTile(
                    'Include Charts & Graphs',
                    'Visual representations of data',
                    Icons.bar_chart,
                    _includeCharts,
                    (value) => setState(() => _includeCharts = value),
                  ),
                  SizedBox(height: 1.h),
                  _buildSettingsTile(
                    'Include Raw Data',
                    'Detailed numerical data tables',
                    Icons.table_rows,
                    _includeRawData,
                    (value) => setState(() => _includeRawData = value),
                  ),
                  SizedBox(height: 3.h),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _handleRealExport,
                    icon: _isExporting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isExporting
                        ? 'Exporting...'
                        : 'Export as $_selectedFormat'),
                  ),
                ),
                if (widget.reportData != null) ...[
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: value
            ? AppTheme.primaryLight.withValues(alpha: 0.05)
            : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.primaryLight.withValues(alpha: 0.2)
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
        ),
        secondary: Icon(
          icon,
          color: value ? AppTheme.primaryLight : AppTheme.textSecondaryLight,
        ),
        contentPadding: EdgeInsets.all(2.w),
      ),
    );
  }

  // REAL export functionality that actually downloads files
  Future<void> _handleRealExport() async {
    setState(() => _isExporting = true);

    try {
      if (widget.reportData != null) {
        Navigator.pop(context);
      }

      final filters = <String, dynamic>{
        'includeCharts': _includeCharts,
        'includeRawData': _includeRawData,
        'compressFile': _compressFile,
      };

      // Call the real report service to generate and download
      await ReportService.downloadReport(
        reportType: widget.reportData?['type'] ?? 'weekly',
        format: _selectedFormat,
        filters: filters,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report downloaded successfully as $_selectedFormat'),
            backgroundColor: AppTheme.successLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.errorLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}

class ExportFormat {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String fileSize;
  final List<String> features;

  ExportFormat({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.fileSize,
    required this.features,
  });
}
