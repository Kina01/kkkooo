// models/schedule_model.dart
import 'user_model.dart';
import 'subject_model.dart';

/// Class thông tin lớp đơn giản dùng trong lịch
class ClassSimple {
  final int classId;
  final String classCode;
  final String className;
  final String description;

  ClassSimple({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.description,
  });

  factory ClassSimple.fromJson(Map<String, dynamic> json) {
    return ClassSimple(
      classId: json['classId'] ?? 0,
      classCode: json['classCode'] ?? '',
      className: json['className'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

/// Item lịch học (mapping với ScheduleResponse bên BE)
class ScheduleItem {
  final int scheduleId;
  final String room;
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final String startTime;
  final String endTime;
  final int totalPeriods;
  final int startWeek;
  final int endWeek;
  final String session; // MORNING / AFTERNOON / EVENING
  final String timeDescription;

  final Subject? subject;      // từ SubjectResponse
  final ClassSimple? classInfo; // từ ClassSimpleDTO
  final User? teacher;         // từ UserDTO

  ScheduleItem({
    required this.scheduleId,
    required this.room,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.startTime,
    required this.endTime,
    required this.totalPeriods,
    required this.startWeek,
    required this.endWeek,
    required this.session,
    required this.timeDescription,
    this.subject,
    this.classInfo,
    this.teacher,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      scheduleId: json['scheduleId'] ?? 0,
      room: json['room'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? 2,
      startPeriod: json['startPeriod'] ?? 1,
      endPeriod: json['endPeriod'] ?? 1,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      totalPeriods: json['totalPeriods'] ?? 0,
      startWeek: json['startWeek'] ?? 1,
      endWeek: json['endWeek'] ?? 1,
      session: json['session'] ?? '',
      timeDescription: json['timeDescription'] ?? '',
      subject: json['subject'] != null
          ? Subject.fromJson(json['subject'])
          : null,
      classInfo: json['classInfo'] != null
          ? ClassSimple.fromJson(json['classInfo'])
          : null,
      teacher:
          json['teacher'] != null ? User.fromJson(json['teacher']) : null,
    );
  }
}

/// Request tạo lịch học (mapping với ScheduleDTO.CreateScheduleRequest)
class CreateScheduleRequest {
  final int subjectId;
  final String room;
  final int dayOfWeek;   // 2..7
  final int startPeriod; // 1..10
  final int endPeriod;   // 1..10
  final int startWeek;   // 1..n
  final int endWeek;     // 1..n

  CreateScheduleRequest({
    required this.subjectId,
    required this.room,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.startWeek,
    required this.endWeek,
  });

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
      'startWeek': startWeek,
      'endWeek': endWeek,
    };
  }
}


class UpdateScheduleRequest {
  final int subjectId;
  final String room;
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final int startWeek;
  final int endWeek;

  UpdateScheduleRequest({
    required this.subjectId,
    required this.room,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.startWeek,
    required this.endWeek,
  });

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
      'startWeek': startWeek,
      'endWeek': endWeek,
    };
  }
}