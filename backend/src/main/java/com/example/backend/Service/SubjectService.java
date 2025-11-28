package com.example.backend.Service;

import com.example.backend.DTO.SubjectDTO;
import com.example.backend.Model.Subject;
import com.example.backend.Model.User;
import com.example.backend.Repository.SubjectRepository;
import com.example.backend.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SubjectService {

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private UserRepository userRepository;

    // Tạo môn học mới - chỉ giáo viên được tạo
    @Transactional
    public Subject createSubject(SubjectDTO.CreateSubjectRequest request, Long teacherId) {
        // Lấy thông tin giáo viên
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));

        // Kiểm tra người dùng có phải là giáo viên không
        if (teacher.getRole() != User.Role.TEACHER) {
            throw new RuntimeException("Chỉ giáo viên được phép tạo môn học");
        }

        // Kiểm tra mã môn học đã tồn tại chưa
        if (subjectRepository.existsBySubjectCode(request.getSubjectCode())) {
            throw new RuntimeException("Mã môn học đã tồn tại: " + request.getSubjectCode());
        }

        Subject subject = new Subject();
        subject.setSubjectCode(request.getSubjectCode());
        subject.setSubjectName(request.getSubjectName());
        subject.setCredits(request.getCredits());
        // Lưu thông tin giáo viên tạo
        subject.setCreatedBy(teacher);

        return subjectRepository.save(subject);
    }

    // Cập nhật môn học - chỉ giáo viên tạo môn đó được sửa
    @Transactional
    public Subject updateSubject(Long subjectId, SubjectDTO.UpdateSubjectRequest request, Long teacherId) {
        Subject existingSubject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học"));

        // Kiểm tra giáo viên có quyền sửa môn học này không
        if (!existingSubject.getCreatedBy().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền sửa môn học này");
        }

        // Kiểm tra mã môn học mới không trùng với môn khác
        if (!existingSubject.getSubjectCode().equals(request.getSubjectCode()) &&
                subjectRepository.existsBySubjectCode(request.getSubjectCode())) {
            throw new RuntimeException("Mã môn học đã tồn tại: " + request.getSubjectCode());
        }

        existingSubject.setSubjectCode(request.getSubjectCode());
        existingSubject.setSubjectName(request.getSubjectName());
        existingSubject.setCredits(request.getCredits());

        return subjectRepository.save(existingSubject);
    }

    // Xóa môn học - chỉ giáo viên tạo môn đó được xóa
    @Transactional
    public void deleteSubject(Long subjectId, Long teacherId) {
        Subject subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học"));

        // Kiểm tra giáo viên có quyền xóa môn học này không
        if (!subject.getCreatedBy().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền xóa môn học này");
        }

        subjectRepository.delete(subject);
    }

    // Lấy tất cả môn học (tất cả giáo viên đều xem được)
    @Transactional(readOnly = true)
    public List<SubjectDTO.SubjectResponse> getAllSubjects() {
        return subjectRepository.findAll().stream()
                .map(SubjectDTO.SubjectResponse::fromEntity)
                .collect(Collectors.toList());
    }

    // Lấy môn học theo ID
    @Transactional(readOnly = true)
    public SubjectDTO.SubjectResponse getSubjectById(Long subjectId) {
        Subject subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học"));
        return SubjectDTO.SubjectResponse.fromEntity(subject);
    }

    // Lấy môn học do giáo viên tạo
    @Transactional(readOnly = true)
    public List<SubjectDTO.SubjectResponse> getSubjectsByTeacher(Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));
        
        return subjectRepository.findByCreatedBy(teacher).stream()
                .map(SubjectDTO.SubjectResponse::fromEntity)
                .collect(Collectors.toList());
    }

    // Tìm môn học theo mã
    @Transactional(readOnly = true)
    public SubjectDTO.SubjectResponse getSubjectByCode(String subjectCode) {
        Subject subject = subjectRepository.findBySubjectCode(subjectCode)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học với mã: " + subjectCode));
        return SubjectDTO.SubjectResponse.fromEntity(subject);
    }

    // Tìm môn học theo tên (tìm kiếm toàn hệ thống)
    @Transactional(readOnly = true)
    public List<SubjectDTO.SubjectResponse> searchSubjectsByName(String keyword) {
        return subjectRepository.findBySubjectNameContainingIgnoreCase(keyword).stream()
                .map(SubjectDTO.SubjectResponse::fromEntity)
                .collect(Collectors.toList());
    }

    // Tìm môn học theo tên do giáo viên tạo
    @Transactional(readOnly = true)
    public List<SubjectDTO.SubjectResponse> searchSubjectsByNameAndTeacher(String keyword, Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));
        
        return subjectRepository.findBySubjectNameContainingIgnoreCaseAndCreatedBy(keyword, teacher).stream()
                .map(SubjectDTO.SubjectResponse::fromEntity)
                .collect(Collectors.toList());
    }
}
