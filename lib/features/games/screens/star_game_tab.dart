import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/games/controllers/star_game_progress.dart';
import 'package:numi/features/games/screens/star_game_map_screen.dart';
import 'package:numi/features/games/widgets/star_game_entry_card.dart';
import 'package:numi/shared/layouts/page_header.dart';

class StarGameTab extends StatefulWidget {
  const StarGameTab({
    super.key,
    required this.bottomPadding,
    this.storageKey,
    this.isActive = true,
  });

  final double bottomPadding;
  final String? storageKey;
  final bool isActive;

  @override
  State<StarGameTab> createState() => _StarGameTabState();
}

class _StarGameTabState extends State<StarGameTab> {
  StarGameProgress? _progress;
  bool _openingMap = false;
  bool _hasPlayedEntrance = false;

  Future<void> _openMap() async {
    if (_openingMap) return;
    _openingMap = true;
    final progress = _progress ??= StarGameProgress(widget.storageKey);
    HapticFeedback.selectionClick();
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => StarGameMapScreen(progress: progress),
        ),
      );
    } finally {
      _openingMap = false;
    }
  }

  @override
  void dispose() {
    _progress?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return ColoredBox(
      color: colors.elevatedSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: context.getText(AppKeys.gamesTabTitle)),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 20, 24, widget.bottomPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: widget.isActive || _hasPlayedEntrance
                        ? AppStaggeredEntrance(
                            order: 0,
                            initiallyVisible: _hasPlayedEntrance,
                            onFinished: () {
                              if (mounted) {
                                setState(() => _hasPlayedEntrance = true);
                              }
                            },
                            child: StarGameEntryCard(onTap: _openMap),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
