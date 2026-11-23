import 'package:material_ui/material_ui.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';

class StarGameRating extends StatelessWidget {
  const StarGameRating({super.key, required this.stars, this.size = 20});

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.formatText(AppKeys.gamesStars, {'count': stars}),
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 3; index++)
          Icon(
            index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: index < stars ? starGameGold : starGameMuted,
          ),
      ],
    ),
  );
}

class StarGameButton extends StatelessWidget {
  const StarGameButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 21),
    label: Text(label, textAlign: TextAlign.center),
    style: FilledButton.styleFrom(
      backgroundColor: starGameGold,
      foregroundColor: starGameInk,
      disabledBackgroundColor: starGamePanel,
      disabledForegroundColor: starGameMuted,
      minimumSize: const Size(0, 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: Theme.of(context).textTheme.labelLarge
          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

class StarGameSaveNotice extends StatelessWidget {
  const StarGameSaveNotice({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onRetry,
    icon: const Icon(Icons.refresh_rounded),
    label: Text(context.getText(AppKeys.gamesSaveFailed)),
    style: TextButton.styleFrom(foregroundColor: starGameGold),
  );
}
