package com.example.backend.Controller;

import com.example.backend.DTO.GradeDTO;
import com.example.backend.Model.Grade;
import com.example.backend.Service.GradeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/grades")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class GradeController {

    @Autowired
    private GradeService gradeService;

    // Thêm/cập nhật điểm
    @PostMapping("/class/{classId}/student/{studentId}/subject/{subjectId}")
    public ResponseEntity<Map<String, Object>> addOrUpdateGrade(
            @PathVariable Long classId,
            @PathVariable Long studentId,
            @PathVariable Long subjectId,
            @RequestBody GradeDTO.GradeRequest request,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            Grade grade = gradeService.addOrUpdateGrade(
                    classId, studentId, subjectId,
                    request.getProcessScore(), request.getMidtermScore(),
                    request.getComments(), teacherId);

            GradeDTO.GradeResponse dto = GradeDTO.GradeResponse.fromEntity(grade);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lưu điểm thành công");
            response.put("status", "success");
            response.put("data", dto);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy điểm theo lớp
    @GetMapping("/class/{classId}")
    public ResponseEntity<Map<String, Object>> getGradesByClass(@PathVariable Long classId) {
        try {
            List<Grade> grades = gradeService.getGradesByClass(classId);

            List<GradeDTO.GradeResponse> dtos = grades.stream()
                    .map(GradeDTO.GradeResponse::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy danh sách điểm thành công");
            response.put("status", "success");
            response.put("data", dtos);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy điểm của sinh viên
    @GetMapping("/student/{studentId}")
    public ResponseEntity<Map<String, Object>> getStudentGrades(@PathVariable Long studentId) {
        try {
            List<Grade> grades = gradeService.getStudentGrades(studentId);

            List<GradeDTO.GradeResponse> dtos = grades.stream()
                    .map(GradeDTO.GradeResponse::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy điểm sinh viên thành công");
            response.put("status", "success");
            response.put("data", dtos);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy điểm trung bình lớp
    @GetMapping("/class/{classId}/average")
    public ResponseEntity<Map<String, Object>> getClassAverage(@PathVariable Long classId) {
        try {
            Double average = gradeService.getClassAverageScore(classId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy điểm trung bình thành công");
            response.put("status", "success");
            response.put("data", average);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Chấm điểm hàng loạt
    @PostMapping("/class/{classId}/subject/{subjectId}/batch")
    public ResponseEntity<Map<String, Object>> batchUpdateGrades(
            @PathVariable Long classId,
            @PathVariable Long subjectId,
            @RequestBody List<GradeDTO.GradeUpdateRequest> gradeRequests,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            List<Grade> grades = gradeService.batchUpdateGrades(classId, subjectId, gradeRequests, teacherId);

            List<GradeDTO.GradeResponse> dtos = grades.stream()
                    .map(GradeDTO.GradeResponse::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Chấm điểm hàng loạt thành công");
            response.put("status", "success");
            response.put("data", dtos);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }
}
