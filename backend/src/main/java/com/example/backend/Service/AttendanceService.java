package com.example.backend.Service;

import com.example.backend.Model.Attendance;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.Schedule;
import com.example.backend.Model.User;
import com.example.backend.Repository.AttendanceRepository;
import com.example.backend.Repository.ClassRepository;
import com.example.backend.Repository.ScheduleRepository;
import com.example.backend.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AttendanceService {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private ClassRepository classRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ScheduleRepository scheduleRepository;

    // Điểm danh cho một buổi học
    @Transactional
    public List<Attendance> takeAttendance(Long classId, Long scheduleId, LocalDate date, 
                                         Map<Long, Attendance.AttendanceStatus> attendanceMap, 
                                         Long teacherId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học"));

        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy buổi học"));

        // Kiểm tra giáo viên có quyền điểm danh cho lớp này không
        if (classEntity.getTeacher() == null || !classEntity.getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền điểm danh cho lớp này");
        }

        // -- Thay vì xóa toàn bộ attendance của schedule, chỉ xóa các bản ghi cho ngày hiện tại --
        attendanceRepository.deleteByScheduleAndAttendanceDate(schedule, date);

        // Tạo điểm danh mới cho ngày hiện tại
        List<Attendance> newAttendances = classEntity.getClassStudents().stream()
                .map(classStudent -> {
                    Attendance attendance = new Attendance();
                    attendance.setClassObj(classEntity);
                    attendance.setStudent(classStudent.getStudent());
                    attendance.setSchedule(schedule);
                    attendance.setAttendanceDate(date);
                    attendance.setStatus(attendanceMap.getOrDefault(
                            classStudent.getStudent().getUserId(), 
                            Attendance.AttendanceStatus.ABSENT));
                    return attendance;
                })
                .collect(Collectors.toList());

        return attendanceRepository.saveAll(newAttendances);
    }

    // Lấy danh sách điểm danh theo lớp và ngày
    public List<Attendance> getAttendanceByClassAndDate(Long classId, LocalDate date) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học"));
        return attendanceRepository.findByClassObjAndAttendanceDate(classEntity, date);
    }

    // Lấy lịch sử điểm danh của sinh viên
    public List<Attendance> getStudentAttendanceHistory(Long studentId, Long classId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sinh viên"));
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học"));
        return attendanceRepository.findByStudentAndClassObj(student, classEntity);
    }

    // Thống kê điểm danh
    public Map<Attendance.AttendanceStatus, Long> getAttendanceStatistics(Long classId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp học"));
        
        List<Object[]> stats = attendanceRepository.countAttendanceByStatus(classEntity);
        return stats.stream()
                .collect(Collectors.toMap(
                        obj -> (Attendance.AttendanceStatus) obj[0],
                        obj -> (Long) obj[1]
                ));
    }

    // Cập nhật điểm danh cá nhân
    @Transactional
    public Attendance updateAttendance(Long attendanceId, Attendance.AttendanceStatus status, String notes, Long teacherId) {
        Attendance attendance = attendanceRepository.findById(attendanceId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bản ghi điểm danh"));

        // Kiểm tra quyền
        if (attendance.getClassObj() == null || attendance.getClassObj().getTeacher() == null
                || !attendance.getClassObj().getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền cập nhật điểm danh này");
        }

        attendance.setStatus(status);
        attendance.setNotes(notes);
        return attendanceRepository.save(attendance);
    }
}
