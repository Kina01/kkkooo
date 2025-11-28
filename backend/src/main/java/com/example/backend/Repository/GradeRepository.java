package com.example.backend.Repository;

import com.example.backend.Model.Grade;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.User;
import com.example.backend.Model.Subject;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GradeRepository extends JpaRepository<Grade, Long> {
    
    // Tìm điểm theo lớp
    List<Grade> findByClassObj(ClassEntity classObj);
    
    // Tìm điểm theo sinh viên
    List<Grade> findByStudent(User student);
    
    // Tìm điểm theo sinh viên và lớp
    List<Grade> findByStudentAndClassObj(User student, ClassEntity classObj);
    
    // Tìm điểm theo sinh viên và môn học
    List<Grade> findByStudentAndSubject(User student, Subject subject);
    
    // Tìm điểm cụ thể theo sinh viên, lớp và môn học
    Optional<Grade> findByStudentAndClassObjAndSubject(User student, ClassEntity classObj, Subject subject);
    
    // Thống kê điểm trung bình theo lớp
    @Query("SELECT AVG((g.processScore + g.midtermScore) / 2) FROM Grade g WHERE g.classObj = :classObj")
    Double findAverageScoreByClass(@Param("classObj") ClassEntity classObj);
    
    // Lấy điểm theo lớp và môn học
    List<Grade> findByClassObjAndSubject(ClassEntity classObj, Subject subject);
}