part of '../../history_tab.dart';

class _HistorySearchField extends StatelessWidget {
  const _HistorySearchField({required this.controller, required this.scale});

  final TextEditingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30 * scale),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: _deepInk,
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: context.getText(AppKeys.searchHint),
          hintStyle: TextStyle(
            color: const Color(0xFFD8C5CC),
            fontSize: FontSize.normal * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14 * scale, right: 6 * scale),
            child: Icon(Icons.search_rounded, color: _navy, size: 22 * scale),
          ),
          suffixIcon: IconButton(
            onPressed: HapticFeedback.selectionClick,
            icon: Icon(Icons.tune_rounded, color: _navy, size: 22 * scale),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 11 * scale,
            horizontal: 10 * scale,
          ),
        ),
      ),
    );
  }
}
