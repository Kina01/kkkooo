package com.example.backend.DTO;

import com.example.backend.Model.ClassStudent;
import lombok.Data;

@Data
public class ClassStudentDTO {
    private Long id;
    private ClassSimpleDTO classInfo;
    private UserDTO student;

    public static ClassStudentDTO fromEntity(ClassStudent classStudent) {
        ClassStudentDTO dto = new ClassStudentDTO();
        dto.setId(classStudent.getId());

        // Thêm thông tin lớp học
        if (classStudent.getClassObj() != null) {
            dto.setClassInfo(ClassSimpleDTO.fromEntity(classStudent.getClassObj()));
        }

        dto.setStudent(UserDTO.fromEntity(classStudent.getStudent()));
        return dto;
    }
}