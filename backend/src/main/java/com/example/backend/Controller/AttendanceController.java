package com.example.backend.Controller;

import com.example.backend.DTO.AttendanceDTO;
import com.example.backend.Model.Attendance;
import com.example.backend.Service.AttendanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/attendances")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class AttendanceController {

    @Autowired
    private AttendanceService attendanceService;

    // Điểm danh cho buổi học
    @PostMapping("/class/{classId}/schedule/{scheduleId}")
    public ResponseEntity<Map<String, Object>> takeAttendance(
            @PathVariable Long classId,
            @PathVariable Long scheduleId,
            @RequestBody AttendanceDTO.TakeAttendanceRequest request,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            List<Attendance> attendances = attendanceService.takeAttendance(
                    classId, scheduleId, request.getDate(), request.getAttendanceMap(), teacherId);

            List<AttendanceDTO.AttendanceResponse> dtoList = attendances.stream()
                    .map(AttendanceDTO.AttendanceResponse::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Điểm danh thành công");
            response.put("status", "success");
            response.put("data", dtoList);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy điểm danh theo lớp và ngày
    @GetMapping("/class/{classId}")
    public ResponseEntity<Map<String, Object>> getAttendanceByClassAndDate(
            @PathVariable Long classId,
            @RequestParam @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate date) {
        try {
            List<Attendance> attendances = attendanceService.getAttendanceByClassAndDate(classId, date);

            List<AttendanceDTO.AttendanceResponse> dtoList = attendances.stream()
                    .map(AttendanceDTO.AttendanceResponse::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy danh sách điểm danh thành công");
            response.put("status", "success");
            response.put("data", dtoList);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy lịch sử điểm danh của sinh viên
    @GetMapping("/student/{studentId}/class/{classId}")
    public ResponseEntity<Map<String, Object>> getStudentAttendanceHistory(
            @PathVariable Long studentId,
            @PathVariable Long classId) {
        try {
            List<Attendance> attendances = attendanceService.getStudentAttendanceHistory(studentId, classId);

            List<AttendanceDTO.AttendanceResponse> dtoList = attendances.stream()
                    .map(AttendanceDTO.AttendanceResponse::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy lịch sử điểm danh thành công");
            response.put("status", "success");
            response.put("data", dtoList);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Thống kê điểm danh
    @GetMapping("/class/{classId}/statistics")
    public ResponseEntity<Map<String, Object>> getAttendanceStatistics(@PathVariable Long classId) {
        try {
            Map<Attendance.AttendanceStatus, Long> statistics = attendanceService.getAttendanceStatistics(classId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy thống kê điểm danh thành công");
            response.put("status", "success");
            response.put("data", statistics);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Cập nhật điểm danh cá nhân
    @PutMapping("/{attendanceId}")
    public ResponseEntity<Map<String, Object>> updateAttendance(
            @PathVariable Long attendanceId,
            @RequestBody AttendanceDTO.UpdateAttendanceRequest request,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            Attendance attendance = attendanceService.updateAttendance(
                    attendanceId, request.getStatus(), request.getNotes(), teacherId);

            AttendanceDTO.AttendanceResponse dto = AttendanceDTO.AttendanceResponse.fromEntity(attendance);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Cập nhật điểm danh thành công");
            response.put("status", "success");
            response.put("data", dto);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }
}
