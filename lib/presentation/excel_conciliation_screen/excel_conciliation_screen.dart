import 'dart:convert';
// ignore: uri_does_not_exist
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// Solo importar universal_html en web
// ignore: uri_does_not_exist
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
  final ServiceRequestService _serviceRequestService =
      ServiceRequestService.instance;

  List<Map<String, dynamic>> _excelData = [];
  List<Map<String, dynamic>> _systemData = [];
  Map<String, String> _columnMapping = {};
  final List<Map<String, dynamic>> _discrepancies = [];
  Map<String, dynamic> _reconciliationSummary = {
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
  final List<String> _processingLogs = [];
  final List<Map<String, dynamic>> _results = [];
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

  Future<List<int>?> _readFileBytes(String? path) async {
    // Solo usar File en plataformas compatibles
    if (path == null) return null;
    try {
      // ignore: avoid_web_libraries_in_flutter
      // import 'dart:io' if (dart.library.io) 'dart:io';
      // File solo existe fuera de web
      // ignore: undefined_class
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
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
            : await _readFileBytes(result.files.first.path);

        if (bytes != null) {
          setState(() {
            _selectedFile = result.files.first.name;
            _isFileImported = true;
          });

          await _parseFileData(bytes, result.files.first.extension ?? '');
        } else if (kIsWeb) {
          _showErrorDialog('No se pudo leer el archivo en Web.');
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

      // Mejorado: buscar línea de headers real y parsear desde ahí
      if (extension == 'csv') {
        String content = utf8.decode(bytes);
        List<String> lines = content.split('\n');
        int headerIndex = -1;
        List<String> headers = [];
        // Buscar la línea que contiene los headers reales
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains('Order Number') &&
              lines[i].contains('Amount')) {
            headerIndex = i;
            headers = lines[i].split(',');
            break;
          }
        }
        if (headerIndex != -1 && headers.isNotEmpty) {
          List<Map<String, dynamic>> data = [];
          for (int i = headerIndex + 1;
              i < lines.length && data.length < 10;
              i++) {
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
        } else {
          _showErrorDialog('No se encontraron headers válidos en el archivo.');
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
      print('[DEBUG] _columnMapping actualizado: $_columnMapping');
      _checkMappingComplete();
    });
  }

  void _checkMappingComplete() {
    // Validar los campos requeridos para la conciliación actual
    final requiredFields = [
      'order_number',
      'technician_name',
      'customer_name',
      'amount',
    ];
    print('[DEBUG] Revisando mapeo. Campos requeridos: $requiredFields');
    print('[DEBUG] Estado actual de _columnMapping: $_columnMapping');
    bool complete = requiredFields.every((field) =>
        _columnMapping.containsKey(field) && _columnMapping[field]!.isNotEmpty);
    print('[DEBUG] ¿Está completo el mapeo? $complete');
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

    // Calcular suma de amounts del archivo Excel
    double excelAmountSum = 0;
    for (final row in _excelData) {
      String amountStr = row[_columnMapping['amount']] ?? '0';
      double excelAmount =
          double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      excelAmountSum += excelAmount;
    }

    // Calcular suma de amounts del sistema
    double systemAmountSum = 0;
    for (final request in _systemData) {
      double systemAmount = (request['amount'] as num?)?.toDouble() ?? 0;
      systemAmountSum += systemAmount;
    }

    setState(() {
      _processingStatus = 'Comparing records...';
    });

    for (int i = 0; i < _excelData.length; i++) {
      Map<String, dynamic> excelRow = _excelData[i];

      // Extraer valores mapeados usando claves en minúsculas
      String orderNumber = excelRow[_columnMapping['order_number']] ?? '';
      String technicianName = excelRow[_columnMapping['technician_name']] ?? '';
      String customerName = excelRow[_columnMapping['customer_name']] ?? '';
      String amountStr = excelRow[_columnMapping['amount']] ?? '0';

      print(
          '[DEBUG] Buscando match para: orderNumber="$orderNumber", technicianName="$technicianName", customerName="$customerName"');
      bool found = false;
      for (final request in _systemData) {
        print(
            '[DEBUG] Comparando con registro sistema: order_number="${request['order_number']}", technician_name="${request['technician_name']}", customer_name="${request['customer_name']}"');
        if ((request['order_number']?.toString().trim() ==
                orderNumber.trim()) &&
            (request['technician_name']?.toString().trim().toLowerCase() ==
                technicianName.trim().toLowerCase()) &&
            (request['customer_name']?.toString().trim().toLowerCase() ==
                customerName.trim().toLowerCase())) {
          found = true;
          double excelAmount =
              double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                  0;
          double systemAmount = (request['amount'] as num?)?.toDouble() ?? 0;
          print(
              '[DEBUG] ¡Match encontrado! excelAmount=$excelAmount, systemAmount=$systemAmount');
          if ((excelAmount - systemAmount).abs() > 0.01) {
            discrepanciesDetected++;
            _discrepancies.add({
              'orderNumber': orderNumber,
              'technicianName': technicianName,
              'customerName': customerName,
              'type': 'Amount Mismatch',
              'excelValue': excelAmount,
              'systemValue': systemAmount,
              'difference': (excelAmount - systemAmount).abs(),
            });
          } else {
            matchesFound++;
            _results.add({
              'orderNumber': orderNumber,
              'technicianName': technicianName,
              'customerName': customerName,
              'status': 'match',
              'details': 'Successfully matched',
            });
          }
          break;
        }
      }
      if (!found) {
        print('[DEBUG] No se encontró match para este registro.');
        missingEntries++;
        _results.add({
          'orderNumber': orderNumber,
          'technicianName': technicianName,
          'customerName': customerName,
          'status': 'missing',
          'details': 'Not found in system',
        });
      }

      setState(() {
        _processingStatus = 'Processing record ${i + 1} of $totalRecords';
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }

    setState(() {
      _reconciliationSummary = {
        'totalRecords': totalRecords,
        'matchesFound': matchesFound,
        'discrepanciesDetected': discrepanciesDetected,
        'missingEntries': missingEntries,
        'amountDifference':
            double.parse((excelAmountSum - systemAmountSum).toStringAsFixed(2)),
      };
    });
  }

  Future<void> _exportDiscrepancies() async {
    if (_discrepancies.isEmpty) {
      _showInfoDialog('No discrepancies to export');
      return;
    }

    try {
      String csvContent =
          'Order Number,Technician Name,Customer Name,Type,Excel Value,System Value,Difference\n';
      for (var discrepancy in _discrepancies) {
        csvContent +=
            '${discrepancy['orderNumber']},${discrepancy['technicianName']},${discrepancy['customerName']},${discrepancy['type']},${discrepancy['excelValue']},${discrepancy['systemValue']},${discrepancy['difference']}\n';
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
        // Solo en web: usar universal_html
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // En otras plataformas, mostrar mensaje de no disponible
        _showErrorDialog('Descarga solo disponible en la versión web.');
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
