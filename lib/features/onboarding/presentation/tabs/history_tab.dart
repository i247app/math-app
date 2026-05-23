import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/quiz_models.dart';
import '../../data/otp_auth_api.dart';
import '../../data/quiz_api.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _orange = Color(0xFFDE5E31);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

class HistoryTab extends StatefulWidget {
  const HistoryTab({
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

  _HistoryFilter _selectedFilter = _HistoryFilter.all;
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

  void _selectFilter(_HistoryFilter filter) {
    HapticFeedback.selectionClick();
    setState(() => _selectedFilter = filter);
  }

  List<GeneratedQuiz> get _filteredQuizzes {
    final query = _searchController.text.trim().toLowerCase();
    return _quizzes.where((quiz) {
      final matchesFilter = _selectedFilter == _HistoryFilter.all ||
          _quizFilterOf(quiz) == _selectedFilter;
      if (!matchesFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        26 * scale,
        24 * scale,
        widget.bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HistoryTitleRow(scale: scale),
          SizedBox(height: 26 * scale),
          _HistorySearchField(
            controller: _searchController,
            scale: scale,
          ),
          SizedBox(height: 22 * scale),
          _HistoryFilterBar(
            selected: _selectedFilter,
            onSelected: _selectFilter,
            scale: scale,
          ),
          SizedBox(height: 26 * scale),
          _HistorySectionHeader(scale: scale),
          SizedBox(height: 18 * scale),
          if (_isLoading)
            _HistoryLoadingState(scale: scale)
          else if (_errorMessage != null)
            _HistoryMessageState(
              icon: Icons.cloud_off_rounded,
              title: 'Chưa tải được lịch sử',
              subtitle: _errorMessage!,
              actionLabel: 'THỬ LẠI',
              onAction: _loadHistory,
              scale: scale,
            )
          else if (quizzes.isEmpty)
            _HistoryMessageState(
              icon: Icons.history_toggle_off_rounded,
              title: 'Chưa có bài phù hợp',
              subtitle: 'Đổi từ khóa hoặc tab để xem các bài khác.',
              scale: scale,
            )
          else
            for (final quiz in quizzes) ...[
              _HistoryQuizCard(quiz: quiz, scale: scale),
              SizedBox(height: 18 * scale),
            ],
        ],
      ),
    );
  }
}

class _HistoryTitleRow extends StatelessWidget {
  const _HistoryTitleRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Lịch sử kiểm tra',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _teal,
              fontFamily: 'Nunito',
              fontSize: 24 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Icon(
          Icons.more_vert_rounded,
          color: _teal,
          size: 28 * scale,
        ),
      ],
    );
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
    return SizedBox(
      height: 56 * scale,
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: _deepInk,
          fontFamily: 'Nunito',
          fontSize: 15 * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài kiểm tra...',
          hintStyle: TextStyle(
            color: _muted.withValues(alpha: 0.45),
            fontFamily: 'Nunito',
            fontSize: 15 * scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _teal,
            size: 28 * scale,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.28),
          contentPadding: EdgeInsets.symmetric(horizontal: 18 * scale),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26 * scale),
            borderSide: BorderSide(
              color: const Color(0xFF9DB8A2).withValues(alpha: 0.42),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26 * scale),
            borderSide: BorderSide(
              color: const Color(0xFF9DB8A2).withValues(alpha: 0.42),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26 * scale),
            borderSide: BorderSide(color: _teal, width: 1.4 * scale),
          ),
        ),
      ),
    );
  }
}

class _HistoryFilterBar extends StatelessWidget {
  const _HistoryFilterBar({
    required this.selected,
    required this.onSelected,
    required this.scale,
  });

  final _HistoryFilter selected;
  final ValueChanged<_HistoryFilter> onSelected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final filter = _historyFilters[index];
          final isSelected = filter.value == selected;
          return _HistoryFilterChip(
            label: filter.label,
            isSelected: isSelected,
            onTap: () => onSelected(filter.value),
            scale: scale,
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 14 * scale),
        itemCount: _historyFilters.length,
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48 * scale,
      child: Material(
        color: isSelected ? _teal : Colors.white,
        elevation: isSelected ? 8 : 2,
        shadowColor: isSelected
            ? _teal.withValues(alpha: 0.24)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24 * scale),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26 * scale),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : _deepInk,
                  fontFamily: 'Nunito',
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistorySectionHeader extends StatelessWidget {
  const _HistorySectionHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Gần đây',
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 23 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Icon(
          Icons.tune_rounded,
          color: _muted,
          size: 26 * scale,
        ),
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
    final correct = grading?.correctNumber;
    final total = grading?.totalQuestions ?? quiz.questions.length;
    final percent = grading?.scorePercentage;
    final hasScore = correct != null && total > 0;
    final scoreColors = _scoreColors(percent);

    return Container(
      constraints: BoxConstraints(minHeight: 144 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: _teal.withValues(alpha: 0.08),
            blurRadius: 22 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10 * scale,
            bottom: 10 * scale,
            child: Container(
              width: 4 * scale,
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8 * scale),
                  bottomRight: Radius.circular(8 * scale),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              26 * scale,
              22 * scale,
              18 * scale,
              20 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatHistoryDate(quiz.createDt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _muted.withValues(alpha: 0.58),
                              fontFamily: 'Nunito',
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            _quizTitle(quiz),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _deepInk,
                              fontFamily: 'Nunito',
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    if (hasScore)
                      _HistoryScoreBadge(
                        correct: correct,
                        total: total,
                        colors: scoreColors,
                        scale: scale,
                      )
                    else
                      _HistoryIncompleteBadge(
                        scale: scale,
                      ),
                  ],
                ),
                SizedBox(height: 26 * scale),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: _muted.withValues(alpha: 0.72),
                      size: 20 * scale,
                    ),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Text(
                        '${quiz.questions.length} câu hỏi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _muted,
                          fontFamily: 'Nunito',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _teal,
                      size: 32 * scale,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryScoreBadge extends StatelessWidget {
  const _HistoryScoreBadge({
    required this.correct,
    required this.total,
    required this.colors,
    required this.scale,
  });

  final int correct;
  final int total;
  final _ScoreBadgeColors colors;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78 * scale,
      height: 64 * scale,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(32 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: colors.foreground,
                fontFamily: 'Nunito',
                letterSpacing: 0,
              ),
              children: [
                TextSpan(
                  text: '$correct',
                  style: TextStyle(
                    fontSize: 27 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: '/$total',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'ĐIỂM SỐ',
            style: TextStyle(
              color: colors.foreground,
              fontFamily: 'Nunito',
              fontSize: 9 * scale,
              fontWeight: FontWeight.w900,
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
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 96 * scale),
      child: Text(
        'Chưa hoàn thành',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: _orange,
          fontFamily: 'Nunito',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w900,
          height: 1.05,
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
      height: 168 * scale,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28 * scale),
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
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28 * scale),
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

enum _HistoryFilter { all, review, assessment, practice }

class _HistoryFilterData {
  const _HistoryFilterData(this.value, this.label);

  final _HistoryFilter value;
  final String label;
}

const _historyFilters = <_HistoryFilterData>[
  _HistoryFilterData(_HistoryFilter.all, 'Tất cả'),
  _HistoryFilterData(_HistoryFilter.review, 'Ôn tập'),
  _HistoryFilterData(_HistoryFilter.assessment, 'Kiểm Tra'),
  _HistoryFilterData(_HistoryFilter.practice, 'Luyện Tập'),
];

class _ScoreBadgeColors {
  const _ScoreBadgeColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

_HistoryFilter _quizFilterOf(GeneratedQuiz quiz) {
  final type = quiz.type?.toUpperCase();
  if (type == 'ASSESSMENT') {
    return _HistoryFilter.assessment;
  }
  if (type == 'PRACTICE') {
    return _HistoryFilter.practice;
  }
  return _HistoryFilter.review;
}

String _quizTitle(GeneratedQuiz quiz) {
  final grade = quiz.grading?.aiDetectGrade?.trim();
  final suffix = grade != null && grade.isNotEmpty ? ' $grade' : '';
  switch (_quizFilterOf(quiz)) {
    case _HistoryFilter.assessment:
      return 'Bài kiểm tra Toán$suffix';
    case _HistoryFilter.practice:
      return 'Bài luyện tập Toán$suffix';
    case _HistoryFilter.review:
      return 'Bài ôn tập Toán$suffix';
    case _HistoryFilter.all:
      return 'Bài học Toán$suffix';
  }
}

_ScoreBadgeColors _scoreColors(int? percent) {
  if (percent == null || percent >= 85) {
    return const _ScoreBadgeColors(
      background: _teal,
      foreground: Colors.white,
    );
  }
  if (percent >= 70) {
    return const _ScoreBadgeColors(
      background: Color(0xFFE4F3F0),
      foreground: _teal,
    );
  }
  return const _ScoreBadgeColors(
    background: Color(0xFFF7E8E3),
    foreground: _orange,
  );
}

String _formatHistoryDate(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return 'Không rõ thời gian';
  }

  final parsed = DateTime.tryParse(isoDate)?.toLocal();
  if (parsed == null) {
    return isoDate;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(parsed.year, parsed.month, parsed.day);
  final time = '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}';
  final difference = today.difference(date).inDays;

  if (difference == 0) {
    return 'Hôm nay, $time';
  }
  if (difference == 1) {
    return 'Hôm qua, $time';
  }

  return '${_twoDigits(parsed.day)}/${_twoDigits(parsed.month)}, $time';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

