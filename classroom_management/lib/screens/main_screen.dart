// screens/main_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'schedule_screen.dart';
import 'class_management_screen.dart';
import 'subject_management_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();

    if (widget.user.isTeacher) {
      // ===== GIÁO VIÊN: có tab Môn học =====
      _screens = [
        ScheduleScreen(user: widget.user),           // 0
        ClassManagementScreen(user: widget.user),    // 1
        SubjectManagementScreen(user: widget.user),  // 2
        NotificationScreen(user: widget.user),       // 3
        ProfileScreen(user: widget.user),            // 4
      ];

      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Lịch học',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Lớp học',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Môn học',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Thông báo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ];
    } else {
      // ===== HỌC SINH: ẩn tab Môn học =====
      _screens = [
        ScheduleScreen(user: widget.user),           // 0
        ClassManagementScreen(user: widget.user),    // 1 (nếu sau này có màn riêng cho HS thì đổi ở đây)
        NotificationScreen(user: widget.user),       // 2
        ProfileScreen(user: widget.user),            // 3
      ];

      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Lịch học',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Lớp học',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Thông báo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: _navItems,
      ),
    );
  }
}
