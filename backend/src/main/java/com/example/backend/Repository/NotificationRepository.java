package com.example.backend.Repository;

import com.example.backend.Model.Notification;
import com.example.backend.Model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    
    // Tìm thông báo theo giáo viên
    List<Notification> findByTeacherOrderByCreatedAtDesc(User teacher);
    
    // Tìm thông báo theo trạng thái
    List<Notification> findByStatusOrderByCreatedAtDesc(Notification.NotificationStatus status);
    
    // Tìm thông báo theo giáo viên và trạng thái
    List<Notification> findByTeacherAndStatusOrderByCreatedAtDesc(User teacher, Notification.NotificationStatus status);
    
    // Tìm thông báo sắp tới (scheduled trong tương lai)
    @Query("SELECT n FROM Notification n WHERE n.scheduledAt > :now AND n.status = 'ACTIVE' ORDER BY n.scheduledAt ASC")
    List<Notification> findUpcomingNotifications(@Param("now") LocalDateTime now);
    
    // Tìm thông báo đã hết hạn
    @Query("SELECT n FROM Notification n WHERE n.scheduledAt < :now AND n.status = 'ACTIVE'")
    List<Notification> findExpiredNotifications(@Param("now") LocalDateTime now);
    
    // Đếm số thông báo theo giáo viên
    Long countByTeacher(User teacher);
}