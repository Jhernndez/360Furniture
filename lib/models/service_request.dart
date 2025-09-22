class ServiceRequest {
  final String id;
  final String customerId;
  final String? technicianId;
  final String createdBy;
  final String serviceType;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final double? estimatedHours;
  final double? actualHours;
  final double? hourlyRate;
  final double? totalCost;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? technician;
  final List<Map<String, dynamic>>? photos;
  final List<Map<String, dynamic>>? timeTracking;

  ServiceRequest({
    required this.id,
    required this.customerId,
    this.technicianId,
    required this.createdBy,
    required this.serviceType,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.estimatedHours,
    this.actualHours,
    this.hourlyRate,
    this.totalCost,
    this.scheduledDate,
    this.completedDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.technician,
    this.photos,
    this.timeTracking,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      technicianId: json['technician_id'],
      createdBy: json['created_by'] ?? '',
      serviceType: json['service_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      estimatedHours: json['estimated_hours']?.toDouble(),
      actualHours: json['actual_hours']?.toDouble(),
      hourlyRate: json['hourly_rate']?.toDouble(),
      totalCost: json['total_cost']?.toDouble(),
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'])
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customer: json['customers'],
      technician: json['user_profiles'],
      photos: json['service_photos'] != null
          ? List<Map<String, dynamic>>.from(json['service_photos'])
          : null,
      timeTracking: json['time_tracking'] != null
          ? List<Map<String, dynamic>>.from(json['time_tracking'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'technician_id': technicianId,
      'created_by': createdBy,
      'service_type': serviceType,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'estimated_hours': estimatedHours,
      'actual_hours': actualHours,
      'hourly_rate': hourlyRate,
      'total_cost': totalCost,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getters for display
  String get customerName => customer?['name'] ?? 'Unknown Customer';
  String get technicianName => technician?['full_name'] ?? 'Unassigned';
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  String get serviceTypeDisplay {
    switch (serviceType) {
      case 'installation':
        return 'Installation';
      case 'maintenance':
        return 'Maintenance';
      case 'repair':
        return 'Repair';
      case 'inspection':
        return 'Inspection';
      default:
        return serviceType;
    }
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? technicianId,
    String? createdBy,
    String? serviceType,
    String? title,
    String? description,
    String? priority,
    String? status,
    double? estimatedHours,
    double? actualHours,
    double? hourlyRate,
    double? totalCost,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? technician,
    List<Map<String, dynamic>>? photos,
    List<Map<String, dynamic>>? timeTracking,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      technicianId: technicianId ?? this.technicianId,
      createdBy: createdBy ?? this.createdBy,
      serviceType: serviceType ?? this.serviceType,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      totalCost: totalCost ?? this.totalCost,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      technician: technician ?? this.technician,
      photos: photos ?? this.photos,
      timeTracking: timeTracking ?? this.timeTracking,
    );
  }
}
