import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

/// Shared frame for option selectors. Features supply their title and content.
class OptionBottomSheetShell extends StatelessWidget {
  const OptionBottomSheetShell({
    super.key,
    required this.children,
    this.backgroundColor,
    this.handleColor,
    this.shadowColor,
  });

  final List<Widget> children;
  final Color? backgroundColor;
  final Color? handleColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 18),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.themeColors.elevatedSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? context.themeColors.shadow,
            blurRadius: 24,
            offset: const Offset(0, -8),
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
                width: 46,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: handleColor ?? context.themeColors.borderStrong,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// The bounded, scrolling list shared by single-option selectors.
class OptionBottomSheetList extends StatelessWidget {
  const OptionBottomSheetList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.dividerColor,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: dividerColor ?? context.themeColors.border,
        ),
        itemBuilder: itemBuilder,
      ),
    ),
  );
}
