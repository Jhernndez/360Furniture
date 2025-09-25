import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// Solo importar universal_html en web
// ignore: uri_does_not_exist
import 'package:universal_html/html.dart' as html;
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Generate and download reports with actual file creation
  static Future<void> downloadReport({
    required String reportType,
    required String format,
    required Map<String, dynamic> filters,
  }) async {
    try {
      // Get real data from database
      final reportData = await _generateReportData(reportType, filters);

      switch (format.toUpperCase()) {
        case 'PDF':
          await _generatePdfReport(reportData, reportType);
          break;
        case 'EXCEL':
          await _generateCsvReport(
              reportData, reportType); // CSV as Excel alternative
          break;
        case 'CSV':
          await _generateCsvReport(reportData, reportType);
          break;
        default:
          throw Exception('Unsupported format: $format');
      }
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  // Generate actual report data from Supabase
  static Future<Map<String, dynamic>> _generateReportData(
    String reportType,
    Map<String, dynamic> filters,
  ) async {
    try {
      Map<String, dynamic> reportData = {};

      switch (reportType.toLowerCase()) {
        case 'summary orders':
          {
            // ...existing code...
            var query = _supabase.from('service_requests').select(
                'order_number, duration, status, updated_at, customer_name, service_type, observations, user_profiles!technician_id(full_name)');
            if (filters['status'] != null) {
              query = query.eq('status', filters['status']);
            }
            final serviceRequests = await query;
            reportData = {
              'title': 'SUMMARY ORDERS',
              'serviceRequests': serviceRequests,
              'summary': _calculateSummary(serviceRequests),
              'generatedAt': DateTime.now().toIso8601String(),
            };
            break;
          }
        case 'summary payments':
          {
            // Fetch order_number, technician_name, customer_name, amount
            var query = _supabase.from('service_requests').select(
                'order_number, amount, customer_name, user_profiles!technician_id(full_name)');
            if (filters['status'] != null) {
              query = query.eq('status', filters['status']);
            }
            final serviceRequests = await query;
            reportData = {
              'title': 'SUMMARY PAYMENTS',
              'serviceRequests': serviceRequests,
              'generatedAt': DateTime.now().toIso8601String(),
            };
            break;
          }
        case 'weekly':
        case 'monthly':
          {
            // Use user-selected date range if provided
            String? start;
            String? end;
            if (filters['start'] != null && filters['end'] != null) {
              start = filters['start'];
              end = filters['end'];
            } else {
              start = _getDateRange(reportType)['start'];
              end = _getDateRange(reportType)['end'];
            }
            var query = _supabase
                .from('service_requests')
                .select('*, customers(*)')
                .gte('updated_at', start!)
                .lte('updated_at', end!);
            if (filters['status'] != null) {
              query = query.eq('status', filters['status']);
            }
            final serviceRequests = await query;
            reportData = {
              'title': '${reportType.toUpperCase()} Performance Report',
              'period': {'start': start, 'end': end},
              'serviceRequests': serviceRequests,
              'summary': _calculateSummary(serviceRequests),
              'generatedAt': DateTime.now().toIso8601String(),
            };
            break;
          }

        case 'technician':
          // Get technician performance data
          final technicians = await _supabase
              .from('users')
              .select('*')
              .eq('role', 'technician');

          final performance = <Map<String, dynamic>>[];
          for (final tech in technicians) {
            final orders = await _supabase
                .from('service_requests')
                .select('*')
                .eq('technician_id', tech['id']);

            performance.add({
              'technician': tech,
              'totalOrders': orders.length,
              'completedOrders':
                  orders.where((o) => o['status'] == 'completed').length,
              'completionRate': orders.isNotEmpty
                  ? (orders.where((o) => o['status'] == 'completed').length /
                      orders.length *
                      100)
                  : 0.0,
            });
          }

          reportData = {
            'title': 'Technician Performance Report',
            'technicians': performance,
            'generatedAt': DateTime.now().toIso8601String(),
          };
          break;

        case 'revenue':
          final revenueData = await _supabase
              .from('service_requests')
              .select('service_type, total_amount, updated_at')
              .not('total_amount', 'is', null);

          final revenueByService = <String, double>{};
          for (final request in revenueData) {
            final serviceType = request['service_type'] ?? 'Unknown';
            final amount = (request['total_amount'] as num?)?.toDouble() ?? 0.0;
            revenueByService[serviceType] =
                (revenueByService[serviceType] ?? 0.0) + amount;
          }

          reportData = {
            'title': 'Revenue Report',
            'revenueByService': revenueByService,
            'totalRevenue': revenueByService.values
                .fold(0.0, (sum, amount) => sum + amount),
            'generatedAt': DateTime.now().toIso8601String(),
          };
          break;

        default:
          throw Exception('Unknown report type: $reportType');
      }

      return reportData;
    } catch (e) {
      throw Exception('Failed to generate report data: $e');
    }
  }

  // Generate PDF report with actual content
  static Future<void> _generatePdfReport(
    Map<String, dynamic> data,
    String reportType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                data['title'] ?? 'ServiceTracker Pro Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated: ${DateTime.now().toString()}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            ..._buildPdfContent(data, reportType),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName =
        '${data['title']?.toString().replaceAll(' ', '_') ?? 'report'}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    await _downloadFile(bytes, fileName);
  }

  // Generate CSV report with actual data
  static Future<void> _generateCsvReport(
    Map<String, dynamic> data,
    String reportType,
  ) async {
    final csvContent = _generateCsvContent(data, reportType);
    final bytes = utf8.encode(csvContent);
    final fileName =
        '${data['title']?.toString().replaceAll(' ', '_') ?? 'report'}_${DateTime.now().millisecondsSinceEpoch}.csv';

    await _downloadFile(bytes, fileName);
  }

  // Platform-specific file download
  static Future<void> _downloadFile(List<int> bytes, String fileName) async {
    if (kIsWeb) {
      // Solo en web: usar universal_html
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // En otras plataformas, mostrar mensaje de no disponible
      throw Exception('Descarga solo disponible en la versión web.');
    }
  }

  // Helper methods
  static Map<String, String> _getDateRange(String reportType) {
    final now = DateTime.now();
    switch (reportType.toLowerCase()) {
      case 'weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return {
          'start': weekStart.toIso8601String(),
          'end': weekStart.add(const Duration(days: 6)).toIso8601String(),
        };
      case 'monthly':
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        return {
          'start': monthStart.toIso8601String(),
          'end': monthEnd.toIso8601String(),
        };
      default:
        return {
          'start': now.subtract(const Duration(days: 7)).toIso8601String(),
          'end': now.toIso8601String(),
        };
    }
  }

  static Map<String, dynamic> _calculateSummary(List<dynamic> serviceRequests) {
    return {
      'totalOrders': serviceRequests.length,
      'completedOrders':
          serviceRequests.where((r) => r['status'] == 'completed').length,
      'pendingOrders':
          serviceRequests.where((r) => r['status'] == 'pending').length,
      'inProgressOrders':
          serviceRequests.where((r) => r['status'] == 'in_progress').length,
    };
  }

  static List<pw.Widget> _buildPdfContent(
      Map<String, dynamic> data, String reportType) {
    final content = <pw.Widget>[];

    if (data['summary'] != null) {
      final summary = data['summary'] as Map<String, dynamic>;
      content.addAll([
        pw.Text('Summary',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Total Orders: ${summary['totalOrders']}'),
        pw.Text('Completed Orders: ${summary['completedOrders']}'),
        pw.Text('Pending Orders: ${summary['pendingOrders']}'),
        pw.Text('In Progress Orders: ${summary['inProgressOrders']}'),
        pw.SizedBox(height: 20),
      ]);
    }

    if (data['technicians'] != null) {
      content.addAll([
        pw.Text('Technician Performance',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
      ]);

      for (final tech in data['technicians']) {
        content.addAll([
          pw.Text(
              '${tech['technician']['full_name']}: ${tech['completionRate'].toStringAsFixed(1)}% completion rate'),
          pw.SizedBox(height: 5),
        ]);
      }
    }

    return content;
  }

  static String _generateCsvContent(
      Map<String, dynamic> data, String reportType) {
    final buffer = StringBuffer();
    buffer.writeln('ServiceTracker Pro Report');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');

    if (data['summary'] != null) {
      final summary = data['summary'] as Map<String, dynamic>;
      buffer.writeln('Summary');
      buffer.writeln('Total Orders,${summary['totalOrders']}');
      buffer.writeln('Completed Orders,${summary['completedOrders']}');
      buffer.writeln('Pending Orders,${summary['pendingOrders']}');
      buffer.writeln('In Progress Orders,${summary['inProgressOrders']}');
      buffer.writeln('');
    }

    if (data['serviceRequests'] != null) {
      buffer.writeln('Service Requests');
      if (data['title'] == 'SUMMARY ORDERS') {
        buffer.writeln(
            'Order Number,Tecnico,Updated At,Status,Customer Name,Service Type,Observations,Duration');
        for (final request in data['serviceRequests']) {
          buffer.writeln('${request['order_number'] ?? ''},'
              '${request['user_profiles'] != null && request['user_profiles']['full_name'] != null ? request['user_profiles']['full_name'] : ''},'
              '${request['updated_at'] ?? ''},'
              '${request['status'] ?? ''},'
              '${request['customer_name'] ?? ''},'
              '${request['service_type'] ?? ''},'
              '${request['observations'] ?? ''},'
              '${request['duration'] ?? ''}');
        }
      } else if (data['title'] == 'SUMMARY PAYMENTS') {
        buffer.writeln('Order Number,Technician Name,Customer Name,Amount');
        for (final request in data['serviceRequests']) {
          buffer.writeln('${request['order_number'] ?? ''},'
              '${request['user_profiles'] != null && request['user_profiles']['full_name'] != null ? request['user_profiles']['full_name'] : ''},'
              '${request['customer_name'] ?? ''},'
              '${request['amount'] ?? ''}');
        }
      } else {
        buffer.writeln(
            'ID,Customer,Service Type,Status,Created Date,Total Amount');
        for (final request in data['serviceRequests']) {
          buffer.writeln(
              '${request['id']},${request['customers']?['full_name'] ?? 'N/A'},${request['service_type']},${request['status']},${request['created_at']},${request['total_amount'] ?? 0}');
        }
      }
    }

    return buffer.toString();
  }
}
