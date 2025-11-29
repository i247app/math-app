import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/ui/math%20test%20process/view/math_result_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/custom_progress_bar.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/info_row.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/question_board.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/answer_section.dart';
import 'package:math_ai_app/data/providers/quiz_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';

class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({super.key});

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  Timer? _timer;

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
        _startTimer();
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
    final userProvider = context.read<UserProvider>();
    final uid = userProvider.user?.id;
    if (uid != null && uid.isNotEmpty) {
      final quizProvider = context.read<QuizProvider>();
      await quizProvider.submitQuiz(uid);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
    }
  }

  void _handleNextPress() async {
    final userProvider = context.read<UserProvider>();
    final uid = userProvider.user?.id;
    if (uid == null || uid.isEmpty) return;

    final quizProvider = context.read<QuizProvider>();

    if (quizProvider.isLastQuiz) {
      _timer?.cancel();
      await _autoSubmit();
    } else {
      await quizProvider.loadNextQuiz(uid);
    }
  }

  void _handlePreviousPress() async {
    final quizProvider = context.read<QuizProvider>();
    quizProvider.loadPreviousQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (quizProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${quizProvider.error}'),
                  ElevatedButton(
                    onPressed: _initializeQuiz,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (quizProvider.questions == null || quizProvider.questions!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No questions available')),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/imgs/grass_background.png',
                  fit: BoxFit.cover,
                  height: 180,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.green.withAlpha((255 * 0.3).toInt()),
                  ),
                ),
              ),

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
                        "Kiểm Tra",
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3E2723),
                        ),
                      ),

                      const SizedBox(height: 10),

                      CustomProgressBar(
                        currentQuestion: quizProvider.currentQuestionIndex + 1,
                        totalQuestions: quizProvider.totalQuestions,
                        currentQuiz: quizProvider.currentQuizIndex + 1,
                        totalQuizzes: quizProvider.totalQuizzes,
                      ),

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
                          onAnswerSelected: (answerLabel) {
                            quizProvider.selectAnswer(
                              quizProvider.currentQuestion!.questionNumber,
                              answerLabel,
                            );
                          },
                          onNext:
                              quizProvider.currentQuestionIndex <
                                  quizProvider.totalQuestions - 1
                              ? () => quizProvider.nextQuestion()
                              : null,
                          onPrevious: quizProvider.currentQuestionIndex > 0
                              ? () => quizProvider.previousQuestion()
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: -10,
                child: Image.asset(
                  'assets/imgs/bee12.png',
                  height: 160,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.bug_report,
                    size: 100,
                    color: Colors.yellow,
                  ),
                ),
              ),

              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //   width: 80,
                      //   height: 56,
                      //   child: ElevatedButton(
                      //     onPressed: quizProvider.currentQuizIndex > 0
                      //         ? _handlePreviousPress
                      //         : null,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: quizProvider.currentQuizIndex > 0
                      //           ? const Color(0xFF4C3D3D)
                      //           : Colors.grey,
                      //       elevation: quizProvider.currentQuizIndex > 0
                      //           ? 5
                      //           : 0,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: 12,
                      //         vertical: 16,
                      //       ),
                      //     ),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Icon(
                      //           Icons.arrow_back,
                      //           color: Colors.white,
                      //           size: 20,
                      //         ),
                      //         SizedBox(width: 4),
                      //         Text(
                      //           'Trước',
                      //           style: GoogleFonts.nunito(
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w700,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 120,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              (quizProvider.isLastQuiz &&
                                  !quizProvider
                                      .isAllQuestionsAnsweredInCurrentQuiz)
                              ? null
                              : _handleNextPress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (quizProvider.isLastQuiz &&
                                    !quizProvider
                                        .isAllQuestionsAnsweredInCurrentQuiz)
                                ? Colors.grey
                                : const Color(0xFF4C3D3D),
                            elevation:
                                (quizProvider.isLastQuiz &&
                                    !quizProvider
                                        .isAllQuestionsAnsweredInCurrentQuiz)
                                ? 0
                                : 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                quizProvider.isLastQuiz ? 'Nộp' : 'Tiếp theo',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
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
