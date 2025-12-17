import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/data/providers/grades_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:math_ai_app/ui/level%20selection/view/level_selection_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:provider/provider.dart';

import '../widget/class_card_widget.dart';
import '../../math test process/view/math_quizz_screen.dart';
import '../../../data/models/grades/grade_model.dart';

class ClassSelectionScreen extends StatefulWidget {
  final bool isForUpdate;
  final bool isAssessmentFlow;

  const ClassSelectionScreen({
    super.key,
    this.isForUpdate = false,
    this.isAssessmentFlow = false,
  });

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen>
    with TickerProviderStateMixin {
  int? selectedIndex;
  bool _navigating = false;
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

  void _selectClass(int index, GradeModel grade) {
    setState(() {
      selectedIndex = index;
    });
    _animationController.forward();

    // Auto-advance after selection
    _goNext(grade);
  }

  void _goNext(GradeModel grade) {
    if (_navigating) return;
    _navigating = true;

    context.read<UserProvider>().setSelectedGrade(grade);
    context.read<UserProvider>().setUserClass(grade.label);

    if (widget.isAssessmentFlow) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LevelSelectionScreen(
            isAssessmentFlow: true,
            gradeId: grade.id,
            gradeLabel: grade.label,
          ),
        ),
      );
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LevelSelectionScreen()));
    }

    // allow subsequent navigation after this frame to avoid rapid double taps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigating = false;
    });
  }

  void _skipToQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MathQuizScreen()),
    );
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
                              final grade = grades[index];
                              return AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: isSelected
                                        ? _scaleAnimation.value
                                        : 1.0,
                                    child: ClassCard(
                                      data: grade,
                                      isSelected: isSelected,
                                      onTap: () => _selectClass(index, grade),
                                      selectionAnimation: _fadeAnimation.value,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (widget.isAssessmentFlow) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _skipToQuiz,
                              child: const Text('Skip'),
                            ),
                          ),
                        ],
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
