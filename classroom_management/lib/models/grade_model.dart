// lib/models/grade_model.dart
class Grade {
  final int gradeId;
  final int classId;
  final int studentId;
  final int subjectId;
  final double? processScore;
  final double? midtermScore;
  final String? comments;
  final String? updatedAt;

  Grade({
    required this.gradeId,
    required this.classId,
    required this.studentId,
    required this.subjectId,
    this.processScore,
    this.midtermScore,
    this.comments,
    this.updatedAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? null;
      return null;
    }
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Grade(
      gradeId: _toInt(json['gradeId'] ?? json['id']),
      classId: _toInt(json['classId'] ?? json['class']?['classId']),
      studentId: _toInt(json['studentId'] ?? json['student']?['userId']),
      subjectId: _toInt(json['subjectId'] ?? json['subject']?['subjectId']),
      processScore: _toDouble(json['processScore']),
      midtermScore: _toDouble(json['midtermScore']),
      comments: json['comments']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'gradeId': gradeId,
    'classId': classId,
    'studentId': studentId,
    'subjectId': subjectId,
    'processScore': processScore,
    'midtermScore': midtermScore,
    'comments': comments,
  };
}
