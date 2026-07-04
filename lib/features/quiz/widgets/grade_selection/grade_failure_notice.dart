import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_selection_style.dart';

class GradeFailureNotice extends StatelessWidget {
  const GradeFailureNotice({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: GradeSelectionStyle.peach.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: GradeSelectionStyle.rust.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: GradeSelectionStyle.rust,
            size: 20 * scale,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              context.getText(AppKeys.generateTestFailed),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: GradeSelectionStyle.rust,
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
