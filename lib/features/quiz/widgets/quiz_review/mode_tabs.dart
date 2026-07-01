part of '../../presentation/quiz_review_screen.dart';

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.selectedMode, required this.onSelected});

  final _ReviewMode selectedMode;
  final ValueChanged<_ReviewMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeTabButton(
              label: context.getText(AppKeys.testAgain),
              selected: selectedMode == _ReviewMode.retry,
              onTap: () => onSelected(_ReviewMode.retry),
            ),
          ),
          Expanded(
            child: _ModeTabButton(
              label: context.getText(AppKeys.viewResult),
              selected: selectedMode == _ReviewMode.result,
              onTap: () => onSelected(_ReviewMode.result),
            ),
          ),
        ],
      ),
    );
  }
}
