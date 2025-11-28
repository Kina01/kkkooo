package com.example.backend.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Nationalized;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "exams")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Exam {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long examId;

    @ManyToOne
    @JoinColumn(name = "class_id", nullable = false)
    private ClassEntity classObj;

    @ManyToOne
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    @Column(nullable = false)
    private LocalDate examDate; // Ngày thi

    @Column(nullable = false)
    private LocalTime examTime; // Giờ thi

    @Column(nullable = false, length = 50)
    private String room; // Phòng thi

    @Nationalized
    @Column(columnDefinition = "NTEXT")
    private String notes; // Ghi chú
}