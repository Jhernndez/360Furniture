import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ReportViewerWidget extends StatefulWidget {
  final Map<String, dynamic> report;

  const ReportViewerWidget({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<ReportViewerWidget> createState() => _ReportViewerWidgetState();
}

class _ReportViewerWidgetState extends State<ReportViewerWidget>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _zoomController;

  bool _isFullScreen = false;
  double _currentZoom = 1.0;
  int _currentPage = 1;
  int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentZoom).abs() > 0.01) {
      setState(() {
        _currentZoom = scale;
      });
    }
  }

  void _zoomIn() {
    final newScale = (_currentZoom * 1.2).clamp(1.0, 3.0);
    final animation = Tween<Matrix4>(
      begin: _transformationController.value,
      end: Matrix4.identity()..scale(newScale),
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOut,
    ));

    animation.addListener(() {
      _transformationController.value = animation.value;
    });

    _zoomController.forward(from: 0);
  }

  void _zoomOut() {
    final newScale = (_currentZoom / 1.2).clamp(1.0, 3.0);
    final animation = Tween<Matrix4>(
      begin: _transformationController.value,
      end: Matrix4.identity()..scale(newScale),
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOut,
    ));

    animation.addListener(() {
      _transformationController.value = animation.value;
    });

    _zoomController.forward(from: 0);
  }

  void _resetZoom() {
    final animation = Tween<Matrix4>(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOut,
    ));

    animation.addListener(() {
      _transformationController.value = animation.value;
    });

    _zoomController.forward(from: 0);
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _showPageJumpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedPage = _currentPage;
        return AlertDialog(
          title: const Text('Jump to Page'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select page (1 - $_totalPages)'),
              SizedBox(height: 2.h),
              Row(
                children: [
                  IconButton(
                    onPressed: selectedPage > 1
                        ? () => setState(() => selectedPage--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        selectedPage.toString(),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: selectedPage < _totalPages
                        ? () => setState(() => selectedPage++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentPage = selectedPage;
                });
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFullScreen ? Colors.black : AppTheme.backgroundLight,
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(widget.report['name']),
              elevation: 2.0,
              actions: [
                IconButton(
                  onPressed: _toggleFullScreen,
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Full Screen',
                ),
                IconButton(
                  onPressed: () => _showShareOptions(),
                  icon: const Icon(Icons.share),
                  tooltip: 'Share',
                ),
                PopupMenuButton<String>(
                  onSelected: _handleMenuAction,
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'download',
                        child: ListTile(
                          leading: Icon(Icons.download),
                          title: Text('Download'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'print',
                        child: ListTile(
                          leading: Icon(Icons.print),
                          title: Text('Print'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'info',
                        child: ListTile(
                          leading: Icon(Icons.info),
                          title: Text('Report Info'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
      body: Stack(
        children: [
          // Main Report Content
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(20.0),
            minScale: 0.5,
            maxScale: 3.0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: _isFullScreen ? Colors.black : Colors.white,
              child: _buildReportContent(),
            ),
          ),

          // Full Screen Exit Button
          if (_isFullScreen)
            Positioned(
              top: 8.h,
              right: 4.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _toggleFullScreen,
                  icon: const Icon(
                    Icons.fullscreen_exit,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Zoom Controls
          Positioned(
            bottom: _isFullScreen ? 15.h : 20.h,
            right: 4.w,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _isFullScreen
                        ? Colors.black54
                        : AppTheme.surfaceElevatedLight,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: _zoomIn,
                        icon: Icon(
                          Icons.zoom_in,
                          color: _isFullScreen
                              ? Colors.white
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text(
                          '${(_currentZoom * 100).toInt()}%',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _isFullScreen
                                        ? Colors.white
                                        : AppTheme.textPrimaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      IconButton(
                        onPressed: _zoomOut,
                        icon: Icon(
                          Icons.zoom_out,
                          color: _isFullScreen
                              ? Colors.white
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                      IconButton(
                        onPressed: _resetZoom,
                        icon: Icon(
                          Icons.center_focus_strong,
                          color: _isFullScreen
                              ? Colors.white
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Controls
          Positioned(
            bottom: _isFullScreen ? 5.h : 10.h,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _isFullScreen
                    ? Colors.black54
                    : AppTheme.surfaceElevatedLight,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1 ? _previousPage : null,
                    icon: Icon(
                      Icons.navigate_before,
                      color: _currentPage > 1
                          ? (_isFullScreen
                              ? Colors.white
                              : AppTheme.primaryLight)
                          : AppTheme.textDisabledLight,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showPageJumpDialog,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '$_currentPage / $_totalPages',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _currentPage < _totalPages ? _nextPage : null,
                    icon: Icon(
                      Icons.navigate_next,
                      color: _currentPage < _totalPages
                          ? (_isFullScreen
                              ? Colors.white
                              : AppTheme.primaryLight)
                          : AppTheme.textDisabledLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: _isFullScreen
                  ? Colors.grey[900]
                  : AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.report['name'],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _isFullScreen
                            ? Colors.white
                            : AppTheme.primaryLight,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Generated: ${_formatDateTime(widget.report['createdAt'])}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isFullScreen
                            ? Colors.white70
                            : AppTheme.textSecondaryLight,
                      ),
                ),
                Text(
                  'Period: ${widget.report['period']} | Page $_currentPage of $_totalPages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isFullScreen
                            ? Colors.white70
                            : AppTheme.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Sample Report Content
          Expanded(
            child: _buildSampleReportPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleReportPage() {
    switch (_currentPage) {
      case 1:
        return _buildExecutiveSummaryPage();
      case 2:
        return _buildMetricsPage();
      case 3:
        return _buildChartsPage();
      case 4:
        return _buildDataTablePage();
      case 5:
        return _buildRecommendationsPage();
      default:
        return _buildExecutiveSummaryPage();
    }
  }

  Widget _buildExecutiveSummaryPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Executive Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _isFullScreen ? Colors.white : AppTheme.textPrimaryLight,
              ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: _isFullScreen
                ? Colors.grey[800]
                : AppTheme.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFullScreen
                  ? Colors.grey[700]!
                  : AppTheme.borderSubtleLight,
            ),
          ),
          child: Text(
            'This ${widget.report['type']} provides comprehensive insights into performance metrics for the ${widget.report['period']} period. Key highlights include improved efficiency, customer satisfaction ratings, and overall operational excellence.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      _isFullScreen ? Colors.white : AppTheme.textPrimaryLight,
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _isFullScreen ? Colors.white : AppTheme.textPrimaryLight,
              ),
        ),
        SizedBox(height: 2.h),
        _buildMetricCard('Total Orders', '156', '+12%'),
        SizedBox(height: 2.h),
        _buildMetricCard('Average Rating', '4.8★', '+0.2'),
        SizedBox(height: 2.h),
        _buildMetricCard('Completion Rate', '98%', '+2%'),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String change) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _isFullScreen ? Colors.grey[800] : AppTheme.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFullScreen ? Colors.grey[700]! : AppTheme.borderSubtleLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      _isFullScreen ? Colors.white : AppTheme.textPrimaryLight,
                ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          _isFullScreen ? Colors.white : AppTheme.primaryLight,
                    ),
              ),
              Text(
                change,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.successLight,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Charts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _isFullScreen ? Colors.white : AppTheme.textPrimaryLight,
              ),
        ),
        SizedBox(height: 2.h),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: _isFullScreen
                  ? Colors.grey[800]
                  : AppTheme.surfaceElevatedLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFullScreen
                    ? Colors.grey[700]!
                    : AppTheme.borderSubtleLight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 20.w,
                    color: _isFullScreen
                        ? Colors.white54
                        : AppTheme.textDisabledLight,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Chart visualization would appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _isFullScreen
                              ? Colors.white54
                              : AppTheme.textDisabledLight,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTablePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Data',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _isFullScreen ? Colors.white : AppTheme.textPrimaryLight,
              ),
        ),
        SizedBox(height: 2.h),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: _isFullScreen
                  ? Colors.grey[800]
                  : AppTheme.surfaceElevatedLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFullScreen
                    ? Colors.grey[700]!
                    : AppTheme.borderSubtleLight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_chart,
                    size: 20.w,
                    color: _isFullScreen
                        ? Colors.white54
                        : AppTheme.textDisabledLight,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Data table would appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _isFullScreen
                              ? Colors.white54
                              : AppTheme.textDisabledLight,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _isFullScreen ? Colors.white : AppTheme.textPrimaryLight,
              ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: _isFullScreen
                ? Colors.grey[800]
                : AppTheme.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFullScreen
                  ? Colors.grey[700]!
                  : AppTheme.borderSubtleLight,
            ),
          ),
          child: Text(
            '• Continue current performance trends\n'
            '• Focus on customer satisfaction improvements\n'
            '• Optimize service delivery times\n'
            '• Implement quality control measures',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      _isFullScreen ? Colors.white : AppTheme.textPrimaryLight,
                  height: 1.8,
                ),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading ${widget.report['name']}...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'print':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printing report...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'info':
        _showReportInfo();
        break;
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Report',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.report['name']}'),
              Text('Type: ${widget.report['type']}'),
              Text('Period: ${widget.report['period']}'),
              Text('Size: ${widget.report['size']}'),
              Text('Created: ${_formatDateTime(widget.report['createdAt'])}'),
              Text('Pages: $_totalPages'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _zoomController.dispose();
    super.dispose();
  }
}
