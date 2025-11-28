package com.example.backend.Repository;

import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClassRepository extends JpaRepository<ClassEntity, Long> {
    
    // Tìm lớp theo mã lớp
    Optional<ClassEntity> findByClassCode(String classCode);
    
    // Kiểm tra mã lớp đã tồn tại chưa
    boolean existsByClassCode(String classCode);
    
    // Tìm tất cả lớp do giáo viên quản lý
    List<ClassEntity> findByTeacher(User teacher);
    
    // Tìm lớp theo mã lớp và giáo viên (để đảm bảo giáo viên chỉ sửa/xóa lớp của mình)
    Optional<ClassEntity> findByClassCodeAndTeacher(String classCode, User teacher);
    
    // Tìm lớp mà sinh viên đã đăng ký
    @Query("SELECT c FROM ClassEntity c JOIN c.classStudents cs WHERE cs.student = :student")
    List<ClassEntity> findByStudentEnrolled(@Param("student") User student);
}