import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/widgets/student_search/student_class_search_assets.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentJoinSchoolFilterField extends StatelessWidget {
  const StudentJoinSchoolFilterField({
    super.key,
    required this.valueText,
    required this.selected,
    required this.isLoading,
    required this.onTap,
  });

  final String valueText;
  final bool selected;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFC4C6D2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  valueText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? AppColors.textInkDark
                        : AppColors.textMuted,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                SvgPicture.asset(studentJoinDropdownIcon, width: 10, height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
