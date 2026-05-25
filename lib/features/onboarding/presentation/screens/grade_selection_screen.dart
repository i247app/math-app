import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/grade_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/otp_auth_api.dart';
import '../../data/grade_api.dart';
import 'assessment_screen.dart';

const _gradeMint = Color(0xFFEBFAEC);
const _gradeTeal = Color(0xFF006762);
const _gradeInk = Color(0xFF253228);
const _gradePeach = Color(0xFFFFDCCA);
const _gradeRust = Color(0xFFA03A0F);

class GradeSelectionScreen extends StatefulWidget {
  const GradeSelectionScreen({
    super.key,
    this.user,
    this.initialGrades = const <GradeModel>[],
    this.gradeService,
  });

  final LoginUser? user;
  final List<GradeModel> initialGrades;
  final GradeService? gradeService;

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  State<GradeSelectionScreen> createState() => _GradeSelectionScreenState();
}

class _GradeSelectionScreenState extends State<GradeSelectionScreen> {
  late final GradeService _gradeService;
  bool showGenerationFailed = false;
  bool isLoadingGrades = false;
  String? gradeLoadError;
  List<GradeModel> grades = const <GradeModel>[];
  String? selectedGradeLabel;

  @override
  void initState() {
    super.initState();
    _gradeService = widget.gradeService ?? GradeApi();
    grades = widget.initialGrades;
    selectedGradeLabel = _defaultGradeLabel(grades);
    if (grades.isEmpty) {
      loadGrades();
    }
  }

  Future<void> loadGrades() async {
    final userId = widget.user?.id.trim();
    if (userId == null || userId.isEmpty) {
      setState(() {
        isLoadingGrades = false;
        gradeLoadError = 'Chưa có thông tin tài khoản để tải danh sách lớp.';
        grades = const <GradeModel>[];
      });
      return;
    }

    setState(() {
      isLoadingGrades = true;
      gradeLoadError = null;
    });

    try {
      final loadedGrades = await _gradeService.listGrades(userId: userId);
      if (!mounted) {
        return;
      }

      setState(() {
        grades = loadedGrades;
        isLoadingGrades = false;
        if (!loadedGrades.any(
          (grade) => grade.label?.trim() == selectedGradeLabel,
        )) {
          selectedGradeLabel = _defaultGradeLabel(loadedGrades);
        }
      });
    } on GradeException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        gradeLoadError = error.message;
        isLoadingGrades = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        gradeLoadError = 'Tải danh sách lớp thất bại.';
        isLoadingGrades = false;
      });
    }
  }

  Future<void> openAssessment({String? gradeLabel}) async {
    HapticFeedback.mediumImpact();
    if (showGenerationFailed) {
      setState(() => showGenerationFailed = false);
    }

    final result = await Navigator.of(context).push<AiAssessmentResult>(
      MaterialPageRoute<AiAssessmentResult>(
        builder: (_) => AiAssessmentScreen(gradeLabel: gradeLabel),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == AiAssessmentResult.generationFailed) {
      setState(() => showGenerationFailed = true);
      return;
    }

    setState(() {
      showGenerationFailed = false;
      selectedGradeLabel = _defaultGradeLabel(grades);
    });
  }

  void selectGrade(_GradeOption option) {
    HapticFeedback.selectionClick();
    setState(() => selectedGradeLabel = option.label);
  }

  void continueWithSelectedGrade() {
    final gradeLabel = selectedGradeLabel;
    if (gradeLabel == null || gradeLabel.isEmpty) {
      HapticFeedback.selectionClick();
      return;
    }

    openAssessment(gradeLabel: gradeLabel);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _gradeMint,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 430.0);
              final height = constraints.maxHeight;
              final scale = math.min(
                width / GradeSelectionScreen._designWidth,
                height / GradeSelectionScreen._designHeight,
              );

              double s(double value) => value * scale;

              return Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      const Positioned.fill(child: _GradeBackground()),
                      Positioned.fill(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            s(38),
                            s(132),
                            s(38),
                            s(128),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Bé đang học lớp mấy\nnhỉ?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _gradeInk,
                                  fontFamily: 'Nunito',
                                  fontSize: s(31),
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                  letterSpacing: 0,
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: showGenerationFailed
                                    ? Padding(
                                        key: const ValueKey(
                                          'generate-failed-notice',
                                        ),
                                        padding: EdgeInsets.only(top: s(18)),
                                        child: _GradeFailureNotice(
                                          scale: scale,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              SizedBox(height: s(26)),
                              _GradeGrid(
                                scale: scale,
                                grades: grades,
                                selectedGradeLabel: selectedGradeLabel,
                                isLoading: isLoadingGrades,
                                errorMessage: gradeLoadError,
                                onSelected: selectGrade,
                                onRetry: loadGrades,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: _GradeHeader(scale: scale),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _GradeBottomBar(
                          scale: scale,
                          onSkip: openAssessment,
                          onContinue: continueWithSelectedGrade,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GradeFailureNotice extends StatelessWidget {
  const _GradeFailureNotice({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: _gradePeach.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: _gradeRust.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _gradeRust,
            size: 20 * scale,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              'Tạo test thất bại. Vui lòng thử lại sau.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _gradeRust,
                fontFamily: 'Nunito',
                fontSize: 13 * scale,
                fontWeight: FontWeight.w900,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeBackground extends StatelessWidget {
  const _GradeBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradeMint, Color(0xFFD8EBD8), _gradeMint],
          stops: [0, 0.80, 1],
        ),
      ),
    );
  }
}

class _GradeHeader extends StatelessWidget {
  const _GradeHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 70 * scale,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          color: _gradeMint.withValues(alpha: 0.78),
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).maybePop();
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: _gradeTeal,
              size: 28 * scale,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: 42 * scale,
              height: 42 * scale,
            ),
            tooltip: 'Quay lại',
          ),
        ),
      ),
    );
  }
}

class _GradeGrid extends StatelessWidget {
  const _GradeGrid({
    required this.scale,
    required this.grades,
    required this.selectedGradeLabel,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelected,
    required this.onRetry,
  });

  final double scale;
  final List<GradeModel> grades;
  final String? selectedGradeLabel;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<_GradeOption> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _GradeLoadState(scale: scale);
    }

    if (errorMessage != null) {
      return _GradeLoadError(
        scale: scale,
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    final items = grades
        .where((grade) {
          final label = grade.label?.trim();
          return label != null && label.isNotEmpty;
        })
        .map(_GradeOption.fromGradeModel)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (items.isEmpty) {
      return _GradeLoadError(
        scale: scale,
        message: 'Chưa có lớp học nào để hiển thị.',
        onRetry: onRetry,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12 * scale,
        crossAxisSpacing: 12 * scale,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final option = items[index];
        return _GradeCard(
          option: option,
          scale: scale,
          isSelected: option.label == selectedGradeLabel,
          onSelected: () => onSelected(option),
        );
      },
    );
  }
}

class _GradeLoadState extends StatelessWidget {
  const _GradeLoadState({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12 * scale,
        crossAxisSpacing: 12 * scale,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        return _GradeSkeletonCard(scale: scale);
      },
    );
  }
}

class _GradeSkeletonCard extends StatelessWidget {
  const _GradeSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        17 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35 * scale,
            height: 35 * scale,
            decoration: BoxDecoration(
              color: _gradeTeal.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          Container(
            width: 72 * scale,
            height: 15 * scale,
            decoration: BoxDecoration(
              color: _gradeInk.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeLoadError extends StatelessWidget {
  const _GradeLoadError({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            color: _gradeTeal,
            size: 34 * scale,
          ),
          SizedBox(height: 12 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _gradeInk,
              fontFamily: 'Nunito',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 14 * scale),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'THỬ LẠI',
              style: TextStyle(
                color: _gradeTeal,
                fontFamily: 'Nunito',
                fontSize: 13 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.option,
    required this.scale,
    required this.isSelected,
    required this.onSelected,
  });

  final _GradeOption option;
  final double scale;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: option.label,
      selected: isSelected,
      button: true,
      enabled: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28 * scale),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(28 * scale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              20 * scale,
              20 * scale,
              17 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28 * scale),
              border: Border.all(
                color: isSelected ? _gradeTeal : Colors.transparent,
                width: 2 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _gradeTeal.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 16 * scale : 10 * scale,
                  offset: Offset(0, isSelected ? 7 * scale : 4 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GradeBadge(
                  option: option,
                  scale: scale,
                  isSelected: isSelected,
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: _gradeInk,
                      fontFamily: 'Nunito',
                      fontSize: 17 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({
    required this.option,
    required this.scale,
    required this.isSelected,
  });

  final _GradeOption option;
  final double scale;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = 35 * scale;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? _gradeTeal : AppColors.aquaMist,
        shape: BoxShape.circle,
      ),
      child: option.number == null
          ? Icon(
              Icons.school_rounded,
              color: isSelected ? Colors.white : _gradeTeal,
              size: 19 * scale,
            )
          : Text(
              option.number!,
              style: TextStyle(
                color: isSelected ? Colors.white : _gradeTeal,
                fontFamily: 'Nunito',
                fontSize: 17 * scale,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
    );
  }
}

class _GradeBottomBar extends StatelessWidget {
  const _GradeBottomBar({
    required this.scale,
    required this.onSkip,
    required this.onContinue,
  });

  final double scale;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 72 * scale,
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            10 * scale,
            24 * scale,
            10 * scale,
          ),
          decoration: BoxDecoration(
            color: _gradeMint.withValues(alpha: 0.90),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 22 * scale,
                offset: Offset(0, -8 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: _PillActionButton(
                  label: 'BỎ QUA',
                  background: _gradePeach,
                  foreground: _gradeRust,
                  scale: scale,
                  onPressed: onSkip,
                ),
              ),
              SizedBox(width: 20 * scale),
              Expanded(
                flex: 10,
                child: _PillActionButton(
                  label: 'TIẾP TỤC',
                  icon: Icons.arrow_forward_rounded,
                  background: _gradeTeal,
                  foreground: Colors.white,
                  gradient: const LinearGradient(
                    colors: [_gradeTeal, Color(0xFF55E0D6)],
                  ),
                  scale: scale,
                  onPressed: onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillActionButton extends StatelessWidget {
  const _PillActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.scale,
    required this.onPressed,
    this.icon,
    this.gradient,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double scale;
  final VoidCallback onPressed;
  final IconData? icon;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? background : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: gradient == null
              ? null
              : [
                  BoxShadow(
                    color: _gradeTeal.withValues(alpha: 0.24),
                    blurRadius: 12 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0.8,
                  ),
                ),
                if (icon != null) ...[
                  SizedBox(width: 8 * scale),
                  Icon(icon, size: 18 * scale),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradeOption {
  const _GradeOption(
    this.number,
    this.label, {
    this.displayOrder = 0,
  });

  factory _GradeOption.fromGradeModel(GradeModel grade) {
    final label = grade.label?.trim() ?? '';
    return _GradeOption(
      _gradeNumberFromLabel(label),
      label,
      displayOrder: grade.displayOrder ?? 0,
    );
  }

  final String? number;
  final String label;
  final int displayOrder;
}

String? _gradeNumberFromLabel(String label) {
  final match = RegExp(r'\d+').firstMatch(label);
  return match?.group(0);
}

String? _defaultGradeLabel(List<GradeModel> grades) {
  final sortedGrades = grades
      .where((grade) => grade.label?.trim().isNotEmpty == true)
      .toList()
    ..sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
  if (sortedGrades.isEmpty) {
    return null;
  }
  return sortedGrades.first.label?.trim();
}
