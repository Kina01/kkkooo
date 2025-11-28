// lib/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/notification_model.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class NotificationService {
  static const String baseUrl =
      'http://desktop-nkukmb9.local:8080/api/notifications';
  // static const String baseUrl =
  //     'http://172.xx.xx.xx:8080/api/notifications';

  /// Lấy danh sách thông báo của giáo viên
  static Future<ApiResponse<List<NotificationSummary>>>
      getTeacherNotifications() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/teacher/my-notifications'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) => (jsonData as List)
              .map((e) => NotificationSummary.fromJson(e))
              .toList(),
        );
      } else {
        return ApiResponse(
          message: 'Lỗi kết nối: ${response.statusCode}',
          status: 'error',
        );
      }
    } catch (e) {
      return ApiResponse(
        message: 'Lỗi kết nối: $e',
        status: 'error',
      );
    }
  }

  /// Lấy danh sách thông báo cho sinh viên
  static Future<ApiResponse<List<NotificationSummary>>>
      getStudentNotifications() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/student/my-notifications'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) => (jsonData as List)
              .map((e) => NotificationSummary.fromJson(e))
              .toList(),
        );
      } else {
        return ApiResponse(
          message: 'Lỗi kết nối: ${response.statusCode}',
          status: 'error',
        );
      }
    } catch (e) {
      return ApiResponse(
        message: 'Lỗi kết nối: $e',
        status: 'error',
      );
    }
  }

  /// Lấy chi tiết 1 thông báo
  static Future<ApiResponse<NotificationDetail>> getNotificationDetail(
      int notificationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) => NotificationDetail.fromJson(jsonData),
        );
      } else {
        return ApiResponse(
          message: 'Lỗi kết nối: ${response.statusCode}',
          status: 'error',
        );
      }
    } catch (e) {
      return ApiResponse(
        message: 'Lỗi kết nối: $e',
        status: 'error',
      );
    }
  }

  /// Tạo thông báo mới (giáo viên)
  static Future<ApiResponse<NotificationDetail>> createNotification(
      CreateNotificationRequest request) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) => NotificationDetail.fromJson(jsonData),
        );
      } else {
        return ApiResponse(
          message: 'Lỗi kết nối: ${response.statusCode}',
          status: 'error',
        );
      }
    } catch (e) {
      return ApiResponse(
        message: 'Lỗi kết nối: $e',
        status: 'error',
      );
    }
  }

  /// Cập nhật thông báo
  static Future<ApiResponse<NotificationDetail>> updateNotification(
      int notificationId, UpdateNotificationRequest request) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.put(
        Uri.parse('$baseUrl/update/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) => NotificationDetail.fromJson(jsonData),
        );
      } else {
        return ApiResponse(
          message: 'Lỗi kết nối: ${response.statusCode}',
          status: 'error',
        );
      }
    } catch (e) {
      return ApiResponse(
        message: 'Lỗi kết nối: $e',
        status: 'error',
      );
    }
  }

  /// Xóa thông báo
  static Future<ApiResponse<void>> deleteNotification(
      int notificationId) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(data, (jsonData) => null);
      } else {
        return ApiResponse(
          message: 'Lỗi kết nối: ${response.statusCode}',
          status: 'error',
        );
      }
    } catch (e) {
      return ApiResponse(
        message: 'Lỗi kết nối: $e',
        status: 'error',
      );
    }
  }
}
