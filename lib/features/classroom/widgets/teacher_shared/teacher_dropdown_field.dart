part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherDropdownField<T> extends StatelessWidget {
  const _TeacherDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.displayText,
    required this.onChanged,
    required this.scale,
    this.outlined = false,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) displayText;
  final ValueChanged<T?> onChanged;
  final double scale;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = value == null ? null : displayText(value as T);
    final canSelect = items.isNotEmpty;

    return _TeacherFieldShell(
      label: label,
      scale: scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canSelect ? () => _openSelector(context) : null,
          borderRadius: BorderRadius.circular(
            outlined ? 16 * scale : 12 * scale,
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: InputDecorator(
            isEmpty: selectedLabel == null,
            decoration: _teacherInputDecoration(
              hintText: items.isEmpty
                  ? context.getText(AppKeys.teacherNoOptions)
                  : null,
              scale: scale,
              outlined: outlined,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedLabel ?? context.getText(AppKeys.teacherNoOptions),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: selectedLabel == null
                          ? const Color(0x806B7280)
                          : _teacherInk,
                      fontSize: FontSize.normal * scale,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: canSelect
                      ? _teacherTeal
                      : _teacherMuted.withValues(alpha: 0.45),
                  size: 22 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSelector(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            10 * scale,
            20 * scale,
            bottomInset + 18 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28 * scale),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24 * scale,
                offset: Offset(0, -8 * scale),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 46 * scale,
                    height: 5 * scale,
                    margin: EdgeInsets.only(bottom: 14 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E9EC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.andika(
                    color: _teacherTeal,
                    fontSize: FontSize.xxxl * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10 * scale),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 360 * scale),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFEFF4F5)),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = identical(item, value);
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            displayText(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.andika(
                              color: _teacherInk,
                              fontSize: FontSize.normal * scale,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: _teacherTeal,
                                  size: 22 * scale,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(item),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      onChanged(selected);
    }
  }
}
