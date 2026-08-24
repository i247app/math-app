import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/shared/parent_home_helpers.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';

class ParentClassCarousel extends StatefulWidget {
  const ParentClassCarousel({
    super.key,
    required this.summaries,
    required this.onTap,
  });

  final List<ParentChildSummary> summaries;
  final VoidCallback onTap;

  @override
  State<ParentClassCarousel> createState() => _ParentClassCarouselState();
}

class _ParentClassCarouselState extends State<ParentClassCarousel> {
  static const _cardHeight = 154.0;
  static const _cardGap = 16.0;
  static const _maxCardWidth = 200.0;

  int _activeIndex = 0;

  List<ParentChildSummary> get _joinedClassSummaries {
    return <ParentChildSummary>[
      for (final summary in widget.summaries)
        for (final classroom
            in summary.classrooms.isNotEmpty
                ? summary.classrooms
                : <ClassroomModel>[?summary.classroom])
          ParentChildSummary(profile: summary.profile, classroom: classroom),
    ];
  }

  @override
  void didUpdateWidget(covariant ParentClassCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final joinedClassCount = _joinedClassSummaries.length;
    if (_activeIndex >= joinedClassCount) {
      _activeIndex = math.max(0, joinedClassCount - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final joinedClassSummaries = _joinedClassSummaries;

    if (joinedClassSummaries.isEmpty) {
      return const SizedBox.shrink();
    }

    if (joinedClassSummaries.length == 1) {
      final summary = joinedClassSummaries.first;

      return SizedBox(
        height: _cardHeight,
        child: _buildClassCard(context, summary: summary, index: 0),
      );
    }

    if (joinedClassSummaries.length == 2) {
      return SizedBox(
        height: _cardHeight,
        child: Row(
          children: [
            for (
              var index = 0;
              index < joinedClassSummaries.length;
              index++
            ) ...[
              if (index > 0) const SizedBox(width: _cardGap),
              Expanded(
                child: _buildClassCard(
                  context,
                  summary: joinedClassSummaries[index],
                  index: index,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = math.min(_maxCardWidth, constraints.maxWidth);
        final trailingSpace = math.max(0.0, constraints.maxWidth - cardWidth);
        final itemExtent = cardWidth + _cardGap;

        return Column(
          children: [
            SizedBox(
              height: _cardHeight,
              child: NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  final nextIndex = (notification.metrics.pixels / itemExtent)
                      .round()
                      .clamp(0, joinedClassSummaries.length - 1);
                  if (nextIndex != _activeIndex) {
                    setState(() => _activeIndex = nextIndex);
                  }
                  return false;
                },
                child: ListView.separated(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(right: trailingSpace),
                  itemCount: joinedClassSummaries.length,
                  separatorBuilder: (_, _) => const SizedBox(width: _cardGap),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildClassCard(
                        context,
                        summary: joinedClassSummaries[index],
                        index: index,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (
                    var index = 0;
                    index < joinedClassSummaries.length;
                    index++
                  )
                    AnimatedContainer(
                      key: ValueKey('parent-class-page-dot-$index'),
                      duration: const Duration(milliseconds: 180),
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _activeIndex
                            ? AppColors.brandTealSolid
                            : AppColors.inactiveDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required ParentChildSummary summary,
    required int index,
  }) {
    final teacherName = summary.classroom?.teacherName?.trim();

    return _ParentClassCard(
      key: ValueKey('parent-class-card-$index'),
      studentName: profileDisplayName(context, summary.profile),
      className: parentClassroomName(context, summary),
      teacherName: teacherName?.isNotEmpty == true
          ? teacherName!
          : context.getText(AppKeys.parentNoTeacher),
      backgroundColor: index.isEven
          ? AppColors.brandTeal
          : AppColors.brandOrange,
      onTap: widget.onTap,
    );
  }
}

class _ParentClassCard extends StatelessWidget {
  const _ParentClassCard({
    super.key,
    required this.studentName,
    required this.className,
    required this.teacherName,
    required this.backgroundColor,
    required this.onTap,
  });

  final String studentName;
  final String className;
  final String teacherName;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30);

    return Semantics(
      button: true,
      label: '$studentName, $className, $teacherName',
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor, borderRadius: radius),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    studentName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      height: 1.1,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          className,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 58,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    teacherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
