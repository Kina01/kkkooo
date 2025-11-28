// lib/models/class_model.dart
import 'user_model.dart';

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String _toStr(dynamic v) => v == null ? '' : v.toString();

class ClassSummary {
  final int classId;
  final String classCode;
  final String className;
  final String description;
  final String teacherName;
  final int studentCount;

  ClassSummary({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.description,
    required this.teacherName,
    required this.studentCount,
  });

  factory ClassSummary.fromJson(Map<String, dynamic> json) {
    return ClassSummary(
      classId: _toInt(json['classId']),
      classCode: _toStr(json['classCode']),
      className: _toStr(json['className']),
      description: _toStr(json['description']),
      teacherName: _toStr(json['teacherName']),
      studentCount: _toInt(json['studentCount']),
    );
  }
}

class ClassResponse {
  final int classId;
  final String classCode;
  final String className;
  final String description;
  final User? teacher;
  final List<User> students;
  final int studentCount;

  ClassResponse({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.description,
    required this.teacher,
    required this.students,
    required this.studentCount,
  });

  factory ClassResponse.fromJson(Map<String, dynamic> json) {
    final studentsJson = json['students'];
    List<User> students = [];
    if (studentsJson is List) {
      students = studentsJson.map((e) {
        if (e is Map<String, dynamic>) return User.fromJson(Map<String, dynamic>.from(e));
        return User.fromJson({});
      }).toList();
    }

    User? teacher;
    if (json['teacher'] is Map<String, dynamic>) {
      teacher = User.fromJson(Map<String, dynamic>.from(json['teacher']));
    }

    return ClassResponse(
      classId: _toInt(json['classId']),
      classCode: _toStr(json['classCode']),
      className: _toStr(json['className']),
      description: _toStr(json['description']),
      teacher: teacher,
      students: students,
      studentCount: _toInt(json['studentCount']),
    );
  }
}

class CreateClassRequest {
  final String classCode;
  final String className;
  final String description;

  CreateClassRequest({ required this.classCode, required this.className, required this.description });

  Map<String, dynamic> toJson() => {
    'classCode': classCode,
    'className': className,
    'description': description,
  };
}

class UpdateClassRequest {
  final String classCode;
  final String className;
  final String description;

  UpdateClassRequest({ required this.classCode, required this.className, required this.description });

  Map<String, dynamic> toJson() => {
    'classCode': classCode,
    'className': className,
    'description': description,
  };
}

class ApiResponse<T> {
  final String message;
  final String status;
  final T? data;

  ApiResponse({ required this.message, required this.status, this.data });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    final message = json['message']?.toString() ?? '';
    final status = json['status']?.toString() ?? '';
    final rawData = json['data'];
    T? parsed;
    if (rawData != null) {
      parsed = fromJsonT(rawData);
    }
    return ApiResponse(message: message, status: status, data: parsed);
  }

  bool get isSuccess => status == 'success';
}
