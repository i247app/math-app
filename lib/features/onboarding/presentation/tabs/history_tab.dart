import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/quiz_models.dart';
import '../../data/otp_auth_api.dart';
import '../../data/quiz_api.dart';

const _teal = Color(0xFF006762);
const _blue = Color(0xFF0B74B9);
const _muted = Color(0xFF5D4A54);
const _deepInk = Color(0xFF1F2B2B);
const _navy = Color(0xFF063A7B);
const _orange = Color(0xFFDE8C4B);
const _historyBackground = Color(0xFFEEF9FB);
const _cardBorder = Color(0xFFE3DDDF);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

class HistoryTab extends StatefulWidget {
  const HistoryTab({
    super.key,
    required this.user,
    required this.bottomPadding,
    required this.scale,
  });

  final LoginUser? user;
  final double bottomPadding;
  final double scale;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late final QuizService _quizService =
      _useFakeQuizApi ? const FakeQuizApi() : QuizApi();
  final TextEditingController _searchController = TextEditingController();

  List<GeneratedQuiz> _quizzes = const <GeneratedQuiz>[];
  bool _isLoading = true;
  String? _errorMessage;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSearch);
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant HistoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _loadHistory();
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshSearch)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final requestId = ++_loadRequestId;
    final userId = widget.user?.id.trim();
    if (userId == null || userId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Chưa có thông tin tài khoản để tải lịch sử.';
        _quizzes = const <GeneratedQuiz>[];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quizzes = await _quizService.listQuizzes(userId: userId);
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } on QuizException catch (error) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _errorMessage = 'Tải lịch sử thất bại.';
        _isLoading = false;
      });
    }
  }

  void _refreshSearch() {
    setState(() {});
  }

  List<GeneratedQuiz> get _filteredQuizzes {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _quizzes;
    }

    return _quizzes.where((quiz) {
      final searchable = <String>[
        _quizTitle(quiz),
        quiz.type ?? '',
        quiz.quizStatus ?? '',
        quiz.grading?.aiDetectGrade ?? '',
        ...quiz.questions.map((question) => question.questionName),
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final quizzes = _filteredQuizzes;

    return ColoredBox(
      color: _historyBackground,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HistoryHeader(scale: scale),
            SizedBox(height: 46 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26 * scale),
              child: _HistorySearchField(
                controller: _searchController,
                scale: scale,
              ),
            ),
            SizedBox(height: 40 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26 * scale),
              child: _HistoryBody(
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                quizzes: quizzes,
                onRetry: _loadHistory,
                scale: scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124 * scale,
      child: CustomPaint(
        painter: _HistoryHeaderCurvePainter(scale: scale),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            30 * scale,
            28 * scale,
            30 * scale,
            24 * scale,
          ),
          child: Row(
            children: [
              SizedBox(width: 60 * scale),
              Expanded(
                child: Text(
                  'Lịch Sử',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _navy,
                    fontFamily: 'Nunito',
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _HistoryHeaderButton(
                icon: Icons.notifications_none_rounded,
                outlined: true,
                onTap: HapticFeedback.selectionClick,
                scale: scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryHeaderButton extends StatelessWidget {
  const _HistoryHeaderButton({
    required this.icon,
    required this.outlined,
    required this.onTap,
    required this.scale,
  });

  final IconData icon;
  final bool outlined;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 60 * scale;
    final radius = BorderRadius.circular(outlined ? 22 * scale : size / 2);

    return Material(
      color: Colors.white,
      elevation: outlined ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: outlined
                ? Border.all(
                    color: _deepInk.withValues(alpha: 0.72),
                    width: 1.5 * scale,
                  )
                : null,
            boxShadow: outlined
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: _teal, size: 29 * scale),
        ),
      ),
    );
  }
}

class _HistoryHeaderCurvePainter extends CustomPainter {
  const _HistoryHeaderCurvePainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = _historyBackground;
    canvas.drawRect(Offset.zero & size, background);

    final line = Paint()
      ..color = _orange.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * scale;
    final path = Path()
      ..moveTo(0, size.height - 17 * scale)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 2 * scale,
        size.width,
        size.height - 17 * scale,
      );
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _HistoryHeaderCurvePainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}

class _HistorySearchField extends StatelessWidget {
  const _HistorySearchField({
    required this.controller,
    required this.scale,
  });

  final TextEditingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30 * scale),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: _deepInk,
          fontFamily: 'Nunito',
          fontSize: 18 * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm ...',
          hintStyle: TextStyle(
            color: const Color(0xFFD8C5CC),
            fontFamily: 'Nunito',
            fontSize: 20 * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 18 * scale, right: 8 * scale),
            child: Icon(
              Icons.search_rounded,
              color: _navy,
              size: 30 * scale,
            ),
          ),
          suffixIcon: IconButton(
            onPressed: HapticFeedback.selectionClick,
            icon: Icon(
              Icons.tune_rounded,
              color: _navy,
              size: 30 * scale,
            ),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(
              vertical: 13 * scale, horizontal: 12 * scale),
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.isLoading,
    required this.errorMessage,
    required this.quizzes,
    required this.onRetry,
    required this.scale,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<GeneratedQuiz> quizzes;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _HistoryLoadingState(scale: scale);
    }

    if (errorMessage != null) {
      return _HistoryMessageState(
        icon: Icons.cloud_off_rounded,
        title: 'Chưa tải được lịch sử',
        subtitle: errorMessage!,
        actionLabel: 'THỬ LẠI',
        onAction: onRetry,
        scale: scale,
      );
    }

    if (quizzes.isEmpty) {
      return _HistoryMessageState(
        icon: Icons.history_toggle_off_rounded,
        title: 'Chưa có bài phù hợp',
        subtitle: 'Đổi từ khóa để xem các bài khác.',
        scale: scale,
      );
    }

    return Column(
      children: [
        for (final quiz in quizzes) ...[
          _HistoryQuizCard(quiz: quiz, scale: scale),
          SizedBox(height: 22 * scale),
        ],
      ],
    );
  }
}

class _HistoryQuizCard extends StatelessWidget {
  const _HistoryQuizCard({
    required this.quiz,
    required this.scale,
  });

  final GeneratedQuiz quiz;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final grading = quiz.grading;
    final percent = grading?.scorePercentage;
    final scoreColors = _scoreColors(percent);
    final dateParts = _historyDateParts(quiz.createDt);

    return Container(
      constraints: BoxConstraints(minHeight: 132 * scale),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        22 * scale,
        16 * scale,
        20 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: _cardBorder, width: 1.3 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (percent != null)
            _HistoryScoreBadge(
              percentage: percent,
              colors: scoreColors,
              scale: scale,
            )
          else
            _HistoryIncompleteBadge(scale: scale),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _quizTitle(quiz),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _deepInk,
                    fontFamily: 'Nunito',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.32,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 12 * scale),
                _HistoryMetaRow(parts: dateParts, scale: scale),
              ],
            ),
          ),
          SizedBox(width: 4 * scale),
          Icon(
            Icons.chevron_right_rounded,
            color: _muted.withValues(alpha: 0.78),
            size: 32 * scale,
          ),
        ],
      ),
    );
  }
}

class _HistoryMetaRow extends StatelessWidget {
  const _HistoryMetaRow({
    required this.parts,
    required this.scale,
  });

  final _HistoryDateParts parts;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14 * scale,
      runSpacing: 8 * scale,
      children: [
        _HistoryMetaItem(
          icon: Icons.calendar_month_outlined,
          label: parts.date,
          scale: scale,
        ),
        _HistoryMetaItem(
          icon: Icons.schedule_rounded,
          label: parts.time,
          scale: scale,
        ),
      ],
    );
  }
}

class _HistoryMetaItem extends StatelessWidget {
  const _HistoryMetaItem({
    required this.icon,
    required this.label,
    required this.scale,
  });

  final IconData icon;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _muted, size: 18 * scale),
        SizedBox(width: 6 * scale),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _muted,
            fontFamily: 'Nunito',
            fontSize: 11 * scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _HistoryScoreBadge extends StatelessWidget {
  const _HistoryScoreBadge({
    required this.percentage,
    required this.colors,
    required this.scale,
  });

  final int percentage;
  final _ScoreBadgeColors colors;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final scoreOutOf10 = (percentage / 10).round();
    return SizedBox(
      width: 74 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58 * scale,
            height: 58 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: colors.foreground,
                width: 6 * scale,
              ),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$scoreOutOf10/10',
                  maxLines: 1,
                  style: TextStyle(
                    color: colors.foreground,
                    fontFamily: 'Nunito',
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            colors.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.foreground,
              fontFamily: 'Nunito',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryIncompleteBadge extends StatelessWidget {
  const _HistoryIncompleteBadge({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74 * scale,
      child: Text(
        'Chưa xong',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _orange,
          fontFamily: 'Nunito',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _HistoryLoadingState extends StatelessWidget {
  const _HistoryLoadingState({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: _cardBorder),
      ),
      child: Center(
        child: SizedBox(
          width: 34 * scale,
          height: 34 * scale,
          child: const CircularProgressIndicator(
            color: _teal,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

class _HistoryMessageState extends StatelessWidget {
  const _HistoryMessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.scale,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(26 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: _teal, size: 42 * scale),
          SizedBox(height: 14 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontFamily: 'Nunito',
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 18 * scale),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: _teal,
                  fontFamily: 'Nunito',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreBadgeColors {
  const _ScoreBadgeColors({
    required this.foreground,
    required this.label,
  });

  final Color foreground;
  final String label;
}

class _HistoryDateParts {
  const _HistoryDateParts({
    required this.date,
    required this.time,
  });

  final String date;
  final String time;
}

String _quizTitle(GeneratedQuiz quiz) {
  if (quiz.title != null && quiz.title!.trim().isNotEmpty) {
    return quiz.title!;
  }

  final grade = quiz.grading?.aiDetectGrade?.trim();
  final suffix = grade != null && grade.isNotEmpty ? ' $grade' : '';
  final type = quiz.type?.toUpperCase();

  if (type == 'ASSESSMENT') {
    return 'Bài kiểm tra Toán$suffix';
  }
  if (type == 'PRACTICE') {
    return 'Bài luyện tập Toán$suffix';
  }
  return 'Bài ôn tập Toán$suffix';
}

_ScoreBadgeColors _scoreColors(int? percent) {
  if (percent == null) {
    return const _ScoreBadgeColors(
      foreground: Color(0xFF0A8A4D),
      label: 'Tuyệt vời!',
    );
  }

  final scoreOutOf10 = (percent / 10).round();

  if (scoreOutOf10 >= 9) {
    return const _ScoreBadgeColors(
      foreground: Color(0xFF0A8A4D), // Green
      label: 'Tuyệt vời!',
    );
  }
  if (scoreOutOf10 >= 7) {
    return const _ScoreBadgeColors(
      foreground: Color(0xFFFFC107), // Yellow
      label: 'Tốt',
    );
  }
  if (scoreOutOf10 >= 5) {
    return const _ScoreBadgeColors(
      foreground: Color(0xFFD2691E), // Brown-red
      label: 'Khá tốt',
    );
  }
  return const _ScoreBadgeColors(
    foreground: Color(0xFFD32F2F), // Red
    label: 'Cần luyện',
  );
}

_HistoryDateParts _historyDateParts(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return const _HistoryDateParts(date: '--/--/----', time: '--:--');
  }

  final parsed = DateTime.tryParse(isoDate)?.toLocal();
  if (parsed == null) {
    return _HistoryDateParts(date: isoDate, time: '--:--');
  }

  return _HistoryDateParts(
    date:
        '${_twoDigits(parsed.day)}/${_twoDigits(parsed.month)}/${parsed.year}',
    time: '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}',
  );
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
