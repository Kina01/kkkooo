// lib/services/exam_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';
import '../models/exam_model.dart';
import 'auth_service.dart';

class ExamService {
  static const String baseUrl = 'http://desktop-nkukmb9.local:8080/api/exams';

  static Future<ApiResponse<Exam>> createExam(int classId, Map<String, dynamic> payload) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.post(Uri.parse('$baseUrl/class/$classId'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      }, body: json.encode(payload));

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => Exam.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<Exam>> updateExam(int examId, Map<String, dynamic> payload) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');
      final response = await http.put(Uri.parse('$baseUrl/$examId'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      }, body: json.encode(payload));

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => Exam.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<void>> deleteExam(int examId) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');
      final response = await http.delete(Uri.parse('$baseUrl/$examId'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      });

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => null);
      } else {
        return ApiResponse(message: data['message']?.toString() ?? 'Lỗi', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<Exam>>> getExamsByClass(int classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/class/$classId'), headers: {'Content-Type': 'application/json'});
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => Exam.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: 'Lỗi: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<Exam>>> getTeacherExams() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');
      final response = await http.get(Uri.parse('$baseUrl/teacher'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      });

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => Exam.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: 'Lỗi: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }
}
