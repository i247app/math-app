part of 'package:numi/features/quiz/presentation/tabs/history_tab.dart';

class _HistoryIncompleteBadge extends StatelessWidget {
  const _HistoryIncompleteBadge({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      child: Text(
        context.getText(AppKeys.incomplete),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.orangeMuted,
          fontSize: FontSize.caption * 0.77 * scale,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
