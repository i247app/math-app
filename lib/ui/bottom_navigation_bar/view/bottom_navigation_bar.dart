import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/ui/math%20test%20process/view/math_test_intro_screen.dart';
import '../sub_view/profile_screen.dart';
import 'placeholder_screen.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  final int initialIndex;
  const BottomNavigationBarScreen({super.key, this.initialIndex = 3});

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  late int _currentIndex; // Mặc định mở tab Profile (index 3)

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const PlaceholderScreen(title: "Trang Chủ", color: Colors.blueAccent),
    const MathTestIntroScreen(),
    const PlaceholderScreen(title: "Tiến Độ", color: Colors.greenAccent),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      // IndexedStack giúp giữ trạng thái màn hình, không bị load lại khi chuyển tab
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.05).toInt()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFFB300),
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Trang Chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: "Bài Kiểm Tra",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_edu),
              label: "Tiến Độ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: "Hồ Sơ",
            ),
          ],
        ),
      ),
    );
  }
}
