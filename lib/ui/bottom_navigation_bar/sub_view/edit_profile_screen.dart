import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/data/providers/grades_provider.dart';
import 'package:math_ai_app/data/providers/levels_provider.dart';
import 'package:math_ai_app/data/providers/profile_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'package:math_ai_app/ui/class selection /widget/class_card_widget.dart';
import 'package:math_ai_app/ui/level selection/widget/level_card_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  int? selectedGradeIndex;
  int? selectedLevelIndex;
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
      _loadDataAndSetCurrentSelections();
    });
  }

  void _loadDataAndSetCurrentSelections() {
    final gradesProvider = context.read<GradesProvider>();
    final levelsProvider = context.read<LevelsProvider>();
    final profileProvider = context.read<ProfileProvider>();

    
    gradesProvider.loadGrades();
    levelsProvider.loadLevels();

    
    final currentGrade = profileProvider.profile?.grade;
    final currentLevel = profileProvider.profile?.level;

    
    if (currentGrade != null && gradesProvider.grades != null) {
      for (int i = 0; i < gradesProvider.grades!.length; i++) {
        if (gradesProvider.grades![i].label == currentGrade) {
          setState(() {
            selectedGradeIndex = i;
          });
          break;
        }
      }
    }

    
    if (currentLevel != null && levelsProvider.levels != null) {
      for (int i = 0; i < levelsProvider.levels!.length; i++) {
        if (levelsProvider.levels![i].label == currentLevel) {
          setState(() {
            selectedLevelIndex = i;
          });
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectGrade(int index) {
    setState(() {
      selectedGradeIndex = index;
    });
    _animationController.forward();
  }

  void _selectLevel(int index) {
    setState(() {
      selectedLevelIndex = index;
    });
    _animationController.forward();
  }

  Future<void> _updateProfile() async {
    if (selectedGradeIndex == null || selectedLevelIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn cả lớp và kì học'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final gradesProvider = context.read<GradesProvider>();
    final levelsProvider = context.read<LevelsProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final userProvider = context.read<UserProvider>();

    final selectedGrade = gradesProvider.grades![selectedGradeIndex!];
    final selectedLevel = levelsProvider.levels![selectedLevelIndex!];

    final uid = userProvider.user?.id;
    if (uid != null && uid.isNotEmpty) {
      final success = await profileProvider.updateProfile(
        uid: uid,
        gradeId: selectedGrade.id,
        semesterId: selectedLevel.id,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); 
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${profileProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Chỉnh Sửa Hồ Sơ",
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1C1C1C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              
              Text(
                "Chọn Lớp Học",
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 16),

              Consumer<GradesProvider>(
                builder: (context, gradesProvider, child) {
                  if (gradesProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (gradesProvider.error != null) {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            'Lỗi tải lớp học: ${gradesProvider.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: () => gradesProvider.loadGrades(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final grades = gradesProvider.grades ?? [];
                  return SizedBox(
                    height: 200,
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: grades.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemBuilder: (context, index) {
                        final isSelected = selectedGradeIndex == index;
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isSelected ? _scaleAnimation.value : 1.0,
                              child: ClassCard(
                                data: grades[index],
                                isSelected: isSelected,
                                onTap: () => _selectGrade(index),
                                selectionAnimation: _fadeAnimation.value,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              
              Text(
                "Chọn Kì Học",
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 16),

              Consumer<LevelsProvider>(
                builder: (context, levelsProvider, child) {
                  if (levelsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (levelsProvider.error != null) {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            'Lỗi tải kì học: ${levelsProvider.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: () => levelsProvider.loadLevels(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final levels = levelsProvider.levels ?? [];
                  return SizedBox(
                    height: 200,
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: levels.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemBuilder: (context, index) {
                        final isSelected = selectedLevelIndex == index;
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isSelected ? _scaleAnimation.value : 1.0,
                              child: LevelCard(
                                data: levels[index],
                                isSelected: isSelected,
                                onTap: () => _selectLevel(index),
                                selectionAnimation: _fadeAnimation.value,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),

              const Spacer(),

              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      (selectedGradeIndex != null && selectedLevelIndex != null)
                      ? _updateProfile
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (selectedGradeIndex != null &&
                            selectedLevelIndex != null)
                        ? const Color(0xFF3E2723)
                        : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation:
                        (selectedGradeIndex != null &&
                            selectedLevelIndex != null)
                        ? 2
                        : 0,
                  ),
                  child: Consumer<ProfileProvider>(
                    builder: (context, profileProvider, child) {
                      if (profileProvider.isLoading) {
                        return const CircularProgressIndicator(
                          color: Colors.white,
                        );
                      }
                      return Text(
                        "Cập Nhật Hồ Sơ",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          color:
                              (selectedGradeIndex != null &&
                                  selectedLevelIndex != null)
                              ? Colors.white
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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
