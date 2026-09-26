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
    } catch (_) {
      // Keep the last rendered state if progress cannot be refreshed.
    } finally {
      if (mounted && requestId == _chartRequestId) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Widget _buildProgressChart(double width) {
    return SizedBox(
      key: const ValueKey('welcome-assessment-intro-chart'),
      width: width,
      child: AssessmentProgressionChart(
        finalGrade: _currentGrade,
        previousGrades: _previousGrades,
        testNumbers: _testNumbers,
        lastSubmittedAt: _lastSubmittedAt,
        chartHeight: 180,
      ),
    );
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

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppBackButton(
            key: const ValueKey('welcome-assessment-back'),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.welcomeTeal,
          ),
          TextButton(
            key: const ValueKey('welcome-assessment-skip'),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onSkip();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.welcomeTeal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: Text(
              context.getText(AppKeys.skipUpper),
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, {required bool isTablet}) {
    final isVietnamese = LingoScope.of(context).language == AppLanguage.vi;
    return Padding(
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
              isVietnamese ? 'ĐÁNH GIÁ NĂNG LỰC' : 'ASESSMENT',
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
    );
  }

  Widget _buildHistoryHeader(double contentWidth) {
    if (_isLoadingHistory) {
      return AppSkeletonLoader(
        builder: (context, color) => AppSkeletonBlock(
          key: const ValueKey('welcome-assessment-intro-history-skeleton'),
          width: contentWidth,
          height: 90,
          radius: 28,
          color: color,
        ),
      );
    }

    // The ribbon PNG has 72 transparent pixels on each side.
    // Expand its width so the visible colors align with the chart.
    final ribbonWidth = contentWidth * 2172 / 2028;
    return SizedBox(
      width: contentWidth,
      height: 90,
      child: OverflowBox(
        alignment: Alignment.center,
        minWidth: ribbonWidth,
        maxWidth: ribbonWidth,
        child: AssessmentGradeRibbon(currentGrade: _currentGrade),
      ),
    );
  }

  Widget _buildHistoryVisual(double contentWidth, double mascotWidth) {
    if (_isLoadingHistory) {
      return AppSkeletonLoader(
        builder: (context, color) => AppSkeletonBlock(
          width: contentWidth,
          height: 240,
          radius: 20,
          color: color,
        ),
      );
    }
    if (_hasExamProgress) return _buildProgressChart(contentWidth);
    return Image.asset(
      WelcomeAssessmentIntroScreen._mascotAsset,
      key: const ValueKey('welcome-assessment-intro-mascot'),
      width: mascotWidth,
      height: mascotWidth,
      fit: BoxFit.contain,
      semanticLabel: 'Numi assessment mascot',
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isTablet,
    required double contentWidth,
    required double mascotWidth,
  }) {
    final content = CustomScrollView(
      key: const ValueKey('welcome-assessment-intro-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: isTablet ? 32 : 24),
              _buildTitle(context, isTablet: isTablet),
              SizedBox(height: isTablet ? 48 : 32),
              _buildHistoryHeader(contentWidth),
              const SizedBox(height: 16),
            ],
          ),
        ),
        SliverLayoutBuilder(
          builder: (context, constraints) => SliverToBoxAdapter(
            // Fill spare space on tall screens, but let the visual keep its
            // natural height and scroll on short screens or with larger text.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0.0, constraints.remainingPaintExtent),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: _buildHistoryVisual(contentWidth, mascotWidth),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    if (_isLoadingHistory) return content;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, opacity, child) => Opacity(
        key: const ValueKey('welcome-assessment-intro-history-content'),
        opacity: opacity,
        child: child,
      ),
      child: content,
    );
  }

  Widget _buildStartButton(double width) {
    return Center(
      child: SizedBox(
        width: math.min(width - 112, 240),
        child: IgnorePointer(
          ignoring: _isStarting,
          child: Stack(
            alignment: Alignment.center,
            children: [
              WelcomeStartButton(
                key: const ValueKey('welcome-assessment-intro-action'),
                onStart: () => _startAssessment(),
                labelText: 'START',
                fontSize: 32,
                cornerRadius: 16,
                verticalPadding: 14,
                fitLabel: true,
              ),
              if (_isStarting)
                const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final isTablet =
                      MediaQuery.sizeOf(context).shortestSide >= 600;
                  final mascotWidth = math.min(
                    width * (isTablet ? 0.58 : 0.7),
                    isTablet ? 390.0 : 310.0,
                  );
                  final contentWidth = math.min(width - 32, 430.0);

                  return Column(
                    children: [
                      _buildToolbar(context),
                      Expanded(
                        child: _buildContent(
                          context,
                          isTablet: isTablet,
                          contentWidth: contentWidth,
                          mascotWidth: mascotWidth,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStartButton(width),
                      SizedBox(height: constraints.maxHeight < 700 ? 32 : 96),
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
