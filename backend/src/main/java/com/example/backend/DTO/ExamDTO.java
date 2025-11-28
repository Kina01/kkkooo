package com.example.backend.DTO;

import com.example.backend.Model.Exam;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;

public class ExamDTO {

    // DTO cho tạo lịch thi
    @Data
    public static class CreateExamRequest {
        private Long subjectId;
        private LocalDate examDate;
        private LocalTime examTime;
        private String room;
        private String notes;
    }

    // DTO cho response lịch thi
    @Data
    public static class ExamResponse {
        private Long examId;
        private Long classId;
        private String classCode;
        private Long subjectId;
        private String subjectName;
        private LocalDate examDate;
        private LocalTime examTime;
        private String room;
        private String notes;

        public static ExamResponse fromEntity(Exam exam) {
            ExamResponse r = new ExamResponse();
            r.setExamId(exam.getExamId());
            if (exam.getClassObj() != null) {
                r.setClassId(exam.getClassObj().getClassId());
                r.setClassCode(exam.getClassObj().getClassCode());
            }
            if (exam.getSubject() != null) {
                r.setSubjectId(exam.getSubject().getSubjectId());
                r.setSubjectName(exam.getSubject().getSubjectName());
            }
            r.setExamDate(exam.getExamDate());
            r.setExamTime(exam.getExamTime());
            r.setRoom(exam.getRoom());
            r.setNotes(exam.getNotes());
            return r;
        }
    }
}
