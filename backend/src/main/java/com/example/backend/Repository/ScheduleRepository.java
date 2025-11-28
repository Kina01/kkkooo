package com.example.backend.Repository;

import com.example.backend.Model.Schedule;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    
    // Tìm lịch học theo lớp
    List<Schedule> findByClassObj(ClassEntity classObj);
    
    // Tìm lịch học theo giáo viên
    List<Schedule> findByTeacher(User teacher);
    
    // Tìm lịch học theo tuần và ngày
    @Query("SELECT s FROM Schedule s WHERE :week BETWEEN s.startWeek AND s.endWeek AND s.dayOfWeek = :dayOfWeek")
    List<Schedule> findByWeekAndDay(@Param("week") Integer week, @Param("dayOfWeek") Integer dayOfWeek);
    
    // Tìm lịch học theo lớp và tuần
    @Query("SELECT s FROM Schedule s WHERE s.classObj = :classObj AND :week BETWEEN s.startWeek AND s.endWeek")
    List<Schedule> findByClassAndWeek(@Param("classObj") ClassEntity classObj, @Param("week") Integer week);
    
    // Tìm lịch học theo lớp, ngày và khoảng tuần (để kiểm tra trùng)
    @Query("SELECT s FROM Schedule s WHERE s.classObj = :classObj AND s.dayOfWeek = :dayOfWeek " +
           "AND ((s.startWeek BETWEEN :startWeek AND :endWeek) OR (s.endWeek BETWEEN :startWeek AND :endWeek) " +
           "OR (:startWeek BETWEEN s.startWeek AND s.endWeek) OR (:endWeek BETWEEN s.startWeek AND s.endWeek))")
    List<Schedule> findByClassAndDayAndWeekRange(@Param("classObj") ClassEntity classObj,
                                               @Param("dayOfWeek") Integer dayOfWeek,
                                               @Param("startWeek") Integer startWeek,
                                               @Param("endWeek") Integer endWeek);
}