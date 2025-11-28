package com.example.backend.DTO;

import lombok.Data;

public class ScheduleDTO {

    // DTO cho tạo lịch học
    @Data
    public static class CreateScheduleRequest {
        private Long subjectId;
        private String room;
        private Integer dayOfWeek; // 2=Thứ 2, 3=Thứ 3, ..., 7=Chủ nhật
        private Integer startPeriod; // Tiết bắt đầu (1-10)
        private Integer endPeriod; // Tiết kết thúc (1-10)
        private Integer startWeek; // Tuần bắt đầu
        private Integer endWeek; // Tuần kết thúc
    }

    // DTO cho cập nhật lịch học
    @Data
    public static class UpdateScheduleRequest {
        private Long subjectId;
        private String room;
        private Integer dayOfWeek;
        private Integer startPeriod;
        private Integer endPeriod;
        private Integer startWeek;
        private Integer endWeek;
    }

    // DTO cho response lịch học
    @Data
    public static class ScheduleResponse {
        private Long scheduleId;
        private String room;
        private Integer dayOfWeek;
        private Integer startPeriod;
        private Integer endPeriod;
        private String startTime;
        private String endTime;
        private Integer totalPeriods;
        private Integer startWeek;
        private Integer endWeek;
        private String session;
        private String timeDescription;
        private SubjectDTO.SubjectResponse subject;
        private ClassSimpleDTO classInfo;
        private UserDTO teacher;

        public static ScheduleResponse fromEntity(com.example.backend.Model.Schedule schedule) {
            ScheduleResponse response = new ScheduleResponse();
            response.setScheduleId(schedule.getScheduleId());
            response.setRoom(schedule.getRoom());
            response.setDayOfWeek(schedule.getDayOfWeek());
            response.setStartPeriod(schedule.getStartPeriod());
            response.setEndPeriod(schedule.getEndPeriod());
            response.setStartTime(schedule.getStartTime().toString());
            response.setEndTime(schedule.getEndTime().toString());
            response.setTotalPeriods(schedule.getTotalPeriods());
            response.setStartWeek(schedule.getStartWeek());
            response.setEndWeek(schedule.getEndWeek());
            response.setSession(schedule.getSession());
            response.setTimeDescription(schedule.getTimeDescription());

            // Thông tin môn học
            if (schedule.getSubject() != null) {
                response.setSubject(SubjectDTO.SubjectResponse.fromEntity(schedule.getSubject()));
            }

            // Thông tin lớp học
            if (schedule.getClassObj() != null) {
                response.setClassInfo(ClassSimpleDTO.fromEntity(schedule.getClassObj()));
            }

            // Thông tin giáo viên
            if (schedule.getTeacher() != null) {
                response.setTeacher(UserDTO.fromEntity(schedule.getTeacher()));
            }

            return response;
        }
    }
}