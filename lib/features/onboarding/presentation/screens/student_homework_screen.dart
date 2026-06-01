import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';

const _studentHomeworkBg = Color(0xFFF6FFFF);
const _studentHomeworkTeal = Color(0xFF38898C);
const _studentHomeworkActive = Color(0xFF2E6F70);
const _studentHomeworkInk = Color(0xFF001741);
const _studentHomeworkMuted = Color(0xFF444650);

class StudentHomeworkScreen extends StatelessWidget {
  const StudentHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _studentHomeworkBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _StudentHomeworkTopBar(
              title: context.getText(AppKeys.studentHomework),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  28,
                  20,
                  MediaQuery.paddingOf(context).bottom + 40,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HomeworkSearchField(),
                    SizedBox(height: 17),
                    _HomeworkFilterTabs(),
                    SizedBox(height: 18),
                    _HomeworkAssignmentCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentHomeworkTopBar extends StatelessWidget {
  const _StudentHomeworkTopBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/student_join_back.svg',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: _studentHomeworkTeal,
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 34 / 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkSearchField extends StatelessWidget {
  const _HomeworkSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.fromLTRB(19, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/student_homework_search.png',
            width: 19,
            height: 19,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              context.getText(AppKeys.studentHomeworkSearchHint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: const Color(0xFF515F54).withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkFilterTabs extends StatelessWidget {
  const _HomeworkFilterTabs();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _HomeworkFilterChip(
            label: context.getText(AppKeys.studentHomeworkNotSubmitted),
            selected: true,
          ),
          const SizedBox(width: 8),
          _HomeworkFilterChip(
            label: context.getText(AppKeys.studentHomeworkSubmitted),
          ),
          const SizedBox(width: 8),
          _HomeworkFilterChip(
            label: context.getText(AppKeys.studentHomeworkOverdue),
          ),
        ],
      ),
    );
  }
}

class _HomeworkFilterChip extends StatelessWidget {
  const _HomeworkFilterChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? _studentHomeworkActive : const Color(0xFFE5E8EB),
        borderRadius: BorderRadius.circular(9999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        style: GoogleFonts.andika(
          color: selected ? Colors.white : _studentHomeworkMuted,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
        ),
      ),
    );
  }
}

class _HomeworkAssignmentCard extends StatelessWidget {
  const _HomeworkAssignmentCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(context.getText(AppKeys.studentClassComingSoon)),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1400),
              ),
            );
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC4C6D2).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.getText(AppKeys.studentHomeworkAssignedAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: _studentHomeworkMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.getText(AppKeys.studentHomeworkReviewTitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: _studentHomeworkInk,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 28 / 18,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  context.getText(AppKeys.studentHomeworkQuestionCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _studentHomeworkMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 20 / 14,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 17),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFC4C6D2).withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/student_homework_calendar.svg',
                      width: 12,
                      height: 13.33,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.getText(AppKeys.studentHomeworkDueDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _studentHomeworkMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 24 / 16,
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
  }
}
