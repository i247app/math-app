import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/guest_account_service.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_grade_ribbon.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/welcome/widgets/welcome_start_button.dart';
import 'package:numi/shared/widgets/app_back_button.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

/// The guest assessment entry shown after the Welcome details carousel.
class WelcomeAssessmentIntroScreen extends StatefulWidget {
  const WelcomeAssessmentIntroScreen({
    super.key,
    required this.onAssessment,
    required this.onSkip,
  });

  static const _backgroundAsset =
      'assets/images/assessment_intro/assessment-intro-background.png';
  static const _mascotAsset =
      'assets/images/assessment_intro/assessment-graduate-mascot.png';

  final Future<void> Function(BuildContext context) onAssessment;
  final VoidCallback onSkip;

  @override
  State<WelcomeAssessmentIntroScreen> createState() =>
      _WelcomeAssessmentIntroScreenState();
}

class _WelcomeAssessmentIntroScreenState
    extends State<WelcomeAssessmentIntroScreen> {
  bool _isStarting = false;
  bool _isLoadingHistory = true;
  bool _hasExamProgress = false;
  int _currentGrade = 0;
  List<int> _previousGrades = const <int>[];
  List<int> _testNumbers = const <int>[1];
  DateTime? _lastSubmittedAt;
  int _chartRequestId = 0;
  final ScrollController _chartScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadChart();
    });
  }

  Future<void> _loadChart() async {
    final requestId = ++_chartRequestId;
    if (!_isLoadingHistory) setState(() => _isLoadingHistory = true);
    try {
      final guestAccounts = context.read<GuestAccountService>();
      final guest = guestAccounts.current ?? await guestAccounts.ensureGuest();
      if (!mounted || requestId != _chartRequestId) return;
      final profileId = guest.profileId;
      if (profileId == null) return;

      final examService = context.read<ExamService>();
      final toDt = DateTime.now();
      final progress = await examService.getExamProgress(
        profileId: profileId,
        fromDt: toDt.subtract(const Duration(days: 7)),
        toDt: toDt,
      );
      if (!mounted || requestId != _chartRequestId) return;
      final points = progress.series.where((point) {
        final status = point.status?.trim().toUpperCase();
        return point.grade != null &&
            (status == null || status == 'COMPLETE' || status == 'SUBMITTED');
      }).toList()..sort((a, b) => a.sequence.compareTo(b.sequence));
      setState(() {
        _hasExamProgress = points.isNotEmpty;
        _currentGrade = points.isEmpty ? 0 : points.last.grade!.clamp(0, 5);
        _previousGrades = points
            .take(points.length - 1)
            .map((point) => point.grade!.clamp(0, 5))
            .toList(growable: false);
        _testNumbers = points.isEmpty
            ? const <int>[1]
            : points.map((point) => point.sequence).toList(growable: false);
        _lastSubmittedAt = points.isEmpty ? null : points.last.completedDt;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            requestId == _chartRequestId &&
            _chartScrollController.hasClients) {
          _chartScrollController.jumpTo(
            _chartScrollController.position.maxScrollExtent,
          );
        }
      });
    } catch (_) {
      // Keep the last rendered state if progress cannot be refreshed.
    } finally {
      if (mounted && requestId == _chartRequestId) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Widget _buildProgressChart(double width, double availableHeight) {
    return SizedBox(
      key: const ValueKey('welcome-assessment-intro-chart'),
      width: width,
      child: SingleChildScrollView(
        controller: _chartScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(width, 210.0 + (_testNumbers.length - 1) * 64.0),
          child: AssessmentProgressionChart(
            finalGrade: _currentGrade,
            previousGrades: _previousGrades,
            testNumbers: _testNumbers,
            lastSubmittedAt: _lastSubmittedAt,
            maxVisiblePoints: null,
            chartHeight: math.max(
              100.0,
              math.min(180.0, availableHeight - 140.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  Future<void> _startAssessment() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);
    try {
      await widget.onAssessment(context);
    } on NetworkException catch (error) {
      if (mounted) await context.showErrorDialog(error.message);
    } on FormatException {
      if (mounted) {
        await context.showErrorDialog(
          context.getText(AppKeys.invalidServerResponse),
        );
      }
    } catch (_) {
      if (mounted) {
        await context.showErrorDialog(
          context.getText(AppKeys.apiConnectionFailed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
        _loadChart();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isVietnamese = LingoScope.of(context).language == AppLanguage.vi;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              WelcomeAssessmentIntroScreen._backgroundAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final isTablet =
                      MediaQuery.sizeOf(context).shortestSide >= 600;
                  final mascotWidth = math.min(
                    width * (isTablet ? 0.58 : 0.7),
                    isTablet ? 390.0 : 310.0,
                  );
                  final contentWidth = math.min(width - 32, 430.0);
                  const contentLift = 25.0;
                  final contentTop =
                      math.max(
                        height * (height < 700 ? 0.34 : 0.36),
                        isTablet ? 250.0 : 190.0,
                      ) -
                      contentLift;
                  final contentBottom =
                      MediaQuery.viewPaddingOf(context).bottom +
                      182 +
                      contentLift;
                  final contentHeight = math.max(
                    0.0,
                    height - contentTop - contentBottom,
                  );

                  return Stack(
                    children: [
                      Positioned(
                        top: 2,
                        left: 12,
                        child: AppBackButton(
                          key: const ValueKey('welcome-assessment-back'),
                          onPressed: () => Navigator.of(context).pop(),
                          color: AppColors.welcomeTeal,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 12,
                        child: TextButton(
                          key: const ValueKey('welcome-assessment-skip'),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onSkip();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.welcomeTeal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            context.getText(AppKeys.skipUpper),
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: isTablet ? 80 : 72,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isVietnamese ? 'TOÁN AI' : 'AI MATH',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'NunitoVariable',
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandTeal,
                                  fontSize: isTablet ? 52 : 42,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  isVietnamese
                                      ? 'Kiểm Tra Năng Lực'
                                      : 'ASESSMENT TEST',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'NunitoVariable',
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.brandOrange,
                                    fontSize: isTablet ? 38 : 32,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: contentTop,
                        bottom: contentBottom,
                        left: (width - contentWidth) / 2,
                        right: (width - contentWidth) / 2,
                        child: _isLoadingHistory
                            ? Column(
                                children: [
                                  Expanded(
                                    child: AppSkeletonLoader(
                                      builder: (context, color) => Column(
                                        children: [
                                          AppSkeletonBlock(
                                            key: const ValueKey(
                                              'welcome-assessment-intro-history-skeleton',
                                            ),
                                            width: contentWidth,
                                            height: 56,
                                            radius: 28,
                                            color: color,
                                          ),
                                          const SizedBox(height: 24),
                                          Expanded(
                                            child: Center(
                                              child: AppSkeletonBlock(
                                                width: contentWidth,
                                                height: math.max(
                                                  100.0,
                                                  math.min(
                                                    180.0,
                                                    contentHeight - 140,
                                                  ),
                                                ),
                                                radius: 20,
                                                color: color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                builder: (context, opacity, child) => Opacity(
                                  key: const ValueKey(
                                    'welcome-assessment-intro-history-content',
                                  ),
                                  opacity: opacity,
                                  child: child,
                                ),
                                child: Column(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0, -24),
                                      child: AssessmentGradeRibbon(
                                        currentGrade: _currentGrade,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Center(
                                        child: _hasExamProgress
                                            ? height < 700
                                                  ? FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child:
                                                          _buildProgressChart(
                                                            contentWidth,
                                                            contentHeight,
                                                          ),
                                                    )
                                                  : _buildProgressChart(
                                                      contentWidth,
                                                      contentHeight,
                                                    )
                                            : Image.asset(
                                                WelcomeAssessmentIntroScreen
                                                    ._mascotAsset,
                                                key: const ValueKey(
                                                  'welcome-assessment-intro-mascot',
                                                ),
                                                width: mascotWidth,
                                                fit: BoxFit.contain,
                                                semanticLabel:
                                                    'Numi assessment mascot',
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.viewPaddingOf(context).bottom + 96,
                        child: Center(
                          child: SizedBox(
                            width: math.min(width - 112, 240),
                            child: IgnorePointer(
                              ignoring: _isStarting,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  WelcomeStartButton(
                                    key: const ValueKey(
                                      'welcome-assessment-intro-action',
                                    ),
                                    onStart: () => _startAssessment(),
                                    labelText: 'START',
                                    fontSize: 32,
                                    cornerRadius: 16,
                                    verticalPadding: 14,
                                  ),
                                  if (_isStarting)
                                    const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
