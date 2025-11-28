package com.example.backend.Service;

import com.example.backend.Model.Exam;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.User;
import com.example.backend.Repository.ExamRepository;
import com.example.backend.Repository.ClassRepository;
import com.example.backend.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ExamService {

    @Autowired
    private ExamRepository examRepository;

    @Autowired
    private ClassRepository classRepository;

    @Autowired
    private UserRepository userRepository;

    // Tạo lịch thi mới
    @Transactional
    public Exam createExam(Exam exam, Long classId, Long teacherId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp"));

        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));

        // Kiểm tra giáo viên có quyền thêm lịch thi cho lớp này không
        if (!classEntity.getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền thêm lịch thi cho lớp này");
        }

        exam.setClassObj(classEntity);
        return examRepository.save(exam);
    }

    // Cập nhật lịch thi
    @Transactional
    public Exam updateExam(Long examId, Exam examDetails, Long teacherId) {
        Exam existingExam = examRepository.findById(examId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch thi"));

        // Kiểm tra giáo viên có quyền sửa lịch thi này không
        if (!existingExam.getClassObj().getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền sửa lịch thi này");
        }

        existingExam.setSubject(examDetails.getSubject());
        existingExam.setExamDate(examDetails.getExamDate());
        existingExam.setExamTime(examDetails.getExamTime());
        existingExam.setRoom(examDetails.getRoom());
        existingExam.setNotes(examDetails.getNotes());

        return examRepository.save(existingExam);
    }

    // Xóa lịch thi
    @Transactional
    public void deleteExam(Long examId, Long teacherId) {
        Exam exam = examRepository.findById(examId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch thi"));

        // Kiểm tra giáo viên có quyền xóa lịch thi này không
        if (!exam.getClassObj().getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền xóa lịch thi này");
        }

        examRepository.delete(exam);
    }

    // Lấy lịch thi theo lớp
    @Transactional(readOnly = true)
    public List<Exam> getExamsByClass(Long classId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp"));
        return examRepository.findByClassObj(classEntity);
    }

    // Lấy tất cả lịch thi của giáo viên
    @Transactional(readOnly = true)
    public List<Exam> getExamsByTeacher(Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));
        
        // Lấy tất cả lớp của giáo viên
        List<ClassEntity> teacherClasses = classRepository.findByTeacher(teacher);
        
        // Lấy tất cả lịch thi của các lớp đó
        return teacherClasses.stream()
                .flatMap(classEntity -> examRepository.findByClassObj(classEntity).stream())
                .toList();
    }
}
