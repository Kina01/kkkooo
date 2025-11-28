package com.example.backend.Repository;

import com.example.backend.Model.Exam;
import com.example.backend.Model.ClassEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamRepository extends JpaRepository<Exam, Long> {
    
    // Tìm lịch thi theo lớp
    List<Exam> findByClassObj(ClassEntity classObj);
    
    // Tìm lịch thi theo môn học
    // List<Exam> findBySubject(Subject subject);
}