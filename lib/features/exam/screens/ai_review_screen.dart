import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_header.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_state_panel.dart';

class AiReviewScreen extends StatefulWidget {
  const AiReviewScreen({
    super.key,
    required this.reviewText,
    this.aiReviewLoader,
  });

  final String reviewText;
  final Future<String> Function()? aiReviewLoader;

  @override
  State<AiReviewScreen> createState() => _AiReviewScreenState();
}

class _AiReviewScreenState extends State<AiReviewScreen> {
  late String _reviewText;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _reviewText = widget.reviewText;
    if (widget.aiReviewLoader != null) unawaited(_loadAiReview());
  }

  Future<void> _loadAiReview() async {
    final loader = widget.aiReviewLoader;
    if (loader == null || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final text = await loader();
      if (!mounted) return;
      setState(() => _reviewText = text);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is ExamException
            ? error.message
            : context.getText(AppKeys.examReviewLoadFailed);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExamReviewHeader(
              title: context.getText(AppKeys.examReviewWeakTopicsTitle),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? ExamReviewStatePanel(
                      isLoading: false,
                      message: _errorMessage,
                      onRetry: _loadAiReview,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: SizedBox(
                        width: double.infinity,
                        child: SelectableText(
                          _reviewText,
                          style: GoogleFonts.andika(
                            fontSize: 16,
                            height: 1.6,
                            color: colors.textPrimary,
                          ),
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
