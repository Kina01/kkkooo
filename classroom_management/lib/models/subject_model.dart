// lib/models/subject_model.dart
import 'user_model.dart';

int _toInt2(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String _toStr2(dynamic v) => v == null ? '' : v.toString();

class Subject {
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int? credits;
  final User? createdBy;
  final String? createdAt;

  Subject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    this.credits,
    this.createdBy,
    this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: _toInt2(json['subjectId']),
      subjectCode: _toStr2(json['subjectCode']),
      subjectName: _toStr2(json['subjectName']),
      credits: json['credits'] != null ? _toInt2(json['credits']) : null,
      createdBy: json['createdBy'] is Map<String, dynamic> ? User.fromJson(Map<String, dynamic>.from(json['createdBy'])) : null,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'credits': credits,
      'createdBy': createdBy?.toJson(),
      'createdAt': createdAt,
    };
  }
}

class SubjectSummary {
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int? credits;
  final String? teacherName;

  SubjectSummary({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    this.credits,
    this.teacherName,
  });

  factory SubjectSummary.fromJson(Map<String, dynamic> json) {
    String? teacher = json['teacherName']?.toString();
    if ((teacher == null || teacher.isEmpty) && json['createdBy'] is Map<String, dynamic>) {
      teacher = (json['createdBy'] as Map)['fullName']?.toString();
    }
    return SubjectSummary(
      subjectId: _toInt2(json['subjectId']),
      subjectCode: _toStr2(json['subjectCode']),
      subjectName: _toStr2(json['subjectName']),
      credits: json['credits'] != null ? _toInt2(json['credits']) : null,
      teacherName: teacher,
    );
  }
}

class CreateSubjectRequest {
  final String subjectCode;
  final String subjectName;
  final int? credits;

  CreateSubjectRequest({ required this.subjectCode, required this.subjectName, this.credits });

  Map<String, dynamic> toJson() => {
    'subjectCode': subjectCode,
    'subjectName': subjectName,
    'credits': credits,
  };
}

class UpdateSubjectRequest {
  final String subjectCode;
  final String subjectName;
  final int? credits;

  UpdateSubjectRequest({ required this.subjectCode, required this.subjectName, this.credits });

  Map<String, dynamic> toJson() => {
    'subjectCode': subjectCode,
    'subjectName': subjectName,
    'credits': credits,
  };
}
