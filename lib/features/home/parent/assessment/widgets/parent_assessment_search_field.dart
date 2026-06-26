part of '../../../home_screen.dart';

class _ParentAssessmentSearchField extends StatelessWidget {
  const _ParentAssessmentSearchField({
    required this.controller,
    required this.scale,
  });

  final TextEditingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFE4DDDF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: const Color(0xFF17252B),
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: context.getText(AppKeys.searchHint),
          hintStyle: TextStyle(
            color: const Color(0xFFD8C5CC),
            fontSize: FontSize.normal * scale,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF063A7B),
            size: 23 * scale,
          ),
          suffixIcon: IconButton(
            onPressed: HapticFeedback.selectionClick,
            icon: Icon(
              Icons.tune_rounded,
              color: const Color(0xFF063A7B),
              size: 21 * scale,
            ),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 11 * scale),
        ),
      ),
    );
  }
}
