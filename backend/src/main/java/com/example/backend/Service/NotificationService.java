package com.example.backend.Service;

import com.example.backend.DTO.NotificationDTO;
import com.example.backend.Model.*;
import com.example.backend.Repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private NotificationClassRepository notificationClassRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClassRepository classRepository;

    @Autowired
    private ClassStudentRepository classStudentRepository;

    // Tạo thông báo mới
    @Transactional
    public Notification createNotification(NotificationDTO.CreateNotificationRequest request, Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));

        // Kiểm tra người dùng có phải là giáo viên không
        if (teacher.getRole() != User.Role.TEACHER) {
            throw new RuntimeException("Chỉ giáo viên được phép tạo thông báo");
        }

        // Kiểm tra danh sách lớp học
        if (request.getClassIds() == null || request.getClassIds().isEmpty()) {
            throw new RuntimeException("Phải chọn ít nhất một lớp học");
        }

        // Tạo thông báo
        Notification notification = new Notification();
        notification.setTeacher(teacher);
        notification.setTitle(request.getTitle());
        notification.setContent(request.getContent());
        notification.setScheduledAt(request.getScheduledAt() != null ? request.getScheduledAt() : LocalDateTime.now());
        notification.setType(request.getType() != null ? request.getType() : Notification.NotificationType.OTHER);

        // Lưu thông báo
        Notification savedNotification = notificationRepository.save(notification);

        // Thêm các lớp học nhận thông báo
        for (Long classId : request.getClassIds()) {
            ClassEntity classEntity = classRepository.findById(classId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học với ID: " + classId));

            // Kiểm tra giáo viên có quyền gửi thông báo cho lớp này không
            if (!classEntity.getTeacher().getUserId().equals(teacherId)) {
                throw new RuntimeException("Bạn không có quyền gửi thông báo cho lớp: " + classEntity.getClassName());
            }

            NotificationClass notificationClass = new NotificationClass();
            notificationClass.setNotification(savedNotification);
            notificationClass.setClassObj(classEntity);

            notificationClassRepository.save(notificationClass);
        }

        return savedNotification;
    }

    // Cập nhật thông báo
    @Transactional
    public Notification updateNotification(Long notificationId, NotificationDTO.UpdateNotificationRequest request, Long teacherId) {
        Notification existingNotification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));

        // Kiểm tra giáo viên có quyền sửa thông báo này không
        if (!existingNotification.getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền sửa thông báo này");
        }

        // Cập nhật thông tin cơ bản
        if (request.getTitle() != null) {
            existingNotification.setTitle(request.getTitle());
        }
        if (request.getContent() != null) {
            existingNotification.setContent(request.getContent());
        }
        if (request.getScheduledAt() != null) {
            existingNotification.setScheduledAt(request.getScheduledAt());
        }
        if (request.getStatus() != null) {
            existingNotification.setStatus(request.getStatus());
        }
        if (request.getType() != null) {
            existingNotification.setType(request.getType());
        }

        // Cập nhật danh sách lớp học nếu có
        if (request.getClassIds() != null) {
            // Xóa các lớp cũ
            List<NotificationClass> existingClasses = notificationClassRepository.findByNotification(existingNotification);
            notificationClassRepository.deleteAll(existingClasses);

            // Thêm các lớp mới
            for (Long classId : request.getClassIds()) {
                ClassEntity classEntity = classRepository.findById(classId)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học với ID: " + classId));

                // Kiểm tra quyền
                if (!classEntity.getTeacher().getUserId().equals(teacherId)) {
                    throw new RuntimeException("Bạn không có quyền gửi thông báo cho lớp: " + classEntity.getClassName());
                }

                NotificationClass notificationClass = new NotificationClass();
                notificationClass.setNotification(existingNotification);
                notificationClass.setClassObj(classEntity);

                notificationClassRepository.save(notificationClass);
            }
        }

        return notificationRepository.save(existingNotification);
    }

    // Xóa thông báo
    @Transactional
    public void deleteNotification(Long notificationId, Long teacherId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));

        // Kiểm tra giáo viên có quyền xóa thông báo này không
        if (!notification.getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền xóa thông báo này");
        }

        notificationRepository.delete(notification);
    }

    // Lấy thông báo theo ID
    @Transactional(readOnly = true)
    public Notification getNotificationById(Long notificationId) {
        return notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));
    }

    // Lấy tất cả thông báo của giáo viên
    @Transactional(readOnly = true)
    public List<Notification> getNotificationsByTeacher(Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));
        return notificationRepository.findByTeacherOrderByCreatedAtDesc(teacher);
    }

    // Lấy thông báo theo trạng thái
    @Transactional(readOnly = true)
    public List<Notification> getNotificationsByStatus(Notification.NotificationStatus status) {
        return notificationRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    // Lấy thông báo của sinh viên (dựa trên các lớp sinh viên đang học)
    @Transactional(readOnly = true)
    public List<Notification> getNotificationsForStudent(Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sinh viên"));

        // Lấy danh sách lớp học của sinh viên
        List<Long> classIds = classStudentRepository.findByStudent(student).stream()
                .map(classStudent -> classStudent.getClassObj().getClassId())
                .collect(Collectors.toList());

        if (classIds.isEmpty()) {
            return List.of();
        }

        // Lấy thông báo cho các lớp này
        List<NotificationClass> notificationClasses = notificationClassRepository.findByClassIds(classIds);
        
        return notificationClasses.stream()
                .map(NotificationClass::getNotification)
                .distinct()
                .sorted((n1, n2) -> n2.getCreatedAt().compareTo(n1.getCreatedAt()))
                .collect(Collectors.toList());
    }

    // Lấy thông báo gần đây cho lớp học
    @Transactional(readOnly = true)
    public List<Notification> getRecentNotificationsForClass(Long classId, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        
        List<NotificationClass> notificationClasses = 
            notificationClassRepository.findRecentByClassId(classId, pageable);
        
        return notificationClasses.stream()
                .map(NotificationClass::getNotification)
                .collect(Collectors.toList());
    }

    // Đánh dấu thông báo đã hết hạn
    @Transactional
    public void markExpiredNotifications() {
        List<Notification> expiredNotifications = notificationRepository.findExpiredNotifications(LocalDateTime.now());
        
        for (Notification notification : expiredNotifications) {
            notification.setStatus(Notification.NotificationStatus.EXPIRED);
        }
        
        notificationRepository.saveAll(expiredNotifications);
    }

    // Lấy thống kê thông báo của giáo viên
    @Transactional(readOnly = true)
    public Map<String, Object> getNotificationStatistics(Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));

        Long totalNotifications = notificationRepository.countByTeacher(teacher);
        List<Notification> activeNotifications = notificationRepository.findByTeacherAndStatusOrderByCreatedAtDesc(teacher, 
                Notification.NotificationStatus.ACTIVE);
        List<Notification> expiredNotifications = notificationRepository.findByTeacherAndStatusOrderByCreatedAtDesc(teacher, 
                Notification.NotificationStatus.EXPIRED);

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalNotifications", totalNotifications);
        stats.put("activeNotifications", (long) activeNotifications.size());
        stats.put("expiredNotifications", (long) expiredNotifications.size());
        stats.put("inactiveNotifications", totalNotifications - activeNotifications.size() - expiredNotifications.size());

        return stats;
    }
}
