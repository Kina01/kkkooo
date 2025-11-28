package com.example.backend.DTO;

import com.example.backend.Model.ClassEntity;
import lombok.Data;

@Data
public class ClassSimpleDTO {
    private Long classId;
    private String classCode;
    private String className;
    private String description;

    public static ClassSimpleDTO fromEntity(ClassEntity classEntity) {
        ClassSimpleDTO dto = new ClassSimpleDTO();
        dto.setClassId(classEntity.getClassId());
        dto.setClassCode(classEntity.getClassCode());
        dto.setClassName(classEntity.getClassName());
        dto.setDescription(classEntity.getDescription());
        return dto;
    }
}