// lib/models/notification_model.dart
import 'user_model.dart';
import 'class_model.dart';

/// Kiểu thông báo (khớp với enum bên backend)
/// Bạn đang muốn giữ lại: lịch học, lịch thi, khác, giáo viên
enum NotificationType {
  SCHEDULE, // Thông báo lịch học
  EXAM,     // Thông báo lịch thi
  OTHER,    // Thông báo khác // Thông báo từ giáo viên
}

/// Trạng thái thông báo
enum NotificationStatus {
  ACTIVE,
  INACTIVE,
  EXPIRED,
}

/// Helper parse enum từ String (tránh lỗi)
NotificationType parseNotificationType(String? value) {
  if (value == null) return NotificationType.OTHER;
  switch (value.toUpperCase()) {
    case 'SCHEDULE':
      return NotificationType.SCHEDULE;
    case 'EXAM':
      return NotificationType.EXAM;
    case 'OTHER':
    default:
      return NotificationType.OTHER;
  }
}

NotificationStatus parseNotificationStatus(String? value) {
  if (value == null) return NotificationStatus.ACTIVE;
  switch (value.toUpperCase()) {
    case 'INACTIVE':
      return NotificationStatus.INACTIVE;
    case 'EXPIRED':
      return NotificationStatus.EXPIRED;
    case 'ACTIVE':
    default:
      return NotificationStatus.ACTIVE;
  }
}

/// Model tóm tắt (dùng cho danh sách)
class NotificationSummary {
  final int notificationId;
  final String title;
  final String? contentPreview;
  final DateTime? createdAt;
  final DateTime? scheduledAt;
  final NotificationStatus status;
  final NotificationType type;
  final String? teacherName;
  final int? totalClasses;

  NotificationSummary({
    required this.notificationId,
    required this.title,
    this.contentPreview,
    this.createdAt,
    this.scheduledAt,
    required this.status,
    required this.type,
    this.teacherName,
    this.totalClasses,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      notificationId: (json['notificationId'] ?? 0) as int,
      title: json['title'] ?? '',
      contentPreview: json['contentPreview'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      status: parseNotificationStatus(json['status']),
      type: parseNotificationType(json['type']),
      teacherName: json['teacherName'],
      totalClasses: json['totalClasses'],
    );
  }

  String get typeLabel {
    switch (type) {
      case NotificationType.SCHEDULE:
        return 'Lịch học';
      case NotificationType.EXAM:
        return 'Lịch thi';
      case NotificationType.OTHER:
      default:
        return 'Khác';
    }
  }

  String get statusLabel {
    switch (status) {
      case NotificationStatus.ACTIVE:
        return 'Đang hiệu lực';
      case NotificationStatus.INACTIVE:
        return 'Tạm ẩn';
      case NotificationStatus.EXPIRED:
        return 'Hết hạn';
    }
  }
}

/// Model chi tiết (NotificationResponse)
class NotificationDetail {
  final int notificationId;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? scheduledAt;
  final NotificationStatus status;
  final NotificationType type;
  final User? teacher;
  final List<ClassSummary> targetClasses;
  final int? totalClasses;

  NotificationDetail({
    required this.notificationId,
    required this.title,
    required this.content,
    this.createdAt,
    this.scheduledAt,
    required this.status,
    required this.type,
    this.teacher,
    required this.targetClasses,
    this.totalClasses,
  });

  factory NotificationDetail.fromJson(Map<String, dynamic> json) {
    return NotificationDetail(
      notificationId: (json['notificationId'] ?? 0) as int,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      status: parseNotificationStatus(json['status']),
      type: parseNotificationType(json['type']),
      teacher: json['teacher'] != null ? User.fromJson(json['teacher']) : null,
      targetClasses: (json['targetClasses'] as List? ?? [])
          .map((e) => ClassSummary.fromJson(e))
          .toList(),
      totalClasses: json['totalClasses'],
    );
  }

  String get typeLabel {
    switch (type) {
      case NotificationType.SCHEDULE:
        return 'Lịch học';
      case NotificationType.EXAM:
        return 'Lịch thi';
      case NotificationType.OTHER:
      default:
        return 'Khác';
    }
  }

  String get statusLabel {
    switch (status) {
      case NotificationStatus.ACTIVE:
        return 'Đang hiệu lực';
      case NotificationStatus.INACTIVE:
        return 'Tạm ẩn';
      case NotificationStatus.EXPIRED:
        return 'Hết hạn';
    }
  }
}

/// Request tạo thông báo
class CreateNotificationRequest {
  final String title;
  final String content;
  final DateTime? scheduledAt;
  final NotificationType type;
  final List<int> classIds;

  CreateNotificationRequest({
    required this.title,
    required this.content,
    this.scheduledAt,
    required this.type,
    required this.classIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'type': type.name, // gửi dạng "SCHEDULE", "EXAM", ...
      'classIds': classIds,
    };
  }
}

/// Request cập nhật thông báo (tùy chọn field)
class UpdateNotificationRequest {
  final String? title;
  final String? content;
  final DateTime? scheduledAt;
  final NotificationStatus? status;
  final NotificationType? type;
  final List<int>? classIds;

  UpdateNotificationRequest({
    this.title,
    this.content,
    this.scheduledAt,
    this.status,
    this.type,
    this.classIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'status': status?.name,
      'type': type?.name,
      'classIds': classIds,
    };
  }
}
