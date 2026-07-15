import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_field_shell.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_primary_button.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_selected_chip.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_shared_helpers.dart';

class TeacherMultiSelectField<T> extends StatelessWidget {
  const TeacherMultiSelectField({
    super.key,
    required this.label,
    required this.values,
    required this.items,
    required this.displayText,
    required this.itemId,
    required this.onChanged,
    required this.scale,
    this.emptyText,
  });

  final String label;
  final List<T> values;
  final List<T> items;
  final String Function(T item) displayText;
  final int? Function(T item) itemId;
  final ValueChanged<List<T>> onChanged;
  final double scale;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = values.map(displayText).join(', ');
    final canSelect = items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeacherFieldShell(
          label: label,
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canSelect ? () => _openSelector(context) : null,
              borderRadius: BorderRadius.circular(12 * scale),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: InputDecorator(
                isEmpty: values.isEmpty,
                decoration: teacherInputDecoration(
                  hintText: items.isEmpty
                      ? context.getText(AppKeys.teacherNoOptions)
                      : emptyText,
                  scale: scale,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        values.isEmpty
                            ? (emptyText ??
                                  context.getText(AppKeys.teacherNoOptions))
                            : selectedLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: values.isEmpty
                              ? const Color(0x806B7280)
                              : AppColors.textInkDark,
                          fontSize: FontSize.normal * scale,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: canSelect
                          ? AppColors.teal520
                          : AppColors.textCoolMuted.withValues(alpha: 0.45),
                      size: 22 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (values.isNotEmpty) ...[
          SizedBox(height: 10 * scale),
          Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: [
              for (final value in values)
                TeacherSelectedChip(
                  label: displayText(value),
                  scale: scale,
                  onDeleted: () {
                    final id = itemId(value);
                    onChanged(
                      values
                          .where((item) => itemId(item) != id)
                          .toList(growable: false),
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _openSelector(BuildContext context) async {
    final selected = await showModalBottomSheet<List<T>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        final maxSheetHeight = math.min(
          MediaQuery.sizeOf(context).height * 0.78,
          620 * scale,
        );
        var selectedIds = values.map(itemId).whereType<int>().toSet();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedValues = items
                .where((item) => selectedIds.contains(itemId(item)))
                .toList(growable: false);

            return Container(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
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
                        color: AppColors.teal520,
                        fontSize: FontSize.xxxl * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: Color(0xFFEFF4F5)),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final id = itemId(item);
                          if (id == null) {
                            return const SizedBox.shrink();
                          }
                          final isSelected = selectedIds.contains(id);
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                displayText(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: AppColors.textInkDark,
                                  fontSize: FontSize.normal * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? AppColors.teal520
                                    : const Color(0xFFC4C6D2),
                                size: 22 * scale,
                              ),
                              onTap: () {
                                setSheetState(() {
                                  selectedIds = Set<int>.from(selectedIds);
                                  if (isSelected) {
                                    selectedIds.remove(id);
                                  } else {
                                    selectedIds.add(id);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    TeacherPrimaryButton(
                      label: context.getText(AppKeys.save),
                      icon: Icons.check_rounded,
                      width: double.infinity,
                      height: 50 * scale,
                      scale: scale,
                      onPressed: () =>
                          Navigator.of(context).pop(selectedValues),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      onChanged(selected);
    }
  }
}
