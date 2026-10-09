import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class PlacementWeakTopicsDropdown extends StatefulWidget {
  const PlacementWeakTopicsDropdown({
    super.key,
    required this.topics,
    required this.maxExpandedHeight,
  });

  final List<String> topics;
  final double maxExpandedHeight;

  @override
  State<PlacementWeakTopicsDropdown> createState() =>
      _PlacementWeakTopicsDropdownState();
}

class _PlacementWeakTopicsDropdownState
    extends State<PlacementWeakTopicsDropdown> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.andika(
      color: AppColors.coral600,
      fontSize: FontSize.small,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    return Container(
      key: const ValueKey('placement-weak-topics'),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE2D6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              key: const ValueKey('placement-weak-topics-toggle'),
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.getText(
                            AppKeys.placementResultWeaknessesTitle,
                          ),
                          style: textStyle,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.coral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _expanded
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.maxExpandedHeight,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final topic in widget.topics)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('•', style: textStyle),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(topic, style: textStyle),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
