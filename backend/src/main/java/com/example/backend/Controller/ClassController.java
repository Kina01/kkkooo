package com.example.backend.Controller;

import com.example.backend.DTO.ClassDTO;
import com.example.backend.DTO.ClassStudentDTO;
import com.example.backend.DTO.UserDTO;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.ClassStudent;
import com.example.backend.Model.User;
import com.example.backend.Service.ClassService;
import com.example.backend.Service.UserService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/classes")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class ClassController {

    @Autowired
    private ClassService classService;

    @Autowired
    private UserService userService;

    // Tạo lớp mới
    @PostMapping("/add-class")
    public ResponseEntity<Map<String, Object>> createClass(@RequestBody ClassDTO.CreateClassRequest createClassRequest,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            ClassEntity createdClass = classService.createClass(createClassRequest, teacherId);

            ClassDTO.ClassResponse classResponse = ClassDTO.ClassResponse.fromEntity(createdClass);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Tạo lớp thành công");
            response.put("status", "success");
            response.put("data", classResponse);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Cập nhật lớp
    @PutMapping("/update/{classId}")
    public ResponseEntity<Map<String, Object>> updateClass(@PathVariable Long classId,
            @RequestBody ClassDTO.UpdateClassRequest updateClassRequest,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            ClassEntity updatedClass = classService.updateClass(classId, updateClassRequest, teacherId);

            ClassDTO.ClassResponse classResponse = ClassDTO.ClassResponse.fromEntity(updatedClass);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Cập nhật lớp thành công");
            response.put("status", "success");
            response.put("data", classResponse);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Xóa lớp
    @DeleteMapping("delete/{classId}")
    public ResponseEntity<Map<String, Object>> deleteClass(@PathVariable Long classId,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            classService.deleteClass(classId, teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Xóa lớp thành công");
            response.put("status", "success");
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Thêm sinh viên vào lớp
    @PostMapping("/{classId}/students/{studentId}")
    public ResponseEntity<Map<String, Object>> addStudentToClass(
            @PathVariable Long classId,
            @PathVariable Long studentId,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            ClassStudent classStudent = classService.addStudentToClass(classId, studentId, teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Thêm sinh viên vào lớp thành công");
            response.put("status", "success");
            response.put("data", ClassStudentDTO.fromEntity(classStudent)); // Sử dụng DTO
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Xóa sinh viên khỏi lớp
    @DeleteMapping("/{classId}/delete-students/{studentId}")
    public ResponseEntity<Map<String, Object>> removeStudentFromClass(
            @PathVariable Long classId,
            @PathVariable Long studentId,
            @RequestHeader("User-ID") Long teacherId) {
        try {
            classService.removeStudentFromClass(classId, studentId, teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Xóa sinh viên khỏi lớp thành công");
            response.put("status", "success");
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy danh sách sinh viên trong lớp
    @GetMapping("/{classId}/students")
    public ResponseEntity<Map<String, Object>> getStudentsInClass(@PathVariable Long classId) {
        try {
            List<UserDTO> students = classService.getStudentsInClass(classId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy danh sách sinh viên thành công");
            response.put("status", "success");
            response.put("data", students);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy danh sách lớp của giáo viên
    @GetMapping("/teacher")
    public ResponseEntity<Map<String, Object>> getTeacherClasses(@RequestHeader("User-ID") Long teacherId) {
        try {
            List<ClassDTO.ClassSummary> classes = classService.getClassesByTeacher(teacherId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy danh sách lớp thành công");
            response.put("status", "success");
            response.put("data", classes);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy thông tin chi tiết lớp
    @GetMapping("getclass/{classId}")
    public ResponseEntity<Map<String, Object>> getClassDetail(@PathVariable Long classId) {
        try {
            ClassDTO.ClassResponse classDetail = classService.getClassDetail(classId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy thông tin lớp thành công");
            response.put("status", "success");
            response.put("data", classDetail);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Lấy danh sách lớp sinh viên đã đăng ký
    @GetMapping("/student")
    public ResponseEntity<Map<String, Object>> getStudentClasses(@RequestHeader("User-ID") Long studentId) {
        try {
            List<ClassDTO.ClassSummary> classes = classService.getClassesByStudent(studentId);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lấy danh sách lớp thành công");
            response.put("status", "success");
            response.put("data", classes);
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/search-students")
    public ResponseEntity<Map<String, Object>> searchStudents(@RequestParam String keyword) {
        try {
            List<User> students = userService.searchStudents(keyword);
            
            List<UserDTO> studentDTOs = students.stream()
                    .map(UserDTO::fromEntity)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Tìm kiếm sinh viên thành công");
            response.put("status", "success");
            response.put("data", studentDTOs);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Lỗi tìm kiếm sinh viên: " + e.getMessage());
            response.put("status", "error");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // // Tìm kiếm lớp
    // @GetMapping("/search")
    // public ResponseEntity<Map<String, Object>> searchClasses(@RequestParam String
    // keyword) {
    // try {
    // List<ClassEntity> classes = classService.searchClasses(keyword);

    // Map<String, Object> response = new HashMap<>();
    // response.put("message", "Tìm kiếm thành công");
    // response.put("status", "success");
    // response.put("data", classes);
    // return ResponseEntity.ok(response);

    // } catch (Exception e) {
    // Map<String, Object> response = new HashMap<>();
    // response.put("message", "Lỗi tìm kiếm");
    // response.put("status", "error");
    // return ResponseEntity.badRequest().body(response);
    // }
    // }
}