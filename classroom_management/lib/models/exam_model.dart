// lib/models/exam_model.dart
class Exam {
  final int examId;
  final int classId;
  final int subjectId;
  final String examDate; // ISO date
  final String examTime; // "HH:mm"
  final String room;
  final String? notes;

  Exam({
    required this.examId,
    required this.classId,
    required this.subjectId,
    required this.examDate,
    required this.examTime,
    required this.room,
    this.notes,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    String _toStr(dynamic v) => v == null ? '' : v.toString();

    return Exam(
      examId: _toInt(json['examId'] ?? json['id']),
      classId: _toInt(json['classId'] ?? json['class']?['classId']),
      subjectId: _toInt(json['subjectId'] ?? json['subject']?['subjectId']),
      examDate: _toStr(json['examDate'] ?? json['date'] ?? json['scheduledAt']),
      examTime: _toStr(json['examTime'] ?? json['time']),
      room: _toStr(json['room']),
      notes: _toStr(json['notes'] ?? json['description']),
    );
  }

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'classId': classId,
    'subjectId': subjectId,
    'examDate': examDate,
    'examTime': examTime,
    'room': room,
    'notes': notes,
  };
}
