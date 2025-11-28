// screens/schedule_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/schedule_model.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../services/schedule_service.dart';
import '../services/class_service.dart';
import '../services/subject_service.dart';

class ScheduleScreen extends StatefulWidget {
  final User user;

  const ScheduleScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<ScheduleItem> _schedules = [];

  // Cho sinh viên chọn lớp để xem TKB
  List<ClassSummary> _studentClasses = [];
  ClassSummary? _selectedClass;

  // Tuần hiện tại
  int _currentWeek = 1;
  int _maxWeek = 16;

  // Controller cho ô phòng học trong form thêm lịch
  final TextEditingController _roomController = TextEditingController();

  // Cấu hình lưới
  static const int maxPeriods = 10;
  static const List<int> dayValues = [2, 3, 4, 5, 6, 7, 8]; // T2..T7
  static const List<String> dayLabels = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (widget.user.isTeacher) {
      final res = await ScheduleService.getTeacherSchedules();
      setState(() {
        _isLoading = false;
        if (res.isSuccess && res.data != null) {
          _schedules = res.data!;
          _updateMaxWeekFromData();
        } else {
          _errorMessage = res.message;
        }
      });
    } else {
      // Sinh viên: lấy danh sách lớp đã đăng ký
      final classRes = await ClassService.getStudentClasses();
      if (classRes.isSuccess &&
          classRes.data != null &&
          classRes.data!.isNotEmpty) {
        _studentClasses = classRes.data!;
        _selectedClass = _studentClasses.first;
        await _loadScheduleForClass();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = classRes.message.isNotEmpty
              ? classRes.message
              : 'Bạn chưa đăng ký lớp nào';
        });
      }
    }
  }

  Future<void> _loadScheduleForClass() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final res = await ScheduleService.getStudentSchedules();
    setState(() {
      _isLoading = false;
      if (res.isSuccess && res.data != null) {
        _schedules = res.data!;
        _updateMaxWeekFromData();
      } else {
        _errorMessage = res.message;
      }
    });
  }

  void _updateMaxWeekFromData() {
    if (_schedules.isEmpty) {
      _maxWeek = 16;
      _currentWeek = 1;
      return;
    }
    int maxEnd = _schedules
        .map((s) => s.endWeek)
        .fold<int>(1, (prev, e) => e > prev ? e : prev);
    if (maxEnd < 1) maxEnd = 1;
    _maxWeek = maxEnd;
    if (_currentWeek > _maxWeek) _currentWeek = _maxWeek;
    if (_currentWeek < 1) _currentWeek = 1;
  }

  // Các lịch hiển thị theo tuần
  List<ScheduleItem> get _visibleSchedules {
    return _schedules
        .where((s) => s.startWeek <= _currentWeek && s.endWeek >= _currentWeek)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch học'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: widget.user.isTeacher
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _openAddScheduleBottomSheet,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (!widget.user.isTeacher) _buildStudentClassSelector(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildStudentClassSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blueGrey[50],
      child: Row(
        children: [
          const Text(
            'Lớp:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<ClassSummary>(
              isExpanded: true,
              value: _selectedClass,
              hint: const Text('Chọn lớp để xem TKB'),
              items: _studentClasses
                  .map(
                    (c) => DropdownMenuItem<ClassSummary>(
                      value: c,
                      child: Text('${c.className} (${c.classCode})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedClass = value;
                  });
                  _loadScheduleForClass();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_schedules.isEmpty) {
      return Center(
        child: Text(
          'Không có lịch học nào',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Column(
      children: [
        _buildWeekSelector(),
        const SizedBox(height: 4),
        Expanded(child: _buildTimetable()),
      ],
    );
  }

  /// Thanh chọn tuần (Tuần 1, Tuần 2, ... với nút < >)
  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentWeek > 1
                ? () {
                    setState(() {
                      _currentWeek--;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            'Tuần $_currentWeek',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: _currentWeek < _maxWeek
                ? () {
                    setState(() {
                      _currentWeek++;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetable() {
    const double cellWidth = 110;
    const double cellHeight = 64;
    const double headerHeight = 40;
    const double periodLabelWidth = 40;

    final double tableWidth = periodLabelWidth + cellWidth * dayValues.length;
    final double tableHeight = headerHeight + cellHeight * maxPeriods;

    return InteractiveViewer(
      constrained: false,
      minScale: 0.8,
      maxScale: 2.5,
      child: SizedBox(
        width: tableWidth,
        height: tableHeight,
        child: Stack(
          children: [
            // ==== Header thứ (T2..T7) ====
            ...List.generate(dayValues.length, (index) {
              return Positioned(
                left: periodLabelWidth + cellWidth * index,
                top: 0,
                width: cellWidth,
                height: headerHeight,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              );
            }),

            // ==== Ô "Tiết" ====
            Positioned(
              left: 0,
              top: 0,
              width: periodLabelWidth,
              height: headerHeight,
              child: Container(
                alignment: Alignment.center,
                color: Colors.blueGrey[50],
                child: const Text(
                  'Tiết',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // ==== Nhãn tiết + grid rỗng ====
            ...List.generate(maxPeriods, (row) {
              final top = headerHeight + cellHeight * row;
              return [
                // Nhãn tiết
                Positioned(
                  left: 0,
                  top: top,
                  width: periodLabelWidth,
                  height: cellHeight,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    child: Text(
                      '${row + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                // Các ô trống
                ...List.generate(dayValues.length, (col) {
                  return Positioned(
                    left: periodLabelWidth + cellWidth * col,
                    top: top,
                    width: cellWidth,
                    height: cellHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right:
                              BorderSide(color: Colors.grey.withOpacity(0.2)),
                          bottom:
                              BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                      ),
                    ),
                  );
                }),
              ];
            }).expand((e) => e),

            // ==== Block môn học (lọc theo tuần) ====
            ..._visibleSchedules.map((s) {
              final dayIndex = dayValues.indexOf(s.dayOfWeek);
              if (dayIndex == -1) return const SizedBox.shrink();

              final duration = (s.endPeriod - s.startPeriod + 1).clamp(1, 10);
              final left = periodLabelWidth + dayIndex * cellWidth + 4;
              final top = headerHeight + (s.startPeriod - 1) * cellHeight + 4;

              return Positioned(
                left: left,
                top: top,
                width: cellWidth - 8,
                height: cellHeight * duration - 10,
                child: _buildScheduleBlock(s),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Block môn học trên lưới
  Widget _buildScheduleBlock(ScheduleItem s) {
    final subjectName = s.subject?.subjectName ?? 'Môn học';
    final className = s.classInfo?.className ?? '';
    final room = s.room;
    final timeDesc = '${s.startTime} - ${s.endTime}';

    return GestureDetector(
      onTap: () => _showScheduleDetail(s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: _getColorForSession(s.session).withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 11),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (className.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Tiết ${s.startPeriod}-${s.endPeriod}',
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                'Phòng: $room',
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                timeDesc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                'Tuần ${s.startWeek}-${s.endWeek}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== DIALOG CHI TIẾT LỊCH HỌC + XÓA + CẬP NHẬT =====
  void _showScheduleDetail(ScheduleItem s) {
    final subjectName = s.subject?.subjectName ?? 'Môn học';
    final className = s.classInfo?.className ?? '';
    final teacherName = s.teacher?.fullName ?? '';
    final room = s.room;
    final dayName = _getDayName(s.dayOfWeek);
    final timeDesc = '${s.startTime} - ${s.endTime}';

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subjectName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.user.isTeacher)
                          IconButton(
                            icon: const Icon(Icons.close, size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                      ],
                    ),
                  ],
                ),
                if (className.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    className,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Các dòng thông tin
                _detailRow(Icons.calendar_today, 'Thứ', dayName),
                _detailRow(Icons.schedule, 'Tiết',
                    '${s.startPeriod} - ${s.endPeriod}'),
                _detailRow(Icons.access_time, 'Thời gian', timeDesc),
                _detailRow(Icons.meeting_room, 'Phòng', room),
                if (teacherName.isNotEmpty)
                  _detailRow(Icons.person, 'Giáo viên', teacherName),
                _detailRow(
                    Icons.view_week, 'Tuần', '${s.startWeek} - ${s.endWeek}'),
                _detailRow(Icons.wb_sunny, "Buổi", _getSessionName(s.session)),


                const SizedBox(height: 20),

                // Nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.user.isTeacher)
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(); // đóng dialog
                          _openEditScheduleBottomSheet(s);
                        },
                        child: const Text('Cập nhật'),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.user.isTeacher)
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop(); // đóng dialog
                              _confirmDeleteSchedule(s);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Xóa lịch',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteSchedule(ScheduleItem s) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lịch học'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final res = await ScheduleService.deleteSchedule(s.scheduleId);
    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa lịch học')),
      );
      _loadInitialData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xóa lịch: ${res.message}')),
      );
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 2:
        return 'Thứ 2';
      case 3:
        return 'Thứ 3';
      case 4:
        return 'Thứ 4';
      case 5:
        return 'Thứ 5';
      case 6:
        return 'Thứ 6';
      case 7:
        return 'Thứ 7';
      case 8:
        return 'Chủ nhật';
      default:
        return 'Không rõ';
    }
  }

  Color _getColorForSession(String session) {
    switch (session.toUpperCase()) {
      case 'MORNING':
        return Colors.orange.shade400;
      case 'AFTERNOON':
        return Colors.green.shade400;
      default:
        return Colors.purple.shade400;
    }
  }

  String _getSessionName(String session) {
    switch (session.toUpperCase()) {
      case 'MORNING':
        return 'Sáng';
      case 'AFTERNOON':
        return 'Chiều';
      default:
        return 'Không rõ';
    }
  }

  /// Bottom sheet thêm lịch học – form nằm ngay trong screen
  Future<void> _openAddScheduleBottomSheet() async {
    if (!widget.user.isTeacher) return;

    // Reset text phòng mỗi lần mở form
    _roomController.text = '';

    // 1. Lấy danh sách lớp & môn của GV
    final classRes = await ClassService.getTeacherClasses();
    final subjectRes = await SubjectService.getMySubjects();

    if (!classRes.isSuccess ||
        classRes.data == null ||
        classRes.data!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Không lấy được danh sách lớp: ${classRes.message}')),
      );
      return;
    }
    if (!subjectRes.isSuccess ||
        subjectRes.data == null ||
        subjectRes.data!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Không lấy được danh sách môn: ${subjectRes.message}')),
      );
      return;
    }

    List<ClassSummary> classes = classRes.data!;
    List<SubjectSummary> subjects = subjectRes.data!;

    ClassSummary? selectedClass = classes.first;
    SubjectSummary? selectedSubject = subjects.first;
    int selectedDay = 2;
    int startPeriod = 1;
    int endPeriod = 1;
    int startWeek = 1;
    int endWeek = 1;

    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              Future<void> save() async {
                if (selectedClass == null || selectedSubject == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng chọn lớp và môn học')),
                  );
                  return;
                }
                if (_roomController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập phòng học')),
                  );
                  return;
                }
                if (endPeriod < startPeriod) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Tiết kết thúc phải lớn hơn hoặc bằng tiết bắt đầu'),
                    ),
                  );
                  return;
                }
                if (endWeek < startWeek) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Tuần kết thúc phải lớn hơn hoặc bằng tuần bắt đầu'),
                    ),
                  );
                  return;
                }

                setModalState(() => isSaving = true);

                final req = CreateScheduleRequest(
                  subjectId: selectedSubject!.subjectId,
                  room: _roomController.text.trim(),
                  dayOfWeek: selectedDay,
                  startPeriod: startPeriod,
                  endPeriod: endPeriod,
                  startWeek: startWeek,
                  endWeek: endWeek,
                );

                final res = await ScheduleService.createSchedule(
                    selectedClass!.classId, req);

                setModalState(() => isSaving = false);

                if (res.isSuccess) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tạo lịch học thành công!')),
                  );
                  _loadInitialData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${res.message}')),
                  );
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const Text(
                      'Thêm lịch học',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Lớp học
                    const Text('Lớp học'),
                    const SizedBox(height: 4),
                    DropdownButton<ClassSummary>(
                      isExpanded: true,
                      value: selectedClass,
                      items: classes
                          .map(
                            (c) => DropdownMenuItem<ClassSummary>(
                              value: c,
                              child: Text('${c.className} (${c.classCode})'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setModalState(() => selectedClass = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Môn học
                    const Text('Môn học'),
                    const SizedBox(height: 4),
                    DropdownButton<SubjectSummary>(
                      isExpanded: true,
                      value: selectedSubject,
                      items: subjects
                          .map(
                            (s) => DropdownMenuItem<SubjectSummary>(
                              value: s,
                              child:
                                  Text('${s.subjectName} (${s.subjectCode})'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setModalState(() => selectedSubject = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Thứ & Phòng
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Thứ'),
                              const SizedBox(height: 4),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: selectedDay,
                                items: const [
                                  DropdownMenuItem(
                                      value: 2, child: Text('Thứ 2')),
                                  DropdownMenuItem(
                                      value: 3, child: Text('Thứ 3')),
                                  DropdownMenuItem(
                                      value: 4, child: Text('Thứ 4')),
                                  DropdownMenuItem(
                                      value: 5, child: Text('Thứ 5')),
                                  DropdownMenuItem(
                                      value: 6, child: Text('Thứ 6')),
                                  DropdownMenuItem(
                                      value: 7, child: Text('Thứ 7')),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => selectedDay = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Phòng'),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _roomController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'VD: A4.203',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tiết
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tiết bắt đầu'),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: startPeriod,
                                items: List.generate(
                                  10,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => startPeriod = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tiết kết thúc'),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: endPeriod,
                                items: List.generate(
                                  10,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => endPeriod = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tuần
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tuần bắt đầu'),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: startWeek,
                                items: List.generate(
                                  16,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => startWeek = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tuần kết thúc'),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: endWeek,
                                items: List.generate(
                                  16,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => endWeek = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Lưu lịch học',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ===== BOTTOM SHEET CẬP NHẬT LỊCH HỌC =====
  Future<void> _openEditScheduleBottomSheet(ScheduleItem s) async {
    if (!widget.user.isTeacher) return;

    // Lấy danh sách môn GV tạo (không cho đổi lớp, chỉ đổi môn/tiết/tuần)
    final subjectRes = await SubjectService.getMySubjects();
    if (!subjectRes.isSuccess ||
        subjectRes.data == null ||
        subjectRes.data!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không lấy được danh sách môn: ${subjectRes.message}'),
        ),
      );
      return;
    }

    final subjects = subjectRes.data!;

    // --- Giá trị mặc định từ lịch đang chọn ---
    final classInfo = s.classInfo;
    SubjectSummary? selectedSubject;
    if (s.subject != null) {
      selectedSubject = subjects.firstWhere(
        (sub) => sub.subjectId == s.subject!.subjectId,
        orElse: () => subjects.first,
      );
    } else {
      selectedSubject = subjects.first;
    }

    int selectedDay = s.dayOfWeek;
    int startPeriod = s.startPeriod;
    int endPeriod = s.endPeriod;
    int startWeek = s.startWeek;
    int endWeek = s.endWeek;

    final roomController = TextEditingController(text: s.room);
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              Future<void> save() async {
                if (selectedSubject == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn môn học')),
                  );
                  return;
                }
                if (roomController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập phòng học')),
                  );
                  return;
                }
                if (endPeriod < startPeriod) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Tiết kết thúc phải lớn hơn hoặc bằng tiết bắt đầu'),
                    ),
                  );
                  return;
                }
                if (endWeek < startWeek) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Tuần kết thúc phải lớn hơn hoặc bằng tuần bắt đầu'),
                    ),
                  );
                  return;
                }

                setModalState(() => isSaving = true);

                final req = UpdateScheduleRequest(
                  subjectId: selectedSubject!.subjectId,
                  room: roomController.text.trim(),
                  dayOfWeek: selectedDay,
                  startPeriod: startPeriod,
                  endPeriod: endPeriod,
                  startWeek: startWeek,
                  endWeek: endWeek,
                );

                final res =
                    await ScheduleService.updateSchedule(s.scheduleId, req);

                setModalState(() => isSaving = false);

                if (res.isSuccess) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Cập nhật lịch học thành công!')),
                  );
                  _loadInitialData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${res.message}')),
                  );
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const Text(
                      'Cập nhật lịch học',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Lớp học (không cho đổi)
                    const Text('Lớp học'),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        classInfo != null
                            ? '${classInfo.className} (${classInfo.classCode})'
                            : 'Không rõ lớp',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Môn học
                    const Text('Môn học'),
                    const SizedBox(height: 4),
                    DropdownButton<SubjectSummary>(
                      isExpanded: true,
                      value: selectedSubject,
                      items: subjects
                          .map(
                            (sub) => DropdownMenuItem<SubjectSummary>(
                              value: sub,
                              child: Text(
                                  '${sub.subjectName} (${sub.subjectCode})'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setModalState(() => selectedSubject = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Thứ & Phòng
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Thứ'),
                              const SizedBox(height: 4),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: selectedDay,
                                items: const [
                                  DropdownMenuItem(
                                      value: 2, child: Text('Thứ 2')),
                                  DropdownMenuItem(
                                      value: 3, child: Text('Thứ 3')),
                                  DropdownMenuItem(
                                      value: 4, child: Text('Thứ 4')),
                                  DropdownMenuItem(
                                      value: 5, child: Text('Thứ 5')),
                                  DropdownMenuItem(
                                      value: 6, child: Text('Thứ 6')),
                                  DropdownMenuItem(
                                      value: 7, child: Text('Thứ 7')),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => selectedDay = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Phòng'),
                              const SizedBox(height: 4),
                              TextField(
                                controller: roomController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'VD: A4.203',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tiết
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tiết bắt đầu'),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: startPeriod,
                                items: List.generate(
                                  10,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => startPeriod = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tiết kết thúc'),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: endPeriod,
                                items: List.generate(
                                  10,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => endPeriod = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tuần
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tuần bắt đầu'),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: startWeek,
                                items: List.generate(
                                  16,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => startWeek = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tuần kết thúc'),
                              DropdownButton<int>(
                                isExpanded: true,
                                value: endWeek,
                                items: List.generate(
                                  16,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => endWeek = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Lưu thay đổi',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
