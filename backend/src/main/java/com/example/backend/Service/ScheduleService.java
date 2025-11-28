package com.example.backend.Service;

import com.example.backend.DTO.ScheduleDTO;
import com.example.backend.Model.Schedule;
import com.example.backend.Model.ClassEntity;
import com.example.backend.Model.ClassStudent;
import com.example.backend.Model.Subject;
import com.example.backend.Model.User;
import com.example.backend.Repository.ScheduleRepository;
import com.example.backend.Repository.ClassRepository;
import com.example.backend.Repository.ClassStudentRepository;
import com.example.backend.Repository.SubjectRepository;
import com.example.backend.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ScheduleService {

    @Autowired
    private ScheduleRepository scheduleRepository;

    @Autowired
    private ClassRepository classRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private ClassStudentRepository classStudentRepository;

    // Tạo lịch học mới
    @Transactional
    public Schedule createSchedule(ScheduleDTO.CreateScheduleRequest request, Long classId, Long teacherId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp"));

        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));

        Subject subject = subjectRepository.findById(request.getSubjectId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học"));

        // Kiểm tra giáo viên có quyền thêm lịch cho lớp này không
        if (!classEntity.getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền thêm lịch cho lớp này");
        }

        // Kiểm tra trùng lịch học
        checkScheduleConflict(classEntity, request.getDayOfWeek(), request.getStartPeriod(),
                request.getEndPeriod(), request.getStartWeek(), request.getEndWeek(), null);

        Schedule schedule = new Schedule();
        schedule.setClassObj(classEntity);
        schedule.setTeacher(teacher);
        schedule.setSubject(subject);
        schedule.setRoom(request.getRoom());
        schedule.setDayOfWeek(request.getDayOfWeek());
        schedule.setStartPeriod(request.getStartPeriod());
        schedule.setEndPeriod(request.getEndPeriod());
        schedule.setStartWeek(request.getStartWeek());
        schedule.setEndWeek(request.getEndWeek());

        // Tự động tính toán thời gian
        schedule.calculateTime();

        return scheduleRepository.save(schedule);
    }

    // Cập nhật lịch học
    @Transactional
    public Schedule updateSchedule(Long scheduleId, ScheduleDTO.UpdateScheduleRequest request, Long teacherId) {
        Schedule existingSchedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch học"));

        // Kiểm tra giáo viên có quyền sửa lịch này không
        if (!existingSchedule.getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền sửa lịch này");
        }

        Subject subject = subjectRepository.findById(request.getSubjectId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học"));

        // Kiểm tra trùng lịch học (loại trừ chính nó)
        checkScheduleConflict(existingSchedule.getClassObj(), request.getDayOfWeek(),
                request.getStartPeriod(), request.getEndPeriod(),
                request.getStartWeek(), request.getEndWeek(), scheduleId);

        existingSchedule.setSubject(subject);
        existingSchedule.setRoom(request.getRoom());
        existingSchedule.setDayOfWeek(request.getDayOfWeek());
        existingSchedule.setStartPeriod(request.getStartPeriod());
        existingSchedule.setEndPeriod(request.getEndPeriod());
        existingSchedule.setStartWeek(request.getStartWeek());
        existingSchedule.setEndWeek(request.getEndWeek());

        // Tự động tính toán lại thời gian
        existingSchedule.calculateTime();

        return scheduleRepository.save(existingSchedule);
    }

    // Xóa lịch học
    @Transactional
    public void deleteSchedule(Long scheduleId, Long teacherId) {
        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch học"));

        // Kiểm tra giáo viên có quyền xóa lịch này không
        if (!schedule.getTeacher().getUserId().equals(teacherId)) {
            throw new RuntimeException("Bạn không có quyền xóa lịch này");
        }

        scheduleRepository.delete(schedule);
    }

    // Kiểm tra trùng lịch học
    private void checkScheduleConflict(ClassEntity classEntity, Integer dayOfWeek,
            Integer startPeriod, Integer endPeriod,
            Integer startWeek, Integer endWeek, Long excludeScheduleId) {
        // Lấy tất cả lịch học của lớp trong cùng ngày và khoảng tuần
        List<Schedule> existingSchedules = scheduleRepository.findByClassAndDayAndWeekRange(
                classEntity, dayOfWeek, startWeek, endWeek);

        for (Schedule existing : existingSchedules) {
            // Bỏ qua lịch hiện tại khi update
            if (excludeScheduleId != null && existing.getScheduleId().equals(excludeScheduleId)) {
                continue;
            }

            // Kiểm tra trùng khoảng tiết học
            boolean periodConflict = (startPeriod <= existing.getEndPeriod()) &&
                    (endPeriod >= existing.getStartPeriod());

            if (periodConflict) {
                throw new RuntimeException(String.format(
                        "Lịch học bị trùng với: %s - %s (Tiết %d-%d)",
                        existing.getSubject().getSubjectName(),
                        existing.getRoom(),
                        existing.getStartPeriod(),
                        existing.getEndPeriod()));
            }
        }
    }

    // Lấy lịch học theo lớp
    @Transactional(readOnly = true)
    public List<ScheduleDTO.ScheduleResponse> getSchedulesByClass(Long classId) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp"));

        return scheduleRepository.findByClassObj(classEntity).stream()
                .map(ScheduleDTO.ScheduleResponse::fromEntity)
                .collect(Collectors.toList());
    }

    // Lấy lịch dạy của giáo viên
    @Transactional(readOnly = true)
    public List<ScheduleDTO.ScheduleResponse> getSchedulesByTeacher(Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giáo viên"));

        return scheduleRepository.findByTeacher(teacher).stream()
                .map(ScheduleDTO.ScheduleResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Schedule> getSchedulesForStudent(Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sinh viên"));

        // Lấy danh sách lớp mà sinh viên đang học
        List<ClassStudent> classStudents = classStudentRepository.findByStudent(student);
        if (classStudents.isEmpty()) {
            return List.of();
        }

        List<Schedule> result = new ArrayList<>();

        for (ClassStudent cs : classStudents) {
            ClassEntity classEntity = cs.getClassObj(); // hoặc getClassEntity() tùy tên field của bạn

            // dùng method có sẵn trong ScheduleRepository, ví dụ:
            List<Schedule> classSchedules = scheduleRepository.findByClassObj(classEntity);
            // nếu field trong Schedule là classEntity thì sửa lại thành
            // findByClassEntity(...)

            result.addAll(classSchedules);
        }

        // sort theo ngày + tiết cho đẹp
        result.sort((a, b) -> {
            int cmpDay = Integer.compare(a.getDayOfWeek(), b.getDayOfWeek());
            if (cmpDay != 0)
                return cmpDay;
            return Integer.compare(a.getStartPeriod(), b.getStartPeriod());
        });

        return result;
    }

    // Lấy lịch học theo tuần và ngày
    @Transactional(readOnly = true)
    public List<ScheduleDTO.ScheduleResponse> getSchedulesByWeekAndDay(Integer week, Integer dayOfWeek) {
        return scheduleRepository.findByWeekAndDay(week, dayOfWeek).stream()
                .map(ScheduleDTO.ScheduleResponse::fromEntity)
                .collect(Collectors.toList());
    }

    // Lấy lịch học theo lớp và tuần
    @Transactional(readOnly = true)
    public List<ScheduleDTO.ScheduleResponse> getSchedulesByClassAndWeek(Long classId, Integer week) {
        ClassEntity classEntity = classRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp"));

        return scheduleRepository.findByClassAndWeek(classEntity, week).stream()
                .map(ScheduleDTO.ScheduleResponse::fromEntity)
                .collect(Collectors.toList());
    }
}
