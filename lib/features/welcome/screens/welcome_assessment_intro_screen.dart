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
import 'package:numi/features/exam/models/assessment_progress_chart_data.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/welcome/widgets/welcome_primary_button.dart';
import 'package:numi/features/welcome/widgets/welcome_intro_loading.dart';
import 'package:numi/features/welcome/widgets/welcome_assessment_background.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

/// The guest assessment entry shown after the Welcome details carousel.
class WelcomeAssessmentIntroScreen extends StatefulWidget {
  const WelcomeAssessmentIntroScreen({
    super.key,
    required this.onAssessment,
    this.profileId,
  });

  static const _mascotAsset =
      'assets/images/assessment_intro/assessment-graduate-mascot.png';
  static const _backgroundSize = WelcomeAssessmentBackground.canvasSize;
  static const _planetSurfaceY = WelcomeAssessmentBackground.planetSurfaceY;
  // The mascot PNG includes transparent padding below its feet.
  static const _mascotFeetFraction = 1200 / 1254;

  final Future<void> Function(BuildContext context) onAssessment;
  final int? profileId;

  @override
  State<WelcomeAssessmentIntroScreen> createState() =>
      _WelcomeAssessmentIntroScreenState();
}

class _WelcomeAssessmentIntroScreenState
    extends State<WelcomeAssessmentIntroScreen> {
  bool _isStarting = false;
  bool _isLoadingHistory = true;
  AssessmentProgressChartData _chart = AssessmentProgressChartData.empty;
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
    // Load the artwork alongside history so the whole scene can fade in.
    final artworkReady = Future.wait<void>([
      for (final asset in WelcomeAssessmentBackground.decorationAssets)
        precacheImage(AssetImage(asset), context),
      precacheImage(
        const AssetImage(WelcomeAssessmentIntroScreen._mascotAsset),
        context,
      ),
      precacheImage(
        const AssetImage('assets/images/grade-ribbon-numbers.png'),
        context,
      ),
    ]);
    try {
      var profileId = widget.profileId;
      if (profileId == null) {
        final guestAccounts = context.read<GuestAccountService>();
        final guest =
            guestAccounts.current ?? await guestAccounts.ensureGuest();
        if (!mounted || requestId != _chartRequestId) return;
        profileId = guest.profileId;
      }
      if (profileId == null) return;

      final examService = context.read<ExamService>();
      final toDt = DateTime.now();
      final progress = await examService.getExamProgress(
        profileId: profileId,
        fromDt: toDt.subtract(const Duration(days: 7)),
        toDt: toDt,
      );
      if (!mounted || requestId != _chartRequestId) return;
      setState(() {
        _chart = AssessmentProgressChartData.fromProgress(progress);
      });
    } catch (_) {
      // Keep the last rendered state if progress cannot be refreshed.
    } finally {
      await artworkReady;
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
        finalGrade: _chart.finalGrade,
        previousGrades: _chart.previousGrades,
        testNumbers: _chart.testNumbers,
        lastSubmittedAt: _chart.lastSubmittedAt,
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
      child: Align(
        alignment: Alignment.centerLeft,
        heightFactor: 1,
        child: AppBackButton(
          key: const ValueKey('welcome-assessment-back'),
          onPressed: () => Navigator.of(context).pop(),
          color: Theme.of(context).brightness == Brightness.dark
              ? context.themeColors.brandStrong
              : AppColors.welcomeTeal,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, {required bool isTablet}) {
    final isVietnamese = LingoScope.of(context).language == AppLanguage.vi;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.themeColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isVietnamese ? 'TOÁN AI' : 'AI MATH',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              color: isDark ? colors.brandStrong : AppColors.brandTeal,
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
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900,
                color: isDark ? colors.accent : AppColors.brandOrange,
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
        child: AssessmentGradeRibbon(currentGrade: _chart.finalGrade),
      ),
    );
  }

  Widget _buildHistoryVisual(double contentWidth, double mascotWidth) {
    if (_chart.hasProgress) return _buildProgressChart(contentWidth);
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
    required double viewportWidth,
    required double planetSurfaceY,
  }) {
    return CustomScrollView(
      key: const ValueKey('welcome-assessment-intro-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildToolbar(context),
              SizedBox(height: isTablet ? 32 : 24),
              _buildTitle(context, isTablet: isTablet),
              SizedBox(height: isTablet ? 48 : 32),
              _buildHistoryHeader(contentWidth),
              const SizedBox(height: 16),
            ],
          ),
        ),
        SliverLayoutBuilder(
          builder: (context, constraints) {
            // Set the feet slightly inside the curved planet surface.
            final mascotTopPadding = math.max(
              0.0,
              planetSurfaceY +
                  12 -
                  constraints.precedingScrollExtent -
                  mascotWidth *
                      WelcomeAssessmentIntroScreen._mascotFeetFraction,
            );
            // Both visuals share the mascot's space and button baseline.
            return SliverToBoxAdapter(
              child: SizedBox(
                // Leave enough room for the chart on compact screens too.
                height: math.max(320.0, mascotTopPadding + mascotWidth),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: _chart.hasProgress ? 0 : mascotTopPadding,
                    ),
                    child: _buildHistoryVisual(contentWidth, mascotWidth),
                  ),
                ),
              ),
            );
          },
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildStartButton(viewportWidth),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
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
              WelcomePrimaryButton(
                key: const ValueKey('welcome-assessment-intro-action'),
                onPressed: () => _startAssessment(),
                labelText: 'START',
                fontSize: 32,
                cornerRadius: 20,
                verticalPadding: 14,
                fitLabel: true,
              ),
              if (_isStarting)
                CircularProgressIndicator(color: context.themeColors.onAccent),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final screenSize = MediaQuery.sizeOf(context);
    final safeArea = MediaQuery.paddingOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        body: _isLoadingHistory
            ? SafeArea(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Center(
                      child: WelcomeIntroLoading(
                        key: ValueKey('welcome-assessment-intro-loading'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: _buildToolbar(context),
                    ),
                  ],
                ),
              )
            : TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, opacity, child) => Opacity(
                  key: const ValueKey(
                    'welcome-assessment-intro-history-content',
                  ),
                  opacity: opacity,
                  child: child,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const WelcomeAssessmentBackground(
                      key: ValueKey('welcome-assessment-intro-background'),
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
                          final backgroundSize =
                              WelcomeAssessmentIntroScreen._backgroundSize;
                          final backgroundScale = math.max(
                            screenSize.width / backgroundSize.width,
                            screenSize.height / backgroundSize.height,
                          );
                          // Match the centered BoxFit.cover background, then express
                          // the planet surface relative to the SafeArea scroll view.
                          final planetSurfaceY =
                              (screenSize.height -
                                      backgroundSize.height * backgroundScale) /
                                  2 +
                              WelcomeAssessmentIntroScreen._planetSurfaceY *
                                  backgroundScale -
                              safeArea.top;

                          return _buildContent(
                            context,
                            isTablet: isTablet,
                            contentWidth: contentWidth,
                            mascotWidth: mascotWidth,
                            viewportWidth: width,
                            planetSurfaceY: planetSurfaceY,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
