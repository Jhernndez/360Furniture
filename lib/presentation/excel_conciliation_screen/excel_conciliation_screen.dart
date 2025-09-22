import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../services/service_request_service.dart';
import '../../theme/app_theme.dart';
import './widgets/discrepancy_detection_widget.dart';
import './widgets/file_import_widget.dart';
import './widgets/file_preview_widget.dart';
import './widgets/mapping_section_widget.dart';
import './widgets/processing_status_widget.dart';
import './widgets/reconciliation_summary_widget.dart';
import './widgets/results_section_widget.dart';

class ExcelConciliationScreen extends StatefulWidget {
  const ExcelConciliationScreen({super.key});

  @override
  State<ExcelConciliationScreen> createState() =>
      _ExcelConciliationScreenState();
}

class _ExcelConciliationScreenState extends State<ExcelConciliationScreen> {
  final ServiceRequestService _serviceRequestService = ServiceRequestService.instance;

  List<Map<String, dynamic>> _excelData = [];
  List<Map<String, dynamic>> _systemData = [];
  Map<String, String> _columnMapping = {};
  List<Map<String, dynamic>> _discrepancies = [];
  Map<String, int> _reconciliationSummary = {
    'totalRecords': 0,
    'matchesFound': 0,
    'discrepanciesDetected': 0,
    'missingEntries': 0,
  };
  bool _isProcessing = false;
  bool _isFileImported = false;
  bool _isMappingComplete = false;
  bool _isReconciliationComplete = false;
  String _processingStatus = '';
  List<String> _processingLogs = [];
  List<Map<String, dynamic>> _results = [];
  String? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadSystemData();
  }

  Future<void> _loadSystemData() async {
    try {
      final data = await _serviceRequestService.getAllServiceRequests();
      setState(() {
        _systemData = data;
      });
    } catch (e) {
      _showErrorDialog('Failed to load system data: $e');
    }
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result != null) {
        final bytes = kIsWeb
            ? result.files.first.bytes
            : await File(result.files.first.path!).readAsBytes();

        if (bytes != null) {
          setState(() {
            _selectedFile = result.files.first.name;
            _isFileImported = true;
          });

          await _parseFileData(bytes, result.files.first.extension ?? '');
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to select file: $e');
    }
  }

  Future<void> _parseFileData(List<int> bytes, String extension) async {
    try {
      setState(() {
        _isProcessing = true;
        _processingStatus = 'Parsing file data...';
      });

      // Simulate CSV parsing (in real app, use csv package)
      if (extension == 'csv') {
        String content = utf8.decode(bytes);
        List<String> lines = content.split('\n');
        if (lines.isNotEmpty) {
          List<String> headers = lines[0].split(',');
          List<Map<String, dynamic>> data = [];

          for (int i = 1; i < lines.length && i < 11; i++) {
            // Limit preview to 10 rows
            if (lines[i].trim().isNotEmpty) {
              List<String> values = lines[i].split(',');
              Map<String, dynamic> row = {};
              for (int j = 0; j < headers.length && j < values.length; j++) {
                row[headers[j].trim()] = values[j].trim();
              }
              data.add(row);
            }
          }

          setState(() {
            _excelData = data;
            _autoDetectMapping();
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to parse file: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _autoDetectMapping() {
    if (_excelData.isEmpty) return;

    Map<String, String> autoMapping = {};
    List<String> excelColumns = _excelData.first.keys.toList();

    // Auto-detect based on common column names
    for (String column in excelColumns) {
      String lowerColumn = column.toLowerCase();
      if (lowerColumn.contains('id') || lowerColumn.contains('order')) {
        autoMapping['Order ID'] = column;
      } else if (lowerColumn.contains('amount') ||
          lowerColumn.contains('cost') ||
          lowerColumn.contains('total')) {
        autoMapping['Amount'] = column;
      } else if (lowerColumn.contains('date') ||
          lowerColumn.contains('scheduled')) {
        autoMapping['Date'] = column;
      } else if (lowerColumn.contains('service') ||
          lowerColumn.contains('type')) {
        autoMapping['Service Type'] = column;
      }
    }

    setState(() {
      _columnMapping = autoMapping;
    });
  }

  void _updateColumnMapping(String systemField, String excelColumn) {
    setState(() {
      _columnMapping[systemField] = excelColumn;
      _checkMappingComplete();
    });
  }

  void _checkMappingComplete() {
    bool complete = [
      'Order ID',
      'Amount',
      'Date',
      'Service Type'
    ].every((field) =>
        _columnMapping.containsKey(field) && _columnMapping[field]!.isNotEmpty);
    setState(() {
      _isMappingComplete = complete;
    });
  }

  Future<void> _startReconciliation() async {
    if (!_isMappingComplete) return;

    setState(() {
      _isProcessing = true;
      _processingStatus = 'Starting reconciliation...';
      _processingLogs.clear();
      _discrepancies.clear();
      _results.clear();
    });

    try {
      await _performReconciliation();
    } catch (e) {
      _showErrorDialog('Reconciliation failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _isReconciliationComplete = true;
      });
    }
  }

  Future<void> _performReconciliation() async {
    int totalRecords = _excelData.length;
    int matchesFound = 0;
    int discrepanciesDetected = 0;
    int missingEntries = 0;

    setState(() {
      _processingStatus = 'Comparing records...';
    });

    for (int i = 0; i < _excelData.length; i++) {
      Map<String, dynamic> excelRow = _excelData[i];

      // Extract mapped values
      String orderId = excelRow[_columnMapping['Order ID']] ?? '';
      String amountStr = excelRow[_columnMapping['Amount']] ?? '0';
      String dateStr = excelRow[_columnMapping['Date']] ?? '';
      String serviceTypeStr = excelRow[_columnMapping['Service Type']] ?? '';

      // Find matching system record
      Map<String, dynamic>? matchingRequest =
          _systemData.cast<Map<String, dynamic>?>().firstWhere(
                (request) =>
                    request?['id'] == orderId ||
                    (request?['title']?.toString().contains(orderId) == true),
                orElse: () => null,
              );

      if (matchingRequest != null) {
        // Compare values
        double excelAmount =
            double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        double systemAmount = (matchingRequest['total_cost'] as num?)?.toDouble() ?? 0;

        if ((excelAmount - systemAmount).abs() > 0.01) {
          discrepanciesDetected++;
          _discrepancies.add({
            'orderId': orderId,
            'type': 'Amount Mismatch',
            'excelValue': excelAmount,
            'systemValue': systemAmount,
            'difference': (excelAmount - systemAmount).abs(),
          });
        } else {
          matchesFound++;
          _results.add({
            'orderId': orderId,
            'status': 'match',
            'details': 'Successfully matched',
          });
        }
      } else {
        missingEntries++;
        _results.add({
          'orderId': orderId,
          'status': 'missing',
          'details': 'Not found in system',
        });
      }

      // Update progress
      setState(() {
        _processingStatus = 'Processing record ${i + 1} of $totalRecords';
      });

      // Add small delay for UI updates
      await Future.delayed(const Duration(milliseconds: 50));
    }

    setState(() {
      _reconciliationSummary = {
        'totalRecords': totalRecords,
        'matchesFound': matchesFound,
        'discrepanciesDetected': discrepanciesDetected,
        'missingEntries': missingEntries,
      };
    });
  }

  Future<void> _exportDiscrepancies() async {
    if (_discrepancies.isEmpty) {
      _showInfoDialog('No discrepancies to export');
      return;
    }

    try {
      String csvContent = 'Order ID,Type,Excel Value,System Value,Difference\n';
      for (var discrepancy in _discrepancies) {
        csvContent +=
            '${discrepancy['orderId']},${discrepancy['type']},${discrepancy['excelValue']},${discrepancy['systemValue']},${discrepancy['difference']}\n';
      }

      await _downloadFile(csvContent,
          'discrepancies_${DateTime.now().millisecondsSinceEpoch}.csv');
      _showInfoDialog('Discrepancies exported successfully');
    } catch (e) {
      _showErrorDialog('Failed to export discrepancies: $e');
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    try {
      if (kIsWeb) {
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
      }
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Conciliation'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          if (_isReconciliationComplete)
            TextButton(
              onPressed: _exportDiscrepancies,
              child:
                  const Text('Export', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Import Section
              FileImportWidget(
                isFileImported: _isFileImported,
                selectedFile: _selectedFile,
                onSelectFile: _selectFile,
              ),

              if (_isFileImported) ...[
                const SizedBox(height: 24),

                // File Preview
                FilePreviewWidget(
                  excelData: _excelData,
                ),

                const SizedBox(height: 24),

                // Mapping Section
                MappingSectionWidget(
                  excelData: _excelData,
                  columnMapping: _columnMapping,
                  onMappingUpdate: _updateColumnMapping,
                  isMappingComplete: _isMappingComplete,
                ),

                const SizedBox(height: 24),

                // Start Reconciliation Button
                if (_isMappingComplete && !_isProcessing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startReconciliation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Start Reconciliation'),
                    ),
                  ),
              ],

              // Processing Status
              if (_isProcessing) ...[
                const SizedBox(height: 24),
                ProcessingStatusWidget(
                  status: _processingStatus,
                  logs: _processingLogs,
                ),
              ],

              // Discrepancy Detection
              if (_discrepancies.isNotEmpty) ...[
                const SizedBox(height: 24),
                DiscrepancyDetectionWidget(
                  discrepancies: _discrepancies,
                ),
              ],

              // Reconciliation Summary
              if (_isReconciliationComplete) ...[
                const SizedBox(height: 24),
                ReconciliationSummaryWidget(
                  summary: _reconciliationSummary,
                ),

                const SizedBox(height: 24),

                // Results Section
                ResultsSectionWidget(
                  results: _results,
                  discrepancies: _discrepancies,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}