import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/data/providers/grades_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:math_ai_app/ui/level%20selection/view/level_selection_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:provider/provider.dart';

import '../widget/class_card_widget.dart';

class ClassSelectionScreen extends StatefulWidget {
  final bool isForUpdate;

  const ClassSelectionScreen({super.key, this.isForUpdate = false});

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

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesProvider>().loadGrades();
    });
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
    return Consumer<GradesProvider>(
      builder: (context, gradesProvider, child) {
        if (gradesProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (gradesProvider.error != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi tải dữ liệu: ${gradesProvider.error}',
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => gradesProvider.loadGrades(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final grades = gradesProvider.grades ?? [];
        

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
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
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: grades.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    scale: isSelected
                                        ? _scaleAnimation.value
                                        : 1.0,
                                    child: ClassCard(
                                      data: grades[index],
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

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: selectedIndex != null
                                  ? () {
                                      final selectedGrade =
                                          grades[selectedIndex!];

                                      
                                      context
                                          .read<UserProvider>()
                                          .setSelectedGrade(selectedGrade);
                                      context.read<UserProvider>().setUserClass(
                                        selectedGrade.label,
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã chọn ${selectedGrade.label}',
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFF4CAF50,
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );

                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          if (context.mounted) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const LevelSelectionScreen(),
                                              ),
                                            );
                                          }
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
                                selectedIndex != null
                                    ? "Tiếp Tục"
                                    : "Chọn lớp học",
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
