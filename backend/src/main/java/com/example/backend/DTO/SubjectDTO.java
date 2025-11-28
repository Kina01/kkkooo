package com.example.backend.DTO;

import java.time.LocalDateTime;

import com.example.backend.Model.Subject;
import lombok.Data;

public class SubjectDTO {

    // DTO cho tạo môn học
    @Data
    public static class CreateSubjectRequest {
        private String subjectCode;
        private String subjectName;
        private Integer credits;
    }

    // DTO cho cập nhật môn học
    @Data
    public static class UpdateSubjectRequest {
        private String subjectCode;
        private String subjectName;
        private Integer credits;
    }

    // DTO cho response môn học
    @Data
    public static class SubjectResponse {
        private Long subjectId;
        private String subjectCode;
        private String subjectName;
        private Integer credits;
        private UserDTO createdBy;
        private LocalDateTime createdAt;

        public static SubjectResponse fromEntity(Subject subject) {
            SubjectResponse response = new SubjectResponse();
            response.setSubjectId(subject.getSubjectId());
            response.setSubjectCode(subject.getSubjectCode());
            response.setSubjectName(subject.getSubjectName());
            response.setCredits(subject.getCredits());
            response.setCreatedAt(subject.getCreatedAt());

            // Thêm thông tin người tạo
            if (subject.getCreatedBy() != null) {
                response.setCreatedBy(UserDTO.fromEntity(subject.getCreatedBy()));
            }

            return response;
        }
    }
}