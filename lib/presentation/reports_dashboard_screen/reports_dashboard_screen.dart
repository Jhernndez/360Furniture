import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/filter_reports_widget.dart';
import '../../services/report_service.dart';
// import './widgets/generated_reports_widget.dart';
// import './widgets/report_type_grid_widget.dart';
// import './widgets/report_viewer_widget.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _periodTabController;

  bool _isGenerating = false;

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
    // No-op: period selection UI removed
    // if (_periodTabController.indexIsChanging) {
    //   setState(() {
    //     _selectedPeriod = _periods[_periodTabController.index];
    //   });
    // }
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

  Map<String, dynamic> _currentFilters = {};

  @override
  Widget build(BuildContext context) {
    final bool showDownloadFab = _currentFilters['dateRange'] != null &&
        _currentFilters['reportType'] != null &&
        _currentFilters['reportType'] != 'All Types';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Reports Dashboard'),
        elevation: 2.0,
        shadowColor: AppTheme.shadowLight,
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
                    // ...existing code...
                    // Removed ReportTypeGridWidget and period selector UI
                    // Filter Section
                    FilterReportsWidget(
                      onFilterChanged: (filters) => _applyFilters(filters),
                    ),
                    SizedBox(height: 3.h),
                    SizedBox(height: 3.h),
                    SizedBox(height: 10.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: showDownloadFab
          ? FloatingActionButton.extended(
              onPressed: _downloadExcel,
              icon: const Icon(Icons.download),
              label: const Text('Descargar Excel'),
            )
          : null,
    );
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
    });
  }

  Future<void> _downloadExcel() async {
    if (_currentFilters['reportType'] == null ||
        _currentFilters['reportType'] == 'All Types' ||
        _currentFilters['dateRange'] == null) {
      return;
    }
    final reportType = _currentFilters['reportType'];
    print('[DEBUG] Valor de reportType recibido: ' + reportType.toString());
    final filters = Map<String, dynamic>.from(_currentFilters);
    // Convert DateTimeRange to start/end ISO strings for backend
    if (filters['dateRange'] != null) {
      filters['start'] = filters['dateRange'].start.toIso8601String();
      filters['end'] = filters['dateRange'].end.toIso8601String();
      filters.remove('dateRange');
    }
    try {
      setState(() => _isGenerating = true);
      if (reportType.toString().toLowerCase() == 'summary payments') {
        // Descarga personalizada para summary payments
        await ReportService.downloadReport(
          reportType: reportType,
          format: 'EXCEL',
          filters: {
            ...filters,
            'columns': [
              'order_number',
              'technician_name',
              'customer_name',
              'amount'
            ],
          },
        );
      } else {
        await ReportService.downloadReport(
          reportType: reportType,
          format: 'EXCEL',
          filters: filters,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Descarga iniciada'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al descargar: $e'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _periodTabController.dispose();
    super.dispose();
  }
}
