import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/ui/math%20test%20process/view/math_result_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/info_row.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/question_board.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/answer_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/error_screen.dart';
import 'package:math_ai_app/data/providers/quiz_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';

class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({super.key});

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  Timer? _timer;
  bool isSubmitting = false;
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuiz();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    final userProvider = context.read<UserProvider>();
    final uid = userProvider.user?.id;
    if (uid != null && uid.isNotEmpty) {
      final quizProvider = context.read<QuizProvider>();
      await quizProvider.generateQuiz(uid);
      if (quizProvider.questions != null &&
          quizProvider.questions!.isNotEmpty) {
        // Allow loading animation to complete before showing quiz
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
          setState(() {
            _showLoading = false;
          });
          _startTimer();
        }
      } else {
        if (mounted) {
          setState(() {
            _showLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _showLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final quizProvider = context.read<QuizProvider>();
      final remainingTime = quizProvider.remainingTime - 1;
      quizProvider.updateTimer(remainingTime);

      if (remainingTime <= 0) {
        _timer?.cancel();
        _autoSubmit();
      }
    });
  }

  Future<void> _autoSubmit() async {
    setState(() {
      isSubmitting = true;
      _showLoading = true;
    });
    final userProvider = context.read<UserProvider>();
    final uid = userProvider.user?.id;
    if (uid != null && uid.isNotEmpty) {
      final quizProvider = context.read<QuizProvider>();
      final success = await quizProvider.submitQuiz(uid);
      if (success && mounted) {
        // Allow loading animation to complete before navigating
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ResultScreen()),
          );
        }
      } else if (mounted) {
        // Show error message
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
          setState(() {
            _showLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(quizProvider.error ?? 'Failed to submit quiz'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    if (mounted) {
      setState(() {
        isSubmitting = false;
        _showLoading = false;
      });
    }
  }

  void _onAnswerSelected(String answerLabel) {
    final quizProvider = context.read<QuizProvider>();
    quizProvider.selectAnswer(
      quizProvider.currentQuestion!.questionNumber,
      answerLabel,
    );

    // Auto proceed after selection
    Future.delayed(const Duration(milliseconds: 800), () async {
      if (quizProvider.currentQuestionIndex >=
          quizProvider.totalQuestions - 1) {
        // Last question in current quiz
        if (quizProvider.isLastQuiz) {
          // Last quiz, auto submit
          _timer?.cancel();
          await _autoSubmit();
        } else {
          // Load next quiz
          if (!mounted) return;
          final userProvider = context.read<UserProvider>();
          final uid = userProvider.user?.id;
          if (uid != null && uid.isNotEmpty) {
            await quizProvider.loadNextQuiz(uid);
          }
        }
      } else {
        // Next question in current quiz
        quizProvider.nextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (_showLoading || quizProvider.isLoading || isSubmitting) {
          return Scaffold(
            backgroundColor: Colors.blue.shade50,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF8E1), // Light yellow
                    Color(0xFFFFE082), // Yellow
                    Color(0xFFFFD54F), // Darker yellow
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated bee
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.8, end: 1.2),
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 360),
                              duration: const Duration(seconds: 4),
                              curve: Curves.linear,
                              builder: (context, rotation, child) {
                                return Transform.rotate(
                                  angle:
                                      rotation *
                                      3.14159 /
                                      180, // Convert to radians
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withAlpha(
                                        (255 * 0.9).toInt(),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(
                                            (255 * 0.1).toInt(),
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/imgs/bee.jpg',
                                          width: 60,
                                          errorBuilder: (c, o, s) => const Icon(
                                            Icons.bug_report,
                                            color: Colors.yellow,
                                            size: 40,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 15,
                                          child: TweenAnimationBuilder<double>(
                                            tween: Tween<double>(
                                              begin: 0,
                                              end: 1,
                                            ),
                                            duration: const Duration(
                                              milliseconds: 1500,
                                            ),
                                            curve: Curves.elasticOut,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: const Text(
                                                  '✨',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Animated loading text
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1500),
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: Text(
                              isSubmitting
                                  ? 'Đang nộp bài...'
                                  : 'Đang chuẩn bị bài kiểm tra...',
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3E2723),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Animated dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.5, end: 1.5),
                            duration: Duration(
                              milliseconds: 600 + (index * 200),
                            ),
                            curve: Curves.bounceOut,
                            builder: (context, scale, child) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3E2723),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // Circular progress indicator with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 6),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 6,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.lerp(
                                  Colors.yellow,
                                  Colors.orange,
                                  value,
                                )!,
                              ),
                              backgroundColor: Colors.white.withAlpha(
                                (255 * 0.3).toInt(),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Math symbols floating animation
                      SizedBox(
                        height: 60,
                        child: Stack(
                          children: [
                            TweenAnimationBuilder<Offset>(
                              tween: Tween<Offset>(
                                begin: const Offset(-50, 0),
                                end: const Offset(50, -20),
                              ),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, offset, child) {
                                return Positioned(
                                  left: 50 + offset.dx,
                                  top: 20 + offset.dy,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: 0.6,
                                          child: Text(
                                            '➕',
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            TweenAnimationBuilder<Offset>(
                              tween: Tween<Offset>(
                                begin: const Offset(100, 20),
                                end: const Offset(-30, -10),
                              ),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, offset, child) {
                                return Positioned(
                                  right: 50 + offset.dx,
                                  top: 10 + offset.dy,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: 0.6,
                                          child: Text(
                                            '➗',
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            TweenAnimationBuilder<Offset>(
                              tween: Tween<Offset>(
                                begin: const Offset(0, 40),
                                end: const Offset(80, -30),
                              ),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, offset, child) {
                                return Positioned(
                                  left: 100 + offset.dx,
                                  bottom: 10 + offset.dy,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: 0.6,
                                          child: Text(
                                            '✖️',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (quizProvider.error != null) {
          return ErrorScreen(
            errorMessage: quizProvider.error!,
            onRetry: _initializeQuiz,
          );
        }

        if (quizProvider.questions == null || quizProvider.questions!.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFE3F2FD),
            body: Center(child: Text('No questions available')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.blue.shade50,
          body: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      HeaderSection(),
                      const SizedBox(height: 10),
                      Text(
                        "KIỂM TRA",
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3E2723),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const SizedBox(height: 20),

                      InfoRow(
                        remainingTime: quizProvider.remainingTime,
                        currentQuestion: quizProvider.currentQuestionIndex + 1,
                        totalQuestions: quizProvider.totalQuestions,
                      ),

                      const SizedBox(height: 10),

                      QuestionBoard(
                        question:
                            quizProvider.currentQuestion?.questionName ?? '',
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: AnswerSection(
                          question: quizProvider.currentQuestion,
                          selectedAnswer: quizProvider
                              .getSelectedAnswerForCurrentQuestion(),
                          onAnswerSelected: _onAnswerSelected,
                          onNext: null, // Not used anymore
                          onPrevious: null, // Not used anymore
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
