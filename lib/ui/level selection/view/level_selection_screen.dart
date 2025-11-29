import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/data/providers/levels_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:math_ai_app/data/providers/profile_provider.dart';
import 'package:math_ai_app/ui/bottom_navigation_bar/view/bottom_navigation_bar.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:provider/provider.dart';

import '../widget/level_card_widget.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
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

    // Load levels data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LevelsProvider>().loadLevels();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectLevel(int index) {
    setState(() {
      selectedIndex = index;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelsProvider>(
      builder: (context, levelsProvider, child) {
        if (levelsProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (levelsProvider.error != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi tải dữ liệu: ${levelsProvider.error}',
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => levelsProvider.loadLevels(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final levels = levelsProvider.levels ?? [];

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
                    "Chọn Mức Độ\ncủa bạn!",
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
                            itemCount: levels.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.8,
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
                                      final selectedLevel =
                                          levels[selectedIndex!];

                                      // Save selected level to user provider
                                      context.read<UserProvider>().setUserClass(
                                        '${context.read<UserProvider>().userClass} - ${selectedLevel.label}',
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã chọn ${selectedLevel.label}',
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
                                        () async {
                                          if (context.mounted) {
                                            // Get selected grade from UserProvider
                                            final userProvider = context
                                                .read<UserProvider>();
                                            final selectedGrade =
                                                userProvider.selectedGrade;

                                            // Get selected level
                                            final selectedLevel =
                                                levels[selectedIndex!];

                                            if (selectedGrade != null) {
                                              // Get user ID - try user.id first, fallback to email if id is null/empty
                                              final userId =
                                                  userProvider
                                                          .user
                                                          ?.id
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? userProvider.user!.id!
                                                  : userProvider.user?.email ??
                                                        '';

                                              if (userId.isEmpty) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }

                                              // Create profile
                                              if (!context.mounted) return;
                                              final profileProvider = context
                                                  .read<ProfileProvider>();
                                              final success =
                                                  await profileProvider
                                                      .createProfile(
                                                        uid: userId,
                                                        grade:
                                                            selectedGrade.label,
                                                        level:
                                                            selectedLevel.label,
                                                      );

                                              if (success && context.mounted) {
                                                Navigator.of(
                                                  context,
                                                ).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const BottomNavigationBarScreen(),
                                                  ),
                                                );
                                              } else {
                                                // Show error
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      profileProvider.error ??
                                                          'Tạo profile thất bại',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
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
                                    : "Chọn mức độ",
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
