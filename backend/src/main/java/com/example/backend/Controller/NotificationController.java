package com.example.backend.Controller;

import com.example.backend.DTO.NotificationDTO;
import com.example.backend.Model.Notification;
import com.example.backend.Service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    // Tạo thông báo mới - Chỉ giáo viên
    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createNotification(
            @RequestBody NotificationDTO.CreateNotificationRequest request,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            Notification createdNotification = notificationService.createNotification(request, teacherId);
            NotificationDTO.NotificationResponse response = NotificationDTO.NotificationResponse.fromEntity(createdNotification);

            Map<String, Object> apiResponse = new HashMap<>();
            apiResponse.put("message", "Tạo thông báo thành công");
            apiResponse.put("status", "success");
            apiResponse.put("data", response);
            return ResponseEntity.ok(apiResponse);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Cập nhật thông báo - Chỉ giáo viên tạo thông báo
    @PutMapping("/update/{notificationId}")
    public ResponseEntity<Map<String, Object>> updateNotification(
            @PathVariable Long notificationId,
            @RequestBody NotificationDTO.UpdateNotificationRequest request,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            Notification updatedNotification = notificationService.updateNotification(notificationId, request, teacherId);
            NotificationDTO.NotificationResponse response = NotificationDTO.NotificationResponse.fromEntity(updatedNotification);

            Map<String, Object> apiResponse = new HashMap<>();
            apiResponse.put("message", "Cập nhật thông báo thành công");
            apiResponse.put("status", "success");
            apiResponse.put("data", response);
            return ResponseEntity.ok(apiResponse);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Xóa thông báo - Chỉ giáo viên tạo thông báo
    @DeleteMapping("/delete/{notificationId}")
    public ResponseEntity<Map<String, Object>> deleteNotification(
            @PathVariable Long notificationId,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            notificationService.deleteNotification(notificationId, teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Xóa thông báo thành công");
            response.put("status", "success");
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy thông tin chi tiết thông báo
    @GetMapping("/{notificationId}")
    public ResponseEntity<Map<String, Object>> getNotificationById(@PathVariable Long notificationId) {
        try {
            Notification notification = notificationService.getNotificationById(notificationId);
            NotificationDTO.NotificationResponse response = NotificationDTO.NotificationResponse.fromEntity(notification);

            Map<String, Object> apiResponse = new HashMap<>();
            apiResponse.put("message", "Lấy thông tin thông báo thành công");
            apiResponse.put("status", "success");
            apiResponse.put("data", response);
            return ResponseEntity.ok(apiResponse);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy danh sách thông báo của giáo viên
    @GetMapping("/teacher/my-notifications")
    public ResponseEntity<Map<String, Object>> getTeacherNotifications(@RequestHeader("User-ID") Long teacherId) {
        try {
            List<Notification> notifications = notificationService.getNotificationsByTeacher(teacherId);
            List<NotificationDTO.NotificationSummary> response = notifications.stream()
                    .map(NotificationDTO.NotificationSummary::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> apiResponse = new HashMap<>();
            apiResponse.put("message", "Lấy danh sách thông báo thành công");
            apiResponse.put("status", "success");
            apiResponse.put("data", response);
            return ResponseEntity.ok(apiResponse);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy danh sách thông báo cho sinh viên
    @GetMapping("/student/my-notifications")
    public ResponseEntity<Map<String, Object>> getStudentNotifications(@RequestHeader("User-ID") Long studentId) {
        try {
            List<Notification> notifications = notificationService.getNotificationsForStudent(studentId);
            List<NotificationDTO.NotificationSummary> response = notifications.stream()
                    .map(NotificationDTO.NotificationSummary::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> apiResponse = new HashMap<>();
            apiResponse.put("message", "Lấy danh sách thông báo thành công");
            apiResponse.put("status", "success");
            apiResponse.put("data", response);
            return ResponseEntity.ok(apiResponse);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy thông báo gần đây cho lớp học
    @GetMapping("/class/{classId}/recent")
    public ResponseEntity<Map<String, Object>> getRecentClassNotifications(
            @PathVariable Long classId,
            @RequestParam(defaultValue = "5") int limit) {
        try {
            List<Notification> notifications = notificationService.getRecentNotificationsForClass(classId, limit);
            List<NotificationDTO.NotificationSummary> response = notifications.stream()
                    .map(NotificationDTO.NotificationSummary::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> apiResponse = new HashMap<>();
            apiResponse.put("message", "Lấy thông báo gần đây thành công");
            apiResponse.put("status", "success");
            apiResponse.put("data", response);
            return ResponseEntity.ok(apiResponse);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy thống kê thông báo của giáo viên
    @GetMapping("/teacher/statistics")
    public ResponseEntity<Map<String, Object>> getNotificationStatistics(@RequestHeader("User-ID") Long teacherId) {
        try {
            Map<String, Object> statistics = notificationService.getNotificationStatistics(teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy thống kê thông báo thành công");
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

    // Đánh dấu thông báo đã hết hạn (có thể chạy scheduled task)
    @PostMapping("/mark-expired")
    public ResponseEntity<Map<String, Object>> markExpiredNotifications() {
        try {
            notificationService.markExpiredNotifications();

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Đánh dấu thông báo hết hạn thành công");
            response.put("status", "success");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lỗi khi đánh dấu thông báo hết hạn");
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }
}