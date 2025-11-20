import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/ui/math%20test%20process/view/math_test_intro_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';

import '../data/class_item_data.dart';
import '../widget/class_card_widget.dart';

class ClassSelectionScreen extends StatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen>
    with TickerProviderStateMixin {
  int? selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectClass(int index) {
    setState(() {
      selectedIndex = index;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final List<ClassItemData> classes = [
      ClassItemData(
        title: "Mẫu giáo",
        imagePath: "assets/imgs/maugiao.jpg",
        color: const Color(0xFF9FE6D8),
      ),
      ClassItemData(
        title: "Lớp 1",
        imagePath: "assets/imgs/lop1.jpg",
        color: const Color(0xFFFFD561),
      ),
      ClassItemData(
        title: "Lớp 2",
        imagePath: "assets/imgs/lop2.jpg",
        color: const Color(0xFFFF8A65),
      ),
      ClassItemData(
        title: "Lớp 3",
        imagePath: "assets/imgs/lop3.jpg",
        color: const Color(0xFFAEDEF4),
      ),
      ClassItemData(
        title: "Lớp 4",
        imagePath: "assets/imgs/lop4.jpg",
        color: const Color(0xFFC5E1A5),
      ),
      ClassItemData(
        title: "Lớp 5",
        imagePath: "assets/imgs/lop5.jpg",
        color: const Color(0xFFF8BBD0),
        hasBadge: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(),
              const SizedBox(height: 40),

              Text(
                "Chọn Lớp Học\ncủa bạn!",
                style: GoogleFonts.nunito(
                  fontSize: 40,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1C),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: classes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isSelected ? _scaleAnimation.value : 1.0,
                          child: ClassCard(
                            data: classes[index],
                            isSelected: isSelected,
                            onTap: () => _selectClass(index),
                            selectionAnimation: _fadeAnimation.value,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: selectedIndex != null
                        ? () {
                            final selectedClass = classes[selectedIndex!];
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã chọn ${selectedClass.title}',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF4CAF50),
                                duration: const Duration(seconds: 1),
                              ),
                            );

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MathTestIntroScreen(),
                                  ),
                                );
                              },
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedIndex != null
                          ? const Color(0xFF3E2723)
                          : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: selectedIndex != null ? 2 : 0,
                    ),
                    child: Text(
                      selectedIndex != null ? "Tiếp Tục" : "Chọn lớp học",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        color: selectedIndex != null
                            ? Colors.white
                            : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
