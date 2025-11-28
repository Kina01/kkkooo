package com.example.backend.Service;

import com.example.backend.Model.Grade;
import com.example.backend.DTO.GradeDTO;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.User;
import com.example.backend.Model.Subject;
import com.example.backend.Repository.GradeRepository;
import com.example.backend.Repository.ClassRepository;
import com.example.backend.Repository.UserRepository;
import com.example.backend.Repository.SubjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class GradeService {

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private ClassRepository classRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubjectRepository subjectRepository; // Đã có repository

    // Thêm/chấm điểm cho sinh viên
    @Transactional
    public Grade addOrUpdateGrade(Long classId, Long studentId, Long subjectId,
            Double processScore, Double midtermScore, String comments, Long teacherId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học"));

        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sinh viên"));

        Subject subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học"));

        // Kiểm tra giáo viên có quyền chấm điểm cho lớp này không
        if (!classEntity.getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền chấm điểm cho lớp này");
        }

        // Kiểm tra sinh viên có trong lớp không
        boolean isStudentInClass = classEntity.getClassStudents().stream()
                .anyMatch(cs -> cs.getStudent().getUserId().equals(studentId));
        if (!isStudentInClass) {
            throw new RuntimeException("Sinh viên không có trong lớp học này");
        }

        // Tìm điểm hiện có hoặc tạo mới
        Optional<Grade> existingGrade = gradeRepository.findByStudentAndClassObjAndSubject(student, classEntity,
                subject);
        Grade grade;

        if (existingGrade.isPresent()) {
            grade = existingGrade.get();
            grade.setProcessScore(processScore);
            grade.setMidtermScore(midtermScore);
            grade.setComments(comments);
        } else {
            grade = new Grade();
            grade.setClassObj(classEntity);
            grade.setStudent(student);
            grade.setSubject(subject);
            grade.setProcessScore(processScore);
            grade.setMidtermScore(midtermScore);
            grade.setComments(comments);
        }

        return gradeRepository.save(grade);
    }

    // Lấy điểm theo lớp
    @Transactional(readOnly = true)
    public List<Grade> getGradesByClass(Long classId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học"));
        return gradeRepository.findByClassObj(classEntity);
    }

    // Lấy điểm của sinh viên
    @Transactional(readOnly = true)
    public List<Grade> getStudentGrades(Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sinh viên"));
        return gradeRepository.findByStudent(student);
    }

    // Lấy điểm của sinh viên trong lớp cụ thể
    @Transactional(readOnly = true)
    public List<Grade> getStudentGradesInClass(Long studentId, Long classId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sinh viên"));
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học"));
        return gradeRepository.findByStudentAndClassObj(student, classEntity);
    }

    // Lấy điểm trung bình của lớp
    @Transactional(readOnly = true)
    public Double getClassAverageScore(Long classId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học"));
        return gradeRepository.findAverageScoreByClass(classEntity);
    }

    // Chấm điểm hàng loạt
    @Transactional
    public List<Grade> batchUpdateGrades(Long classId, Long subjectId,
            List<GradeDTO.GradeUpdateRequest> gradeRequests, Long teacherId) {
        return gradeRequests.stream()
                .map(request -> addOrUpdateGrade(classId, request.getStudentId(), subjectId,
                        request.getProcessScore(), request.getMidtermScore(), request.getComments(), teacherId))
                .collect(Collectors.toList());
    }
}
