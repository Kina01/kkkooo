package com.example.backend.Controller;

import com.example.backend.DTO.SubjectDTO;
import com.example.backend.Service.SubjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/subjects")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class SubjectController {

    @Autowired
    private SubjectService subjectService;

    // Tạo môn học mới - chỉ giáo viên
    @PostMapping("/add")
    public ResponseEntity<Map<String, Object>> createSubject(@RequestBody SubjectDTO.CreateSubjectRequest request,
                                                           @RequestHeader("User-ID") Long teacherId) {
        try {
            var createdSubject = subjectService.createSubject(request, teacherId);
            var subjectResponse = SubjectDTO.SubjectResponse.fromEntity(createdSubject);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Tạo môn học thành công");
            response.put("status", "success");
            response.put("data", subjectResponse);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Cập nhật môn học - chỉ giáo viên tạo môn đó
    @PutMapping("/update/{subjectId}")
    public ResponseEntity<Map<String, Object>> updateSubject(@PathVariable Long subjectId,
                                                           @RequestBody SubjectDTO.UpdateSubjectRequest request,
                                                           @RequestHeader("User-ID") Long teacherId) {
        try {
            var updatedSubject = subjectService.updateSubject(subjectId, request, teacherId);
            var subjectResponse = SubjectDTO.SubjectResponse.fromEntity(updatedSubject);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Cập nhật môn học thành công");
            response.put("status", "success");
            response.put("data", subjectResponse);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Xóa môn học - chỉ giáo viên tạo môn đó
    @DeleteMapping("/delete/{subjectId}")
    public ResponseEntity<Map<String, Object>> deleteSubject(@PathVariable Long subjectId,
                                                           @RequestHeader("User-ID") Long teacherId) {
        try {
            subjectService.deleteSubject(subjectId, teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Xóa môn học thành công");
            response.put("status", "success");
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy tất cả môn học (ai cũng xem được)
    @GetMapping("/all")
    public ResponseEntity<Map<String, Object>> getAllSubjects() {
        try {
            var subjects = subjectService.getAllSubjects();

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy danh sách môn học thành công");
            response.put("status", "success");
            response.put("data", subjects);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy môn học do giáo viên tạo
    @GetMapping("/my-subjects")
    public ResponseEntity<Map<String, Object>> getMySubjects(@RequestHeader("User-ID") Long teacherId) {
        try {
            var subjects = subjectService.getSubjectsByTeacher(teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy danh sách môn học thành công");
            response.put("status", "success");
            response.put("data", subjects);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy môn học theo ID
    @GetMapping("/{subjectId}")
    public ResponseEntity<Map<String, Object>> getSubjectById(@PathVariable Long subjectId) {
        try {
            var subject = subjectService.getSubjectById(subjectId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy thông tin môn học thành công");
            response.put("status", "success");
            response.put("data", subject);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Tìm môn học theo mã
    @GetMapping("/code/{subjectCode}")
    public ResponseEntity<Map<String, Object>> getSubjectByCode(@PathVariable String subjectCode) {
        try {
            var subject = subjectService.getSubjectByCode(subjectCode);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy thông tin môn học thành công");
            response.put("status", "success");
            response.put("data", subject);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Tìm môn học theo tên (toàn hệ thống)
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchSubjects(@RequestParam String name) {
        try {
            var subjects = subjectService.searchSubjectsByName(name);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Tìm kiếm môn học thành công");
            response.put("status", "success");
            response.put("data", subjects);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Tìm môn học theo tên do giáo viên tạo
    @GetMapping("/search/my-subjects")
    public ResponseEntity<Map<String, Object>> searchMySubjects(@RequestParam String name,
                                                              @RequestHeader("User-ID") Long teacherId) {
        try {
            var subjects = subjectService.searchSubjectsByNameAndTeacher(name, teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Tìm kiếm môn học thành công");
            response.put("status", "success");
            response.put("data", subjects);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }
}