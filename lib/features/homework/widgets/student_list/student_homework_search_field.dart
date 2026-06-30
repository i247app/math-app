part of '../../presentation/student_homework_screen.dart';

class _StudentHomeworkSearchField extends StatelessWidget {
  const _StudentHomeworkSearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: GoogleFonts.andika(
        color: _studentHomeworkInk,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
      decoration: InputDecoration(
        hintText: context.getText(AppKeys.studentHomeworkSearchHint),
        hintStyle: GoogleFonts.andika(
          color: const Color(0xFF515F54).withValues(alpha: 0.7),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
        ),
        filled: true,
        fillColor: const Color(0xFFEBEEF1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 19,
          vertical: 12,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 19, right: 9),
          child: Image.asset(
            'assets/images/student_homework_search.png',
            width: 19,
            height: 19,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 47,
          minHeight: 19,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: _studentHomeworkMuted,
                  size: 18,
                ),
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: _studentHomeworkTeal.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
