package com.example.backend.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "schedules")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Schedule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long scheduleId;

    @ManyToOne
    @JoinColumn(name = "class_id", nullable = false)
    private ClassEntity classObj;

    @ManyToOne
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    @ManyToOne
    @JoinColumn(name = "teacher_id", nullable = false)
    private User teacher;

    @Column(nullable = false, length = 50)
    private String room;

    @Column(nullable = false)
    private Integer dayOfWeek; // 2=Thứ 2, 3=Thứ 3, ..., 7=Chủ nhật

    @Column(nullable = false)
    private Integer startPeriod; // Tiết bắt đầu (1-10)

    @Column(nullable = false)
    private Integer endPeriod; // Tiết kết thúc (1-10)

    @Column(nullable = false)
    private LocalTime startTime; // Thời gian bắt đầu

    @Column(nullable = false)
    private LocalTime endTime; // Thời gian kết thúc

    @Column(nullable = false)
    private Integer startWeek; // Tuần bắt đầu

    @Column(nullable = false)
    private Integer endWeek; // Tuần kết thúc

    @Column(nullable = false, length = 20)
    private String session; // MORNING, AFTERNOON

    @OneToMany(mappedBy = "schedule", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Attendance> attendances = new ArrayList<>();

    // Tự động tính toán thời gian dựa trên tiết học
    @PrePersist
    @PreUpdate
    public void calculateTime() {
        if (startPeriod == null || endPeriod == null) {
            throw new IllegalArgumentException("Start period và end period không được null");
        }
        
        if (startPeriod < 1 || startPeriod > 10 || endPeriod < 1 || endPeriod > 10) {
            throw new IllegalArgumentException("Tiết học phải từ 1 đến 10");
        }
        
        if (startPeriod > endPeriod) {
            throw new IllegalArgumentException("Start period không thể lớn hơn end period");
        }

        this.startTime = getStartTimeByPeriod(startPeriod);
        this.endTime = getEndTimeByPeriod(endPeriod);
        
        // Xác định buổi học
        this.session = (startPeriod <= 5) ? "MORNING" : "AFTERNOON";
    }

    private LocalTime getStartTimeByPeriod(Integer period) {
        return switch (period) {
            case 1 -> LocalTime.of(7, 0);   // 07:00
            case 2 -> LocalTime.of(7, 50);  // 07:50
            case 3 -> LocalTime.of(9, 0);   // 09:00
            case 4 -> LocalTime.of(9, 50);  // 09:50
            case 5 -> LocalTime.of(10, 40); // 10:40
            case 6 -> LocalTime.of(13, 0);  // 13:00
            case 7 -> LocalTime.of(13, 50); // 13:50
            case 8 -> LocalTime.of(15, 0);  // 15:00
            case 9 -> LocalTime.of(15, 50); // 15:50
            case 10 -> LocalTime.of(16, 40); // 16:40
            default -> throw new IllegalArgumentException("Tiết học không hợp lệ: " + period);
        };
    }

    private LocalTime getEndTimeByPeriod(Integer period) {
        return switch (period) {
            case 1 -> LocalTime.of(7, 50);  // 07:50
            case 2 -> LocalTime.of(8, 40);  // 08:40
            case 3 -> LocalTime.of(9, 50);  // 09:50
            case 4 -> LocalTime.of(10, 40); // 10:40
            case 5 -> LocalTime.of(11, 30); // 11:30
            case 6 -> LocalTime.of(13, 50); // 13:50
            case 7 -> LocalTime.of(14, 40); // 14:40
            case 8 -> LocalTime.of(15, 50); // 15:50
            case 9 -> LocalTime.of(16, 40); // 16:40
            case 10 -> LocalTime.of(17, 30); // 17:30
            default -> throw new IllegalArgumentException("Tiết học không hợp lệ: " + period);
        };
    }

    // Helper method để lấy số tiết học
    public Integer getTotalPeriods() {
        return endPeriod - startPeriod + 1;
    }

    // Helper method để lấy mô tả thời gian
    public String getTimeDescription() {
        return String.format("Tiết %d-%d (%s - %s)", startPeriod, endPeriod, startTime, endTime);
    }
}