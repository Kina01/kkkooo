package com.example.backend.Repository;

import com.example.backend.Model.Subject;
import com.example.backend.Model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SubjectRepository extends JpaRepository<Subject, Long> {
    
    Optional<Subject> findBySubjectCode(String subjectCode);
    
    boolean existsBySubjectCode(String subjectCode);
    
    Optional<Subject> findBySubjectNameContainingIgnoreCase(String subjectName);
    
    // Tìm subject theo người tạo
    List<Subject> findByCreatedBy(User createdBy);
    
    // Tìm subject theo mã và người tạo (để kiểm tra trùng)
    boolean existsBySubjectCodeAndCreatedBy(String subjectCode, User createdBy);
    
    // Tìm subject theo tên và người tạo
    @Query("SELECT s FROM Subject s WHERE LOWER(s.subjectName) LIKE LOWER(CONCAT('%', :subjectName, '%')) AND s.createdBy = :createdBy")
    List<Subject> findBySubjectNameContainingIgnoreCaseAndCreatedBy(@Param("subjectName") String subjectName, 
                                                                   @Param("createdBy") User createdBy);
}