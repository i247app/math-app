part of '../teacher_study_tab.dart';

class _TeacherStudySearchField extends StatelessWidget {
  const _TeacherStudySearchField({
    required this.controller,
    required this.scale,
    required this.onChanged,
  });

  final TextEditingController controller;
  final double scale;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49 * scale,
      padding: EdgeInsets.fromLTRB(22 * scale, 0, 16 * scale, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/teacher_homework_search.svg',
            width: 18 * scale,
            height: 18 * scale,
          ),
          SizedBox(width: 18 * scale),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              textInputAction: TextInputAction.search,
              style: GoogleFonts.andika(
                color: AppColors.textInkDark,
                fontSize: FontSize.normal * scale,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: context.getText(AppKeys.teacherAssignmentSearchHint),
                hintStyle: GoogleFonts.andika(
                  color: const Color(0xFFDCBFC8),
                  fontSize: FontSize.normal * scale,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          SvgPicture.asset(
            'assets/images/teacher_homework_filter.svg',
            width: 18 * scale,
            height: 18 * scale,
          ),
        ],
      ),
    );
  }
}
