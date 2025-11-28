// lib/screens/notification_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/class_model.dart';
import '../services/notification_service.dart';
import '../services/class_service.dart';

class NotificationScreen extends StatefulWidget {
  final User user;

  const NotificationScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<NotificationSummary> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final res = widget.user.isTeacher
        ? await NotificationService.getTeacherNotifications()
        : await NotificationService.getStudentNotifications();

    setState(() {
      _isLoading = false;
      if (res.isSuccess && res.data != null) {
        _notifications = res.data!;
      } else {
        _errorMessage = res.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: widget.user.isTeacher
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _openCreateNotificationBottomSheet,
                  tooltip: 'Tạo thông báo',
                ),
              ]
            : null,
      ),
      body: _buildBody(),
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
              onPressed: _loadNotifications,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Text(
          'Không có thông báo nào',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return _buildNotificationCard(n);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationSummary n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          // sau này bạn có thể mở màn chi tiết / bottom sheet
        },
        title: Text(
          n.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (n.contentPreview != null) ...[
              const SizedBox(height: 4),
              Text(
                n.contentPreview!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    n.typeLabel, // Lịch học / Lịch thi / Khác / Giáo viên
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (n.status != NotificationStatus.ACTIVE)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      n.statusLabel,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: n.scheduledAt != null
            ? Text(
                _formatDateTime(n.scheduledAt!),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.right,
              )
            : null,
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    // Đơn giản: dd/MM HH:mm
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  /// ===== Bottom sheet tạo thông báo =====
  Future<void> _openCreateNotificationBottomSheet() async {
    if (!widget.user.isTeacher) return;

    // Lấy danh sách lớp mà giáo viên dạy
    final classRes = await ClassService.getTeacherClasses();
    if (!classRes.isSuccess || classRes.data == null || classRes.data!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không lấy được danh sách lớp: ${classRes.message}')),
      );
      return;
    }

    final List<ClassSummary> classes = classRes.data!;
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    NotificationType selectedType = NotificationType.SCHEDULE;
    DateTime? scheduledAt;
    final Set<int> selectedClassIds = {};

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
              Future<void> pickDateTime() async {
                final now = DateTime.now();
                final d = await showDatePicker(
                  context: ctx,
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 2),
                  initialDate: now,
                );
                if (d == null) return;

                final t = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.fromDateTime(now),
                );
                if (t == null) return;

                setModalState(() {
                  scheduledAt = DateTime(
                    d.year,
                    d.month,
                    d.day,
                    t.hour,
                    t.minute,
                  );
                });
              }

              Future<void> save() async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tiêu đề')),
                  );
                  return;
                }
                if (contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập nội dung')),
                  );
                  return;
                }
                if (selectedClassIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng chọn ít nhất một lớp')),
                  );
                  return;
                }

                setModalState(() => isSaving = true);

                final req = CreateNotificationRequest(
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  scheduledAt: scheduledAt, // có thể null -> backend set now
                  type: selectedType,
                  classIds: selectedClassIds.toList(),
                );

                final res = await NotificationService.createNotification(req);

                setModalState(() => isSaving = false);

                if (res.isSuccess) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tạo thông báo thành công')),
                  );
                  _loadNotifications();
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
                      'Tạo thông báo',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Tiêu đề
                    const Text('Tiêu đề'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'VD: Lịch kiểm tra giữa kỳ',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nội dung
                    const Text('Nội dung'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Nhập nội dung thông báo...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Loại thông báo & thời gian
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Loại thông báo'),
                              const SizedBox(height: 4),
                              DropdownButton<NotificationType>(
                                isExpanded: true,
                                value: selectedType,
                                items: const [
                                  DropdownMenuItem(
                                    value: NotificationType.SCHEDULE,
                                    child: Text('Lịch học'),
                                  ),
                                  DropdownMenuItem(
                                    value: NotificationType.EXAM,
                                    child: Text('Lịch thi'),
                                  ),
                                  DropdownMenuItem(
                                    value: NotificationType.OTHER,
                                    child: Text('Khác'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() => selectedType = v);
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
                              const Text('Thời gian gửi / hiệu lực'),
                              const SizedBox(height: 4),
                              OutlinedButton.icon(
                                onPressed: pickDateTime,
                                icon: const Icon(Icons.access_time, size: 18),
                                label: Text(
                                  scheduledAt == null
                                      ? 'Ngay bây giờ'
                                      : _formatDateTime(scheduledAt!),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Chọn lớp
                    const Text('Gửi tới lớp'),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: classes.map((c) {
                        final selected =
                            selectedClassIds.contains(c.classId);
                        return FilterChip(
                          label: Text(c.className),
                          selected: selected,
                          onSelected: (value) {
                            setModalState(() {
                              if (value) {
                                selectedClassIds.add(c.classId);
                              } else {
                                selectedClassIds.remove(c.classId);
                              }
                            });
                          },
                        );
                      }).toList(),
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
                                'Lưu thông báo',
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

    // controller cục bộ -> tự GC, không cần dispose
  }
}
