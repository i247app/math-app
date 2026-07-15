import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/widgets/home_game_preview_row.dart';

class StudentGameSuggestionsSection extends StatelessWidget {
  const StudentGameSuggestionsSection({super.key, required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6FF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.widgets_rounded,
                color: Color(0xFF2D7BEA),
                size: 18,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                context.getText(AppKeys.navGames),
                style: const TextStyle(
                  color: Color(0xFF202328),
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.getText(AppKeys.viewAll)),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const HomeGamePreviewRow(),
      ],
    );
  }
}
