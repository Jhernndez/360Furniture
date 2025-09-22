import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FileImportWidget extends StatelessWidget {
  final bool isFileImported;
  final String? selectedFile;
  final VoidCallback onSelectFile;

  const FileImportWidget({
    super.key,
    required this.isFileImported,
    this.selectedFile,
    required this.onSelectFile,
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
                Icon(Icons.upload_file, color: AppTheme.primaryLight, size: 24),
                const SizedBox(width: 8),
                Text(
                  'File Import',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Drag-drop zone
            GestureDetector(
              onTap: onSelectFile,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isFileImported ? Colors.green : AppTheme.primaryLight,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isFileImported
                      ? Colors.green.withAlpha(13)
                      : AppTheme.primaryLight.withAlpha(13),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFileImported ? Icons.check_circle : Icons.cloud_upload,
                      size: 40,
                      color:
                          isFileImported ? Colors.green : AppTheme.primaryLight,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isFileImported
                          ? 'File imported successfully!'
                          : 'Drag and drop your Excel file here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isFileImported
                            ? Colors.green
                            : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (selectedFile != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        selectedFile!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'or click to browse',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Select File Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSelectFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Select File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryLight,
                  side: BorderSide(color: AppTheme.primaryLight),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Supported formats info
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: AppTheme.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  'Supported formats: .xlsx, .csv',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
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