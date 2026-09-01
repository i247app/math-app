import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/features/quiz/presentation/widgets/grade_selection/grade_option.dart';
import 'package:numi/core/theme/app_colors.dart';

class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final GradeOption option;
  final bool isSelected;
  final VoidCallback onSelected;

  static final Map<String, Future<Uint8List>> _iconBytesCache = {};

  @override
  Widget build(BuildContext context) {
    final iconAsset = option.iconAsset;

    return Semantics(
      key: ValueKey('grade-card-$iconAsset'),
      label: option.label,
      selected: isSelected,
      button: true,
      enabled: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.orange600 : Colors.transparent,
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.orange600.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: isSelected ? 14 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: iconAsset == null
                ? Center(
                    child: Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : Center(
                    child: FutureBuilder<Uint8List>(
                      key: ValueKey('grade-icon-$iconAsset'),
                      future: _iconBytesCache.putIfAbsent(
                        iconAsset,
                        () => _loadEmbeddedPng(iconAsset),
                      ),
                      builder: (context, snapshot) {
                        final bytes = snapshot.data;
                        if (bytes != null) {
                          return Image.memory(
                            bytes,
                            key: ValueKey('grade-icon-image-$iconAsset'),
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            gaplessPlayback: true,
                          );
                        }

                        if (snapshot.hasError) {
                          return _GradeIconFallback(
                            key: ValueKey('grade-icon-fallback-$iconAsset'),
                            label: option.label,
                          );
                        }

                        return SizedBox.square(
                          key: ValueKey('grade-icon-loading-$iconAsset'),
                          dimension: 120,
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  static Future<Uint8List> _loadEmbeddedPng(String assetPath) async {
    final svg = await rootBundle.loadString(assetPath);
    final match = RegExp(r'base64,([^"]+)').firstMatch(svg);
    final encoded = match?.group(1);
    if (encoded == null || encoded.isEmpty) {
      throw FormatException('No embedded image found in $assetPath');
    }

    return base64Decode(encoded);
  }

  Color get _backgroundColor {
    if (option.isKindergarten) {
      return const Color(0xFFFFEAF1);
    }

    return switch (option.number) {
      '1' => const Color(0xFFEEF9DD),
      '2' => const Color(0xFFFFF1D5),
      '3' => const Color(0xFFDDF6F2),
      '4' => const Color(0xFFDDF3F8),
      '5' => const Color(0xFFFBEAF8),
      _ => Colors.white,
    };
  }
}

class _GradeIconFallback extends StatelessWidget {
  const _GradeIconFallback({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
