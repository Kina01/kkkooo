package com.example.backend.DTO;

import com.example.backend.Model.Attendance;
import com.example.backend.Model.Schedule;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class AttendanceDTO {

    // DTO cho điểm danh
    @Data
    public static class TakeAttendanceRequest {
        private LocalDate date;
        private java.util.Map<Long, Attendance.AttendanceStatus> attendanceMap;
    }

    // DTO cho cập nhật điểm danh
    @Data
    public static class UpdateAttendanceRequest {
        private Attendance.AttendanceStatus status;
        private String notes;
    }

    // DTO cho response điểm danh
    @Data
    public static class AttendanceResponse {
        private Long attendanceId;
        private Long classId;
        private String classCode;
        private Long studentId;
        private String studentEmail;
        private String studentFullName;
        private Long scheduleId;
        private Integer dayOfWeek;
        private LocalDate attendanceDate;
        private Attendance.AttendanceStatus status;
        private String notes;
        private LocalDateTime createdAt;

        public static AttendanceResponse fromEntity(Attendance a) {
            AttendanceResponse r = new AttendanceResponse();
            r.setAttendanceId(a.getAttendanceId());
            if (a.getClassObj() != null) {
                r.setClassId(a.getClassObj().getClassId());
                r.setClassCode(a.getClassObj().getClassCode());
            }
            if (a.getStudent() != null) {
                r.setStudentId(a.getStudent().getUserId());
                r.setStudentEmail(a.getStudent().getEmail());
                r.setStudentFullName(a.getStudent().getFullName());
            }
            if (a.getSchedule() != null) {
                Schedule s = a.getSchedule();
                r.setScheduleId(s.getScheduleId());
                r.setDayOfWeek(s.getDayOfWeek());
            }
            r.setAttendanceDate(a.getAttendanceDate());
            r.setStatus(a.getStatus());
            r.setNotes(a.getNotes());
            r.setCreatedAt(a.getCreatedAt());
            return r;
        }
    }
}
