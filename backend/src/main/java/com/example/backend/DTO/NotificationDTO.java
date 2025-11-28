package com.example.backend.DTO;

import com.example.backend.Model.Notification;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class NotificationDTO {

    // DTO cho tạo thông báo
    @Data
    public static class CreateNotificationRequest {
        private String title;
        private String content;
        private LocalDateTime scheduledAt;
        private Notification.NotificationType type;
        private List<Long> classIds;
    }

    // DTO cho cập nhật thông báo
    @Data
    public static class UpdateNotificationRequest {
        private String title;
        private String content;
        private LocalDateTime scheduledAt;
        private Notification.NotificationStatus status;
        private Notification.NotificationType type;
        private List<Long> classIds;
    }

    // DTO cho response thông báo
    @Data
    public static class NotificationResponse {
        private Long notificationId;
        private String title;
        private String content;
        private LocalDateTime createdAt;
        private LocalDateTime scheduledAt;
        private Notification.NotificationStatus status;
        private Notification.NotificationType type;
        private UserDTO teacher;
        private List<ClassSimpleDTO> targetClasses;
        private Integer totalClasses;

        public static NotificationResponse fromEntity(Notification notification) {
            NotificationResponse response = new NotificationResponse();
            response.setNotificationId(notification.getNotificationId());
            response.setTitle(notification.getTitle());
            response.setContent(notification.getContent());
            response.setCreatedAt(notification.getCreatedAt());
            response.setScheduledAt(notification.getScheduledAt());
            response.setStatus(notification.getStatus());
            response.setType(notification.getType());
            
            // Thông tin giáo viên
            if (notification.getTeacher() != null) {
                response.setTeacher(UserDTO.fromEntity(notification.getTeacher()));
            }
            
            // Danh sách lớp học nhận thông báo
            if (notification.getTargetClasses() != null) {
                response.setTargetClasses(notification.getTargetClasses().stream()
                        .map(notificationClass -> ClassSimpleDTO.fromEntity(notificationClass.getClassObj()))
                        .toList());
                response.setTotalClasses(notification.getTargetClasses().size());
            } else {
                response.setTotalClasses(0);
            }
            
            return response;
        }
    }

    // DTO cho thông báo tóm tắt (dùng cho danh sách)
    @Data
    public static class NotificationSummary {
        private Long notificationId;
        private String title;
        private String contentPreview;
        private LocalDateTime createdAt;
        private LocalDateTime scheduledAt;
        private Notification.NotificationStatus status;
        private Notification.NotificationType type;
        private String teacherName;
        private Integer totalClasses;

        public static NotificationSummary fromEntity(Notification notification) {
            NotificationSummary summary = new NotificationSummary();
            summary.setNotificationId(notification.getNotificationId());
            summary.setTitle(notification.getTitle());
            
            // Tạo preview cho content (giới hạn 100 ký tự)
            if (notification.getContent() != null && notification.getContent().length() > 100) {
                summary.setContentPreview(notification.getContent().substring(0, 100) + "...");
            } else {
                summary.setContentPreview(notification.getContent());
            }
            
            summary.setCreatedAt(notification.getCreatedAt());
            summary.setScheduledAt(notification.getScheduledAt());
            summary.setStatus(notification.getStatus());
            summary.setType(notification.getType());
            
            if (notification.getTeacher() != null) {
                summary.setTeacherName(notification.getTeacher().getFullName());
            }
            
            if (notification.getTargetClasses() != null) {
                summary.setTotalClasses(notification.getTargetClasses().size());
            } else {
                summary.setTotalClasses(0);
            }
            
            return summary;
        }
    }
}