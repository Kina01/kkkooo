// lib/services/class_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';
import 'auth_service.dart';

class ClassService {
  static const String baseUrl = 'http://desktop-nkukmb9.local:8080/api/classes';
  // static const String baseUrl = 'http://172.50.169.165:8080/api/classes';

  static Future<ApiResponse<List<ClassSummary>>> getTeacherClasses() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.get(Uri.parse('$baseUrl/teacher'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      });

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => ClassSummary.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<ClassSummary>>> getStudentClasses() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.get(Uri.parse('$baseUrl/student'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      });

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => ClassSummary.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<ClassResponse>> createClass(CreateClassRequest request) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.post(Uri.parse('$baseUrl/add-class'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      }, body: json.encode(request.toJson()));

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => ClassResponse.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<ClassResponse>> getClassDetail(int classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getclass/$classId'), headers: {
        'Content-Type': 'application/json',
      });

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => ClassResponse.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<ClassResponse>> updateClass(int classId, UpdateClassRequest request) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.put(Uri.parse('$baseUrl/update/$classId'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      }, body: json.encode(request.toJson()));

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => ClassResponse.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<void>> deleteClass(int classId) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.delete(Uri.parse('$baseUrl/delete/$classId'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      });

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => null);
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }
}
