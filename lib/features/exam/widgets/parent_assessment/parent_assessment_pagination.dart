import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentAssessmentPagination extends StatelessWidget {
  const ParentAssessmentPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.isLoading,
    required this.onPageSelected,
  });

  final int currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final bool isLoading;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    final pages = _visiblePages(currentPage, totalPages);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PaginationArrow(
          icon: Icons.chevron_left_rounded,
          enabled: hasPrevious && !isLoading,
          tooltip: MaterialLocalizations.of(context).previousPageTooltip,
          onTap: () => onPageSelected(currentPage - 1),
        ),
        for (final page in pages)
          page == null
              ? const _PaginationEllipsis()
              : _PaginationPageButton(
                  page: page,
                  selected: page == currentPage,
                  enabled: !isLoading,
                  onTap: () => onPageSelected(page),
                ),
        _PaginationArrow(
          icon: Icons.chevron_right_rounded,
          enabled: hasNext && !isLoading,
          tooltip: MaterialLocalizations.of(context).nextPageTooltip,
          onTap: () => onPageSelected(currentPage + 1),
        ),
      ],
    );
  }
}

List<int?> _visiblePages(int currentPage, int totalPages) {
  if (totalPages <= 5) {
    return List<int>.generate(totalPages, (index) => index + 1);
  }
  if (currentPage <= 3) {
    return <int?>[1, 2, 3, null, totalPages];
  }
  if (currentPage >= totalPages - 2) {
    return <int?>[1, null, totalPages - 2, totalPages - 1, totalPages];
  }
  return <int?>[
    1,
    null,
    currentPage - 1,
    currentPage,
    currentPage + 1,
    null,
    totalPages,
  ];
}

class _PaginationArrow extends StatelessWidget {
  const _PaginationArrow({
    required this.icon,
    required this.enabled,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return IconButton(
      onPressed: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      icon: Icon(
        icon,
        size: 20,
        color: enabled
            ? colors.brandStrong
            : colors.textMuted.withValues(alpha: 0.35),
      ),
    );
  }
}

class _PaginationPageButton extends StatelessWidget {
  const _PaginationPageButton({
    required this.page,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int page;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Semantics(
      selected: selected,
      button: true,
      label: '$page',
      child: Material(
        color: selected ? colors.brandStrong : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled && !selected
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 32,
            child: Center(
              child: Text(
                '$page',
                style: TextStyle(
                  color: selected ? colors.onBrand : colors.textSecondary,
                  fontSize: FontSize.xxs,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationEllipsis extends StatelessWidget {
  const _PaginationEllipsis();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Text(
        '…',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.themeColors.textSecondary,
          fontSize: FontSize.xxs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
