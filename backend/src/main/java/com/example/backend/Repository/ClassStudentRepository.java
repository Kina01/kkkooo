package com.example.backend.Repository;

import com.example.backend.Model.ClassStudent;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClassStudentRepository extends JpaRepository<ClassStudent, Long> {
    
    // Tìm ClassStudent theo lớp và sinh viên
    Optional<ClassStudent> findByClassObjAndStudent(ClassEntity classObj, User student);
    
    // Lấy tất cả ClassStudent theo lớp
    List<ClassStudent> findByClassObj(ClassEntity classObj);
    
    // Lấy tất cả ClassStudent theo sinh viên
    List<ClassStudent> findByStudent(User student);
    
    // Kiểm tra sinh viên đã có trong lớp chưa
    boolean existsByClassObjAndStudent(ClassEntity classObj, User student);
    
    // Tìm theo classId và studentId
    @Query("SELECT cs FROM ClassStudent cs WHERE cs.classObj.classId = :classId AND cs.student.userId = :studentId")
    Optional<ClassStudent> findByClassIdAndStudentId(@Param("classId") Long classId, @Param("studentId") Long studentId);
    
    // Kiểm tra tồn tại theo classId và studentId
    @Query("SELECT COUNT(cs) > 0 FROM ClassStudent cs WHERE cs.classObj.classId = :classId AND cs.student.userId = :studentId")
    boolean existsByClassIdAndStudentId(@Param("classId") Long classId, @Param("studentId") Long studentId);
}