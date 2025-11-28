package com.example.backend.Repository;

import com.example.backend.Model.Attendance;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.Schedule;
import com.example.backend.Model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, Long> {
    
    // Tìm điểm danh theo lớp và ngày
    List<Attendance> findByClassObjAndAttendanceDate(ClassEntity classObj, LocalDate attendanceDate);
    
    // Tìm điểm danh theo sinh viên và lớp
    List<Attendance> findByStudentAndClassObj(User student, ClassEntity classObj);
    
    // Tìm điểm danh theo buổi học
    List<Attendance> findBySchedule(Schedule schedule);
    
    // Tìm điểm danh theo sinh viên, lớp và ngày
    Optional<Attendance> findByStudentAndClassObjAndAttendanceDate(User student, ClassEntity classObj, LocalDate attendanceDate);
    
    // Tìm điểm danh theo schedule và date (hữu ích cho upsert hoặc kiểm tra tồn tại)
    List<Attendance> findByScheduleAndAttendanceDate(Schedule schedule, LocalDate attendanceDate);

    // Xóa điểm danh theo schedule và ngày (thay vì xóa toàn bộ theo schedule)
    @Modifying
    @Transactional
    @Query("DELETE FROM Attendance a WHERE a.schedule = :schedule AND a.attendanceDate = :date")
    void deleteByScheduleAndAttendanceDate(@Param("schedule") Schedule schedule, @Param("date") LocalDate date);
    
    // Thống kê điểm danh theo lớp
    @Query("SELECT a.status, COUNT(a) FROM Attendance a WHERE a.classObj = :classObj GROUP BY a.status")
    List<Object[]> countAttendanceByStatus(@Param("classObj") ClassEntity classObj);
    
    // Lấy điểm danh theo lớp và khoảng thời gian
    @Query("SELECT a FROM Attendance a WHERE a.classObj = :classObj AND a.attendanceDate BETWEEN :startDate AND :endDate")
    List<Attendance> findByClassAndDateRange(@Param("classObj") ClassEntity classObj, 
                                           @Param("startDate") LocalDate startDate, 
                                           @Param("endDate") LocalDate endDate);
}
