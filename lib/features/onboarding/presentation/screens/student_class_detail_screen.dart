import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/network/classroom_models.dart';
import '../../data/classroom_api.dart';
import 'student_homework_screen.dart';

const _studentClassBg = Color(0xFFF6FFFF);
const _studentClassTeal = Color(0xFF38898C);
const _studentClassInk = Color(0xFF001741);
const _studentClassMuted = Color(0xFF444650);
const _studentClassPink = Color(0xFFAA2A6C);

class StudentClassDetailScreen extends StatefulWidget {
  const StudentClassDetailScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.initialClassroom,
    ClassroomService? classroomService,
  }) : _classroomService = classroomService;

  final int classroomId;
  final int profileId;
  final ClassroomModel? initialClassroom;
  final ClassroomService? _classroomService;

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();

  ClassroomModel? _classroom;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _classroom = widget.initialClassroom;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final classroom = await _classroomService.getClassroomDetail(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
      );
      if (!mounted) {
        return;
      }
      setState(() => _classroom = classroom ?? _classroom);
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classroom = _classroom;
    final title = _nonEmpty(classroom?.name) ??
        context.getText(AppKeys.studentClassDetailTitle);

    return Scaffold(
      backgroundColor: _studentClassBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _StudentClassTopBar(
              title: title,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _studentClassTeal,
                onRefresh: _loadDetail,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    17,
                    16,
                    MediaQuery.paddingOf(context).bottom + 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null && classroom == null)
                        _StudentClassErrorCard(
                          message: _error!,
                          onRetry: _loadDetail,
                        )
                      else ...[
                        _TeacherProfileCard(
                          classroom: classroom,
                          isLoading: _isLoading && classroom == null,
                        ),
                        const SizedBox(height: 26),
                        const _LearningCategorySection(),
                        const SizedBox(height: 23),
                        const _UpcomingDeadlineSection(),
                      ],
                    ],
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

class _StudentClassTopBar extends StatelessWidget {
  const _StudentClassTopBar({
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
          const SizedBox(width: 52),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: _studentClassTeal,
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

class _TeacherProfileCard extends StatelessWidget {
  const _TeacherProfileCard({
    required this.classroom,
    required this.isLoading,
  });

  final ClassroomModel? classroom;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final teacherName = _nonEmpty(classroom?.teacherName) ??
        _nonEmpty(classroom?.owner?.name) ??
        context.getText(AppKeys.teacherFallback);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001741).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? const SizedBox(
              height: 56,
              child: Center(
                child: CircularProgressIndicator(color: _studentClassTeal),
              ),
            )
          : Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFAA2A6C).withValues(alpha: 0.1),
                          width: 2,
                        ),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/student_class_teacher.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.getText(AppKeys.studentClassTeacherRole),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _studentClassMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _studentClassInk,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _MessageButton(
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD9E2FF).withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/student_class_message.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningCategorySection extends StatelessWidget {
  const _LearningCategorySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(context.getText(AppKeys.studentClassLearningCategories)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _CategoryTile(
              backgroundColor: const Color(0xFFFDF0F5),
              iconAsset: 'assets/images/student_class_assignment.svg',
              title: context.getText(AppKeys.studentClassAssignments),
              subtitle:
                  context.getText(AppKeys.studentClassAssignmentsSubtitle),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const StudentHomeworkScreen(),
                ),
              ),
            ),
            _CategoryTile(
              backgroundColor: const Color(0xFFFDF4EE),
              iconAsset: 'assets/images/student_class_quiz.svg',
              title: context.getText(AppKeys.studentClassQuizzes),
              subtitle: context.getText(AppKeys.studentClassQuizzesSubtitle),
            ),
            _CategoryTile(
              backgroundColor: const Color(0xFFF0F4FF),
              iconAsset: 'assets/images/student_class_resources.svg',
              title: context.getText(AppKeys.studentClassMaterials),
              subtitle: context.getText(AppKeys.studentClassMaterialsSubtitle),
            ),
            _CategoryTile(
              backgroundColor: const Color(0xFFEDFBF3),
              iconAsset: 'assets/images/student_class_grades.svg',
              title: context.getText(AppKeys.studentClassGrades),
              subtitle: context.getText(AppKeys.studentClassGradesSubtitle),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.andika(
        color: _studentClassInk,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.5,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.backgroundColor,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Color backgroundColor;
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap ?? () => _showComingSoon(context),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC4C6D2).withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF001741).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: _studentClassInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 20 / 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: _studentClassMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingDeadlineSection extends StatelessWidget {
  const _UpcomingDeadlineSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionTitle(
                context.getText(AppKeys.studentClassUpcomingDeadlines),
              ),
            ),
            Text(
              context.getText(AppKeys.studentClassAll),
              style: GoogleFonts.andika(
                color: _studentClassPink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _showComingSoon(context),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFC4C6D2).withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: _studentClassPink,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.getText(AppKeys.studentClassReview15Minutes),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: _studentClassInk,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          context.getText(AppKeys.studentClassDeadlineSample),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: _studentClassMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/images/student_class_chevron.svg',
                    width: 7,
                    height: 10,
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentClassErrorCard extends StatelessWidget {
  const _StudentClassErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: _studentClassInk,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: _studentClassTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

void _showComingSoon(BuildContext context) {
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
}
