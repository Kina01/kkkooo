// lib/services/attendance_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';
import '../models/class_model.dart';
import 'auth_service.dart';

class AttendanceService {
  static const String baseUrl = 'http://desktop-nkukmb9.local:8080/api/attendances';
  // static const String baseUrl = 'http://172.50.169.165:8080/api/attendances';

  // Take attendance for a class schedule
  static Future<ApiResponse<List<Attendance>>> takeAttendance({
    required int classId,
    required int scheduleId,
    required String dateIso, // 'YYYY-MM-DD'
    required Map<int, AttendanceStatus> attendanceMap, // studentId -> status
  }) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final payload = {
        'date': dateIso,
        'attendanceMap': attendanceMap.map((k, v) => MapEntry(k.toString(), attendanceStatusToString(v))),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/class/$classId/schedule/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
        body: json.encode(payload),
      );

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => Attendance.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<Attendance>>> getAttendanceByClassAndDate(int classId, String dateIso) async {
    try {
      final uri = Uri.parse('http://desktop-nkukmb9.local:8080/api/attendances/class/$classId').replace(queryParameters: {'date': dateIso});
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => Attendance.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<Attendance>>> getStudentAttendanceHistory(int studentId, int classId) async {
    try {
      final response = await http.get(Uri.parse('http://desktop-nkukmb9.local:8080/api/attendances/student/$studentId/class/$classId'), headers: {'Content-Type': 'application/json'});
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => Attendance.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<Attendance>> updateAttendance(int attendanceId, AttendanceStatus status, String? notes) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final body = {'status': attendanceStatusToString(status), 'notes': notes};
      final response = await http.put(Uri.parse('$baseUrl/$attendanceId'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      }, body: json.encode(body));

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => Attendance.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<Map<String, int>>> getAttendanceStatistics(int classId) async {
    try {
      final response = await http.get(Uri.parse('http://desktop-nkukmb9.local:8080/api/attendances/class/$classId/statistics'), headers: {'Content-Type': 'application/json'});
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        final raw = data['data'] as Map<String, dynamic>? ?? {};
        final Map<String, int> out = {};
        raw.forEach((k,v) => out[k.toString()] = (v is int) ? v : int.tryParse(v.toString()) ?? 0);
        return ApiResponse(message: data['message']?.toString() ?? '', status: 'success', data: out);
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }
}
