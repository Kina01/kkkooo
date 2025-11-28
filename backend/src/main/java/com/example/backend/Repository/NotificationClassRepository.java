package com.example.backend.Repository;

import com.example.backend.Model.NotificationClass;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.Notification;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationClassRepository extends JpaRepository<NotificationClass, Long> {
    
    // Tìm theo lớp học
    List<NotificationClass> findByClassObj(ClassEntity classObj);
    
    // Tìm theo thông báo
    List<NotificationClass> findByNotification(Notification notification);
    
    // Tìm thông báo theo lớp học (cho sinh viên)
    @Query("SELECT nc FROM NotificationClass nc WHERE nc.classObj.classId IN :classIds ORDER BY nc.notification.createdAt DESC")
    List<NotificationClass> findByClassIds(@Param("classIds") List<Long> classIds);
    
    // Tìm thông báo gần đây theo lớp
    @Query("SELECT nc FROM NotificationClass nc WHERE nc.classObj.classId = :classId ORDER BY nc.notification.createdAt DESC")
    List<NotificationClass> findRecentByClassId(@Param("classId") Long classId, Pageable pageable);
}