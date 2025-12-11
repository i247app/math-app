import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/ui/math%20test%20process/view/math_result_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/info_row.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/question_board.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/answer_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/error_screen.dart';
import 'package:math_ai_app/data/providers/quiz_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';

class MathQuizScreen extends StatefulWidget {
  final bool isPractice;

  const MathQuizScreen({super.key, this.isPractice = false});

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  Timer? _timer;
  Timer? _animationTimer;
  bool isSubmitting = false;
  bool _showLoading = true;
  int _animationKey = 0;

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
    _animationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    _startAnimationTimer();

    final userProvider = context.read<UserProvider>();
    final uid = userProvider.user?.id;
    if (uid != null && uid.isNotEmpty) {
      final quizProvider = context.read<QuizProvider>();

      if (widget.isPractice) {
        await quizProvider.generatePractice(uid);
      } else {
        await quizProvider.generateQuiz(uid);
      }
      if (quizProvider.questions != null &&
          quizProvider.questions!.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
          setState(() {
            _showLoading = false;
          });
          _animationTimer?.cancel();
          _startTimer();
        }
      } else {
        if (mounted) {
          setState(() {
            _showLoading = false;
          });
          _animationTimer?.cancel();
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _showLoading = false;
        });
        _animationTimer?.cancel();
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

  void _startAnimationTimer() {
    _animationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _showLoading) {
        setState(() {
          _animationKey++;
        });
      } else {
        _animationTimer?.cancel();
      }
    });
  }

  Future<void> _autoSubmit() async {
    setState(() {
      isSubmitting = true;
      _showLoading = true;
    });
    _animationTimer?.cancel();
    _startAnimationTimer();
    final userProvider = context.read<UserProvider>();
    final uid = userProvider.user?.id;
    if (uid != null && uid.isNotEmpty) {
      final quizProvider = context.read<QuizProvider>();
      final success = await quizProvider.submitQuiz(uid);
      if (success && mounted) {
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ResultScreen()),
          );
        }
      } else if (mounted) {
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
      quizProvider.currentQuestion!.questionNumber!,
      answerLabel,
    );

    Future.delayed(const Duration(milliseconds: 200), () async {
      if (quizProvider.currentQuestionIndex >=
          quizProvider.totalQuestions - 1) {
        if (quizProvider.isLastQuiz) {
          _timer?.cancel();
          await _autoSubmit();
        } else {
          if (!mounted) return;
          final userProvider = context.read<UserProvider>();
          final uid = userProvider.user?.id;
          if (uid != null && uid.isNotEmpty) {
            await quizProvider.loadNextQuiz(uid);
          }
        }
      } else {
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
                    Color(0xFFFFF8E1),
                    Color(0xFFFFE082),
                    Color(0xFFFFD54F),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.8, end: 1.2),
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 360 * 100),
                              duration: const Duration(seconds: 120),
                              curve: Curves.linear,
                              builder: (context, rotation, child) {
                                return Transform.rotate(
                                  angle: rotation * 3.14159 / 180,
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

                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 11),
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

                      const SizedBox(height: 30),

                      SizedBox(
                        key: ValueKey(_animationKey),
                        height: 100,
                        child: Stack(
                          children: [
                            TweenAnimationBuilder<Offset>(
                              tween: Tween<Offset>(
                                begin: const Offset(-100, 10),
                                end: const Offset(450, -30),
                              ),
                              duration: const Duration(seconds: 4),
                              curve: Curves.easeInOut,
                              builder: (context, offset, child) {
                                return Positioned(
                                  left: offset.dx,
                                  top: offset.dy,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            '➕',
                                            style: TextStyle(
                                              fontSize: 28,
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
                                begin: const Offset(500, 5),
                                end: const Offset(-80, -25),
                              ),
                              duration: const Duration(seconds: 4),
                              curve: Curves.easeInOut,
                              builder: (context, offset, child) {
                                return Positioned(
                                  left: offset.dx,
                                  top: offset.dy,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            '➗',
                                            style: TextStyle(
                                              fontSize: 28,
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
                                begin: const Offset(-80, 35),
                                end: const Offset(480, -15),
                              ),
                              duration: const Duration(seconds: 4),
                              curve: Curves.easeInOut,
                              builder: (context, offset, child) {
                                return Positioned(
                                  left: offset.dx,
                                  top: offset.dy,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            '✖️',
                                            style: TextStyle(
                                              fontSize: 26,
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
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Không thể quay lại trong khi đang làm bài kiểm tra',
                    ),
                  ),
                );
              }
            },
            child: const Scaffold(
              backgroundColor: Color(0xFFE3F2FD),
              body: Center(child: Text('No questions available')),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Không thể quay lại trong khi đang làm bài kiểm tra',
                  ),
                ),
              );
            }
          },
          child: Scaffold(
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
                        const SizedBox(height: 30),
                        Text(
                          "KIỂM TRA",
                          style: GoogleFonts.nunito(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 50),
                        InfoRow(
                          remainingTime: quizProvider.remainingTime,
                          currentQuestion:
                              quizProvider.currentQuestionIndex + 1,
                          totalQuestions: quizProvider.totalQuestions,
                        ),

                        const SizedBox(height: 10),

                        QuestionBoard(
                          question:
                              quizProvider.currentQuestion?.questionName ?? '',
                        ),

                        const SizedBox(height: 30),

                        Expanded(
                          child: AnswerSection(
                            question: quizProvider.currentQuestion,
                            selectedAnswer: quizProvider
                                .getSelectedAnswerForCurrentQuestion(),
                            onAnswerSelected: _onAnswerSelected,
                            onNext: null,
                            onPrevious: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
