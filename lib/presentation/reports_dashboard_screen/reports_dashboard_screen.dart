import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/automated_scheduling_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/filter_reports_widget.dart';
import './widgets/generated_reports_widget.dart';
import './widgets/report_type_grid_widget.dart';
import './widgets/report_viewer_widget.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _periodTabController;

  String _selectedPeriod = 'Weekly';
  bool _isGenerating = false;
  bool _isAdmin = true; // Role-based access control

  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Custom'];

  @override
  void initState() {
    super.initState();
    _periodTabController = TabController(
      length: _periods.length,
      vsync: this,
      initialIndex: 1, // Weekly
    );
    _periodTabController.addListener(_onPeriodChanged);
  }

  void _onPeriodChanged() {
    if (_periodTabController.indexIsChanging) {
      setState(() {
        _selectedPeriod = _periods[_periodTabController.index];
      });
    }
  }

  Future<void> _refreshReports() async {
    setState(() {
      _isGenerating = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reports refreshed successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCustomPeriodDialog() {
    if (_selectedPeriod == 'Custom') {
      showDateRangePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now(),
        initialDateRange: DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        ),
      ).then((dateRange) {
        if (dateRange != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Custom period: ${dateRange.start.day}/${dateRange.start.month} - ${dateRange.end.day}/${dateRange.end.month}',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Reports Dashboard'),
        elevation: 2.0,
        shadowColor: AppTheme.shadowLight,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(8.h),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevatedLight,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppTheme.borderSubtleLight,
              ),
            ),
            child: TabBar(
              controller: _periodTabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              labelColor: AppTheme.onPrimaryLight,
              unselectedLabelColor: AppTheme.textSecondaryLight,
              tabs: _periods.map((period) {
                return Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(
                      period,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                );
              }).toList(),
              onTap: (index) {
                if (_periods[index] == 'Custom') {
                  _showCustomPeriodDialog();
                }
              },
            ),
          ),
        ),
        actions: [
          if (_isGenerating)
            Container(
              margin: EdgeInsets.only(right: 3.w),
              child: SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          else
            IconButton(
              onPressed: _refreshReports,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Reports',
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshReports,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(2.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Report Type Cards
                    ReportTypeGridWidget(
                      selectedPeriod: _selectedPeriod,
                      isAdmin: _isAdmin,
                      onReportGenerate: (reportType) =>
                          _generateReport(reportType),
                    ),

                    SizedBox(height: 3.h),

                    // Filter Section
                    FilterReportsWidget(
                      onFilterChanged: (filters) => _applyFilters(filters),
                    ),

                    SizedBox(height: 3.h),

                    // Generated Reports
                    GeneratedReportsWidget(
                      isAdmin: _isAdmin,
                      onReportTap: (report) => _viewReport(report),
                      onReportShare: (report) => _shareReport(report),
                      onReportExport: (report) => _exportReport(report),
                      onReportDelete: (report) => _deleteReport(report),
                    ),

                    SizedBox(height: 3.h),

                    // Automated Scheduling (Admin only)
                    if (_isAdmin) ...[
                      AutomatedSchedulingWidget(
                        onScheduleUpdate: (schedule) =>
                            _updateSchedule(schedule),
                      ),
                      SizedBox(height: 3.h),
                    ],

                    // Export Options
                    ExportOptionsWidget(
                      onExport: (format, reportType) =>
                          _handleExport(format, reportType),
                    ),

                    SizedBox(height: 10.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showBulkReportDialog(),
              icon: const Icon(Icons.batch_prediction),
              label: const Text('Bulk Generate'),
            )
          : null,
    );
  }

  Future<void> _generateReport(String reportType) async {
    setState(() {
      _isGenerating = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$reportType report generated successfully'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _viewGeneratedReport(reportType),
          ),
        ),
      );
    }
  }

  void _viewReport(Map<String, dynamic> report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportViewerWidget(report: report),
      ),
    );
  }

  void _shareReport(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ExportOptionsWidget(
        reportData: report,
        onExport: (format, data) => _handleShare(format, report),
      ),
    );
  }

  void _exportReport(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${report['name']}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: Text('Are you sure you want to delete "${report['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${report['name']} deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilters(Map<String, dynamic> filters) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filters applied: ${filters.keys.join(", ")}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateSchedule(Map<String, dynamic> schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Schedule updated: ${schedule['frequency']} ${schedule['reportType']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExport(String format, String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting $reportType as $format...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShare(String format, Map<String, dynamic> data) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing report as $format...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewGeneratedReport(String reportType) {
    final mockReport = {
      'name': '$reportType Report - $_selectedPeriod',
      'type': reportType,
      'period': _selectedPeriod,
      'createdAt': DateTime.now(),
      'size': '2.5 MB',
    };
    _viewReport(mockReport);
  }

  void _showBulkReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bulk Report Generation'),
          content:
              const Text('Generate all report types for the selected period?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateBulkReports();
              },
              child: const Text('Generate All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateBulkReports() async {
    setState(() {
      _isGenerating = true;
    });

    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All reports generated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _periodTabController.dispose();
    super.dispose();
  }
}