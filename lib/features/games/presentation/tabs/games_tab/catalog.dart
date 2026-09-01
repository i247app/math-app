part of '../games_tab.dart';

class _GamesCatalog extends StatelessWidget {
  const _GamesCatalog({
    super.key,
    required this.selectedGrade,
    required this.bottomPadding,
    required this.onChangeGrade,
    required this.onSelected,
  });

  final GradeModel selectedGrade;
  final double bottomPadding;
  final VoidCallback onChangeGrade;
  final ValueChanged<_GamePreview> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final games = _gamePreviews(context);
    return ColoredBox(
      color: colors.pageBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              sliver: SliverToBoxAdapter(
                child: AppStaggeredEntrance(
                  order: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _GamesEyebrow(
                              label: context.getText(AppKeys.navGames),
                            ),
                          ),
                          _GradeChip(
                            label: selectedGrade.label?.trim() ?? '',
                            onTap: onChangeGrade,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        context.getText(AppKeys.gamesChooseTitle),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        context.getText(AppKeys.gamesChooseSubtitle),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
              sliver: SliverList.separated(
                itemCount: games.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) => AppStaggeredEntrance(
                  order: index + 1,
                  child: _GamePreviewCard(
                    game: games[index],
                    onTap: () => onSelected(games[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesMap extends StatelessWidget {
  const _GamesMap({
    super.key,
    required this.game,
    required this.grade,
    required this.completedStages,
    required this.bottomPadding,
    required this.onBack,
    required this.onLevelTap,
  });

  final _GamePreview game;
  final GradeModel grade;
  final int completedStages;
  final double bottomPadding;
  final VoidCallback onBack;
  final ValueChanged<PracticeLesson> onLevelTap;

  @override
  Widget build(BuildContext context) {
    final lessons = List.generate(
      game.levelCount,
      (index) => PracticeLesson(
        number: index + 1,
        title: game.levelTitleKeys == null
            ? context.formatText(AppKeys.gamesLevelLabel, {'level': index + 1})
            : context.getText(game.levelTitleKeys![index]),
      ),
    );
    final chapter = PracticeChapter(
      id: 'game-${game.id}',
      number: 1,
      title: game.title,
      description: grade.label,
      lessons: lessons,
      completedLessons: completedStages,
      icon: game.id == 'monster-rescue' ? '🐾' : '🎮',
    );

    return PracticeChapterScreen(
      chapter: chapter,
      embedded: true,
      bottomPadding: bottomPadding,
      onLessonTap: onLevelTap,
      onEmbeddedBack: onBack,
      showEmbeddedChapterLabel: false,
    );
  }
}

class _GamesEyebrow extends StatelessWidget {
  const _GamesEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: colors.brandStrong,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
      ),
    );
  }
}
