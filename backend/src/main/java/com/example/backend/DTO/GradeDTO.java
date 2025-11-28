package com.example.backend.DTO;

import com.example.backend.Model.Grade;
import lombok.Data;

import java.time.LocalDateTime;

public class GradeDTO {

    // DTO cho chấm điểm
    @Data
    public static class GradeRequest {
        private Double processScore;
        private Double midtermScore;
        private String comments;
    }

    // DTO cho chấm điểm hàng loạt
    @Data
    public static class GradeUpdateRequest {
        private Long studentId;
        private Double processScore;
        private Double midtermScore;
        private String comments;
    }

    // DTO cho response Grade
    @Data
    public static class GradeResponse {
        private Long gradeId;
        private Long classId;
        private String classCode;
        private Long studentId;
        private String studentEmail;
        private String studentFullName;
        private Long subjectId;
        private String subjectName;
        private Double processScore;
        private Double midtermScore;
        private String comments;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        public static GradeResponse fromEntity(Grade g) {
            GradeResponse r = new GradeResponse();
            r.setGradeId(g.getGradeId());
            if (g.getClassObj() != null) {
                r.setClassId(g.getClassObj().getClassId());
                r.setClassCode(g.getClassObj().getClassCode());
            }
            if (g.getStudent() != null) {
                r.setStudentId(g.getStudent().getUserId());
                r.setStudentEmail(g.getStudent().getEmail());
                r.setStudentFullName(g.getStudent().getFullName());
            }
            if (g.getSubject() != null) {
                r.setSubjectId(g.getSubject().getSubjectId());
                r.setSubjectName(g.getSubject().getSubjectName());
            }
            r.setProcessScore(g.getProcessScore());
            r.setMidtermScore(g.getMidtermScore());
            r.setComments(g.getComments());
            r.setCreatedAt(g.getCreatedAt());
            r.setUpdatedAt(g.getUpdatedAt());
            return r;
        }
    }
}
