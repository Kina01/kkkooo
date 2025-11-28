// lib/services/subject_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';
import '../models/subject_model.dart';
import 'auth_service.dart';

class SubjectService {
  static const String baseUrl = 'http://desktop-nkukmb9.local:8080/api/subjects';
  // static const String baseUrl = 'http://172.50.169.165:8080/api/subjects';

  static Future<ApiResponse<List<SubjectSummary>>> getAllSubjects() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/all'), headers: {'Content-Type': 'application/json'});
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => SubjectSummary.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<SubjectSummary>>> getMySubjects() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.get(Uri.parse('$baseUrl/my-subjects'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      });

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => SubjectSummary.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<Subject>> createSubject(CreateSubjectRequest request) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.post(Uri.parse('$baseUrl/add'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      }, body: json.encode(request.toJson()));

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => Subject.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<Subject>> updateSubject(int subjectId, UpdateSubjectRequest request) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.put(Uri.parse('$baseUrl/update/$subjectId'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      }, body: json.encode(request.toJson()));

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => Subject.fromJson(Map<String, dynamic>.from(jsonData)));
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<void>> deleteSubject(int subjectId) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final response = await http.delete(Uri.parse('$baseUrl/delete/$subjectId'), headers: {
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

  static Future<ApiResponse<List<SubjectSummary>>> searchSubjects(String name) async {
    try {
      final encoded = Uri.encodeQueryComponent(name);
      final response = await http.get(Uri.parse('$baseUrl/search?name=$encoded'), headers: {'Content-Type': 'application/json'});
      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => SubjectSummary.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  static Future<ApiResponse<List<SubjectSummary>>> searchMySubjects(String name) async {
    try {
      final user = await AuthService.getUser();
      if (user == null) return ApiResponse(message: 'Chưa đăng nhập', status: 'error');

      final encoded = Uri.encodeQueryComponent(name);
      final response = await http.get(Uri.parse('$baseUrl/search/my-subjects?name=$encoded'), headers: {
        'Content-Type': 'application/json',
        'User-ID': user.userId.toString(),
      });

      final Map<String, dynamic> data = response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic> : {};
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data, (jsonData) => (jsonData as List).map((e) => SubjectSummary.fromJson(Map<String, dynamic>.from(e))).toList());
      } else {
        return ApiResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return ApiResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }
}
