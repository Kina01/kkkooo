package com.example.backend.DTO;

import com.example.backend.Model.ClassEntity;
import lombok.Data;

import java.util.List;
import java.util.stream.Collectors;


public class ClassDTO {

    // DTO cho tạo lớp học
    @Data
    public static class CreateClassRequest {
        private String classCode;
        private String className;
        private String description;
    }

    // DTO cho cập nhật lớp học
    @Data
    public static class UpdateClassRequest {
        private String classCode;
        private String className;
        private String description;
    }

    // DTO cho thông tin lớp học - chi tiết đầy đủ
    @Data
    public static class ClassResponse {
        private Long classId;
        private String classCode;
        private String className;
        private String description;
        private UserDTO teacher;
        private List<UserDTO> students;
        private Integer studentCount;

        public static ClassResponse fromEntity(ClassEntity classEntity) {
            ClassResponse response = new ClassResponse();
            response.setClassId(classEntity.getClassId());
            response.setClassCode(classEntity.getClassCode());
            response.setClassName(classEntity.getClassName());
            response.setDescription(classEntity.getDescription());

            // Chỉ lấy thông tin cơ bản của teacher
            if (classEntity.getTeacher() != null) {
                response.setTeacher(UserDTO.fromEntity(classEntity.getTeacher()));
            }

            // Chuyển đổi danh sách sinh viên
            if (classEntity.getClassStudents() != null) {
                response.setStudents(classEntity.getClassStudents().stream()
                        .map(classStudent -> UserDTO.fromEntity(classStudent.getStudent()))
                        .collect(Collectors.toList()));
                response.setStudentCount(classEntity.getClassStudents().size());
            } else {
                response.setStudentCount(0);
            }

            return response;
        }
    }

    // DTO cho danh sách lớp học tóm tắt
    @Data
    public static class ClassSummary {
        private Long classId;
        private String classCode;
        private String className;
        private String description;
        private String teacherName;
        private Integer studentCount;

        public static ClassSummary fromEntity(ClassEntity classEntity) {
            ClassSummary summary = new ClassSummary();
            summary.setClassId(classEntity.getClassId());
            summary.setClassCode(classEntity.getClassCode());
            summary.setClassName(classEntity.getClassName());
            summary.setDescription(classEntity.getDescription());

            if (classEntity.getTeacher() != null) {
                summary.setTeacherName(classEntity.getTeacher().getFullName());
            }

            if (classEntity.getClassStudents() != null) {
                summary.setStudentCount(classEntity.getClassStudents().size());
            } else {
                summary.setStudentCount(0);
            }

            return summary;
        }
    }

    // DTO cho thống kê lớp học
    @Data
    public static class ClassStatistics {
        private Long classId;
        private String className;
        private Integer totalStudents;
        private Integer presentCount;
        private Integer absentCount;
        private Double averageScore;
    }
}