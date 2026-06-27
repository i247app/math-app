part of '../../../home_screen.dart';

class _ParentLearningStreakCard extends StatelessWidget {
  const _ParentLearningStreakCard({
    required this.hasCompletedAssessment,
  });

  final bool hasCompletedAssessment;

  @override
  Widget build(BuildContext context) {
    final dayLabels = <String>[
      context.getText(AppKeys.parentWeekdaySun),
      context.getText(AppKeys.parentWeekdayMon),
      context.getText(AppKeys.parentWeekdayTue),
      context.getText(AppKeys.parentWeekdayWed),
      context.getText(AppKeys.parentWeekdayThu),
      context.getText(AppKeys.parentWeekdayFri),
      context.getText(AppKeys.parentWeekdaySat),
    ];
    final states = hasCompletedAssessment
        ? const <_ParentStreakDayState>[
            _ParentStreakDayState.done,
            _ParentStreakDayState.done,
            _ParentStreakDayState.done,
            _ParentStreakDayState.current,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
          ]
        : const <_ParentStreakDayState>[
            _ParentStreakDayState.current,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
            _ParentStreakDayState.upcoming,
          ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF0DFD8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.getText(AppKeys.parentLearningStreak),
            style: const TextStyle(
              color: Color(0xFF282828),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dayLabels.length,
              (index) => _ParentStreakDay(
                label: dayLabels[index],
                state: states[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
