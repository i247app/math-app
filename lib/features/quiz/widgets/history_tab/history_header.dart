part of '../../history_tab.dart';

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.scale, required this.topInset});

  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: context.getText(AppKeys.historyTitle),
      scale: scale,
      topInset: topInset,
    );
  }
}
