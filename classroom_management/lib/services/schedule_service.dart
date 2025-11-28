// services/schedule_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/schedule_model.dart';
import '../models/class_model.dart'; // dùng ApiResponse
import '../services/auth_service.dart';

class ScheduleService {
  static const String baseUrl =
      'http://desktop-nkukmb9.local:8080/api/schedules';
  // static const String baseUrl = 'http://172.xx.xx.xx:8080/api/schedules';

  /// Lấy tất cả lịch của giáo viên (lọc theo user hiện tại)
  static Future<ApiResponse<List<ScheduleItem>>> getTeacherSchedules() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/teacher'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) =>
              (jsonData as List).map((e) => ScheduleItem.fromJson(e)).toList(),
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

  // Lấy TKB của SINH VIÊN hiện tại
  static Future<ApiResponse<List<ScheduleItem>>> getStudentSchedules() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/student/my-schedules'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) =>
              (jsonData as List).map((e) => ScheduleItem.fromJson(e)).toList(),
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

  /// Giáo viên tạo lịch học cho 1 lớp
  /// (map với endpoint: POST /api/schedules/class/{classId}/add)
  static Future<ApiResponse<ScheduleItem>> createSchedule(
      int classId, CreateScheduleRequest request) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add/$classId'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) => ScheduleItem.fromJson(jsonData),
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

  // Cập nhật lịch học
  static Future<ApiResponse<ScheduleItem>> updateSchedule(
      int scheduleId, UpdateScheduleRequest request) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.put(
        Uri.parse('$baseUrl/update/$scheduleId'), // chỉnh lại path nếu BE khác
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse.fromJson(
          data,
          (jsonData) => ScheduleItem.fromJson(jsonData),
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

  /// Xóa 1 lịch học
  /// (map với endpoint: DELETE /api/schedules/{scheduleId})
  static Future<ApiResponse<void>> deleteSchedule(int scheduleId) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        return ApiResponse(
          message: 'Chưa đăng nhập',
          status: 'error',
        );
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
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
