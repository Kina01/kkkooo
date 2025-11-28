// lib/services/grade_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';
import '../models/grade_model.dart';
import 'auth_service.dart';

class GradeService {
  static const String baseUrl = 'http://desktop-nkukmb9.local:8080/api/grades';

  static Future<ApiResponse<Grade>> addOrUpdateGrade({
    required int classId,
    required int studentId,
    required int subjectId,
    double? processScore,
    double? midtermScore,
    String? comments,
  }) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final body = {
        'processScore': processScore,
        'midtermScore': midtermScore,
        'comments': comments,
      };

      final response = await http.post(Uri.parse('$baseUrl/class/$classId/student/$studentId/subject/$subjectId'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      }, body: json.encode(body));

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => Grade.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<Grade>>> getGradesByClass(int classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/class/$classId'), headers: {'Content-Type': 'application/json'});
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => Grade.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<Grade>>> getStudentGrades(int studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/student/$studentId'), headers: {'Content-Type': 'application/json'});
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => Grade.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<double>> getClassAverage(int classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/class/$classId/average'), headers: {'Content-Type': 'application/json'});
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        final raw = data['data'];
        double avg = 0;
        if (raw is num) avg = raw.toDouble();
        else if (raw is String) avg = double.tryParse(raw) ?? 0;
        return ApiResponse(message: data['message']?.toString() ?? '', status: 'success', data: avg);
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<Grade>>> batchUpdateGrades(int classId, int subjectId, List<Map<String, dynamic>> gradeRequests) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');
      final response = await http.post(
        Uri.parse('$baseUrl/class/$classId/subject/$subjectId/batch'),
        headers: {
          'Content-Type': 'application/json',
          'User-ID': user.userId.toString(),
        },
        body: json.encode(gradeRequests),
      );
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => Grade.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }
}
