// lib/models/attendance_model.dart
import 'user_model.dart';

enum AttendanceStatus { PRESENT, LATE, ABSENT, EXCUSED }

AttendanceStatus attendanceStatusFromString(String? s) {
  if (s == null) return AttendanceStatus.ABSENT;
  switch (s.toUpperCase()) {
    case 'PRESENT': return AttendanceStatus.PRESENT;
    case 'LATE': return AttendanceStatus.LATE;
    case 'EXCUSED': return AttendanceStatus.EXCUSED;
    case 'ABSENT':
    default: return AttendanceStatus.ABSENT;
  }
}

String attendanceStatusToString(AttendanceStatus s) {
  return s.toString().split('.').last;
}

class Attendance {
  final int attendanceId;
  final int classId;
  final int studentId;
  final String studentName;
  final AttendanceStatus status;
  final String? notes;
  final String date; // ISO date string

  Attendance({
    required this.attendanceId,
    required this.classId,
    required this.studentId,
    required this.studentName,
    required this.status,
    this.notes,
    required this.date,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    String _toStr(dynamic v) => v == null ? '' : v.toString();

    return Attendance(
      attendanceId: _toInt(json['attendanceId'] ?? json['id']),
      classId: _toInt(json['classId'] ?? json['classObj']?['classId']),
      studentId: _toInt(json['studentId'] ?? json['student']?['userId']),
      studentName: _toStr(json['studentName'] ?? json['student']?['fullName']),
      status: attendanceStatusFromString(_toStr(json['status'] ?? json['attendanceStatus'])),
      notes: json['notes']?.toString(),
      date: _toStr(json['date'] ?? json['createdAt'] ?? json['attendanceDate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'attendanceId': attendanceId,
    'classId': classId,
    'studentId': studentId,
    'studentName': studentName,
    'status': attendanceStatusToString(status),
    'notes': notes,
    'date': date,
  };
}
