// screens/student_management_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../services/student_service.dart';

class StudentManagementScreen extends StatefulWidget {
  final ClassSummary classData;
  final VoidCallback onStudentsUpdated;

  const StudentManagementScreen({Key? key, required this.classData, required this.onStudentsUpdated}) : super(key: key);

  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  List<User> _students = [];
  List<User> _availableStudents = [];
  bool _isLoading = true;
  bool _isAddingStudent = false;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _loadAvailableStudents();
  }

  Future<void> _loadStudents() async {
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final response = await StudentService.getStudentsInClass(widget.classData.classId!);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (response.isSuccess && response.data != null) {
          _students = response.data!;
        } else {
          _errorMessage = response.message ?? 'Lỗi khi tải danh sách sinh viên';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = 'Lỗi kết nối: $e'; });
    }
  }

  Future<void> _loadAvailableStudents() async {
    await _searchStudents('');
  }

  Future<void> _searchStudents(String query) async {
    setState(() { _searchQuery = query; _isLoading = true; });

    try {
      final response = await StudentService.searchStudents(query);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (response.isSuccess && response.data != null) {
          _availableStudents = response.data!;
        } else {
          _availableStudents = [];
          if (query.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: ${response.message}')));
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _availableStudents = []; });
      if (query.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sinh viên - ${widget.classData.className ?? ''}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: _showAddStudentDialog),
        ],
      ),
      body: Column(children: [Expanded(child: _buildStudentList())]),
    );
  }

  Widget _buildStudentList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage.isNotEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(_errorMessage, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadStudents, child: const Text('Thử lại')),
      ]));
    }

    if (_students.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('Chưa có sinh viên nào trong lớp', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _showAddStudentDialog, child: const Text('Thêm sinh viên đầu tiên')),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(backgroundColor: Colors.blue[100], child: Icon(Icons.person, color: Colors.blue[700])),
          title: Text(student.fullName ?? ''),
          subtitle: Text(student.email ?? ''),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeStudent(student)),
          onTap: () => _showStudentDetail(student),
        ));
      },
    );
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Thêm sinh viên vào lớp'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Tìm kiếm sinh viên...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                onChanged: (value) async {
                  await _searchStudents(value);
                  setDialogState(() {});
                },
              ),
              const SizedBox(height: 16),
              if (_isAddingStudent) const Center(child: CircularProgressIndicator()) else
                SizedBox(
                  height: 300,
                  child: _availableStudents.isEmpty
                      ? Center(child: Text(_searchQuery.isEmpty ? 'Không có sinh viên nào' : 'Không tìm thấy sinh viên phù hợp', style: const TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _availableStudents.length,
                          itemBuilder: (context, index) {
                            final student = _availableStudents[index];
                            final isAlreadyInClass = _students.any((s) => s.userId == student.userId);
                            return ListTile(
                              leading: CircleAvatar(backgroundColor: Colors.green[100], child: Icon(Icons.person, color: Colors.green[700])),
                              title: Text(student.fullName ?? ''),
                              subtitle: Text(student.email ?? ''),
                              trailing: isAlreadyInClass
                                  ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)), child: const Text('Đã thêm', style: TextStyle(fontSize: 12)))
                                  : ElevatedButton(onPressed: () => _addStudentToClass(student), child: const Text('Thêm')),
                            );
                          },
                        ),
                ),
            ]),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
        );
      }),
    );
  }

  void _addStudentToClass(User student) async {
    setState(() { _isAddingStudent = true; });

    final response = await StudentService.addStudentToClass(widget.classData.classId!, student.userId!);

    if (!mounted) return;
    setState(() { _isAddingStudent = false; });

    if (response.isSuccess) {
      Navigator.pop(context);
      await _loadStudents();
      widget.onStudentsUpdated();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${student.fullName} vào lớp'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message), backgroundColor: Colors.red));
    }
  }

  void _removeStudent(User student) {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Xóa sinh viên'), content: Text('Bạn có chắc chắn muốn xóa ${student.fullName} khỏi lớp ${widget.classData.className}?'), actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
      ElevatedButton(
        onPressed: () async {
          Navigator.pop(context);
          final response = await StudentService.removeStudentFromClass(widget.classData.classId!, student.userId!);
          if (!mounted) return;
          if (response.isSuccess) {
            await _loadStudents();
            widget.onStudentsUpdated();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa ${student.fullName} khỏi lớp'), backgroundColor: Colors.green));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message), backgroundColor: Colors.red));
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('Xóa'),
      ),
    ]));
  }

  void _showStudentDetail(User student) {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Thông tin sinh viên'), content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Center(child: CircleAvatar(radius: 40, backgroundColor: Colors.blue[100], child: Icon(Icons.person, size: 40, color: Colors.blue[700]))),
      const SizedBox(height: 16),
      _buildDetailItem('Họ tên', student.fullName ?? ''),
      _buildDetailItem('Email', student.email ?? ''),
      _buildDetailItem('Vai trò', 'Sinh viên'),
      _buildDetailItem('Lớp', widget.classData.className ?? ''),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))]));
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
      Expanded(child: Text(value)),
    ]));
  }
}
