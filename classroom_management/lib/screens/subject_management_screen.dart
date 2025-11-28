// screens/subject_management_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../services/subject_service.dart';

class SubjectManagementScreen extends StatefulWidget {
  final User user;

  const SubjectManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SubjectManagementScreenState createState() => _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  List<SubjectSummary> _subjects = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await SubjectService.getMySubjects();

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _subjects = response.data!;
      } else {
        _errorMessage = response.message;
      }
    });
  }

  Future<void> _searchSubjects(String query) async {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _loadSubjects();
      return;
    }

    final response = await SubjectService.searchMySubjects(query);

    if (response.isSuccess && response.data != null) {
      setState(() {
        _subjects = response.data!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm: ${response.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý môn học'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showCreateSubjectDialog();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubjects,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.subject, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Bạn chưa tạo môn học nào'
                  : 'Không tìm thấy môn học phù hợp',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            if (_searchQuery.isEmpty)
              ElevatedButton(
                onPressed: () {
                  _showCreateSubjectDialog();
                },
                child: Text('Tạo môn học đầu tiên'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return _buildSubjectCard(subject);
      },
    );
  }

  Widget _buildSubjectCard(SubjectSummary subject) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.subject,
            color: Colors.purple[700],
          ),
        ),
        title: Text(
          subject.subjectName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Mã môn: ${subject.subjectCode}'),
            if (subject.credits != null) 
              Text('Số tín chỉ: ${subject.credits}'),
          ],
        ),
        trailing: _buildSubjectMenu(subject),
        onTap: () {
          _showSubjectDetail(subject);
        },
      ),
    );
  }

  Widget _buildSubjectMenu(SubjectSummary subject) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
          onTap: () {
            _editSubject(subject);
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            _deleteSubject(subject);
          },
        ),
      ],
    );
  }

  void _showSearchDialog() {
    final searchController = TextEditingController(text: _searchQuery);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tìm kiếm môn học'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Nhập tên môn học...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Có thể thêm debounce ở đây
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _searchSubjects(searchController.text);
            },
            child: Text('Tìm kiếm'),
          ),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _searchQuery = '';
                _loadSubjects();
              },
              child: Text('Xóa tìm kiếm'),
            ),
        ],
      ),
    );
  }

  void _showCreateSubjectDialog() {
    final subjectCodeController = TextEditingController();
    final subjectNameController = TextEditingController();
    final creditsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tạo môn học mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectCodeController,
                decoration: InputDecoration(
                  labelText: 'Mã môn học',
                  hintText: 'VD: TOAN001',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: subjectNameController,
                decoration: InputDecoration(
                  labelText: 'Tên môn học',
                  hintText: 'VD: Toán cao cấp',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tín chỉ (tùy chọn)',
                  hintText: 'VD: 3',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectCodeController.text.isEmpty || subjectNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng nhập mã môn và tên môn')),
                );
                return;
              }

              final request = CreateSubjectRequest(
                subjectCode: subjectCodeController.text,
                subjectName: subjectNameController.text,
                credits: creditsController.text.isNotEmpty ? int.tryParse(creditsController.text) : null,
              );

              final response = await SubjectService.createSubject(request);

              if (response.isSuccess) {
                Navigator.pop(context);
                _loadSubjects();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tạo môn học thành công!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response.message)),
                );
              }
            },
            child: Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showSubjectDetail(SubjectSummary subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subject.subjectName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mã môn: ${subject.subjectCode}'),
              SizedBox(height: 8),
              if (subject.credits != null) 
                Text('Số tín chỉ: ${subject.credits}'),
              if (subject.teacherName != null) 
                Text('Giáo viên: ${subject.teacherName}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _editSubject(SubjectSummary subject) {
    final subjectCodeController = TextEditingController(text: subject.subjectCode);
    final subjectNameController = TextEditingController(text: subject.subjectName);
    final creditsController = TextEditingController(text: subject.credits?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa môn học'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectCodeController,
                decoration: InputDecoration(
                  labelText: 'Mã môn học',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: subjectNameController,
                decoration: InputDecoration(
                  labelText: 'Tên môn học',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tín chỉ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectCodeController.text.isEmpty || subjectNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng nhập mã môn và tên môn')),
                );
                return;
              }

              final request = UpdateSubjectRequest(
                subjectCode: subjectCodeController.text,
                subjectName: subjectNameController.text,
                credits: creditsController.text.isNotEmpty ? int.tryParse(creditsController.text) : null,
              );

              final response = await SubjectService.updateSubject(subject.subjectId, request);

              if (response.isSuccess) {
                Navigator.pop(context);
                _loadSubjects();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cập nhật môn học thành công!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response.message)),
                );
              }
            },
            child: Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(SubjectSummary subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa môn học'),
        content: Text('Bạn có chắc chắn muốn xóa môn ${subject.subjectName}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await SubjectService.deleteSubject(subject.subjectId);

              if (response.isSuccess) {
                _loadSubjects();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa môn học thành công!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response.message)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}