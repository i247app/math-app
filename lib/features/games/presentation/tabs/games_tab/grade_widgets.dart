part of '../games_tab.dart';

class _GamesGradeCard extends StatelessWidget {
  const _GamesGradeCard({
    required this.grade,
    required this.index,
    required this.onTap,
  });

  final GradeModel grade;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = grade.label?.trim() ?? '';
    final isKindergarten = _isKindergartenLabel(label);
    final display = _GradeDisplay.fromGrade(grade);
    final palette = _GradeCirclePalette.forGrade(
      display.number,
      fallbackIndex: index,
      isKindergarten: isKindergarten,
    );

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: _GradeOvalButton(
          display: display,
          palette: palette,
          isKindergarten: isKindergarten,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _GradeOvalButton extends StatelessWidget {
  const _GradeOvalButton({
    required this.display,
    required this.palette,
    required this.isKindergarten,
    required this.onTap,
  });

  final _GradeDisplay display;
  final _GradeCirclePalette palette;
  final bool isKindergarten;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final buttonWidth = width;
        final buttonHeight = height;
        final contentSize = math.min(buttonWidth, buttonHeight);
        final buttonBorderRadius = BorderRadius.all(
          Radius.elliptical(buttonWidth / 2, buttonHeight / 2),
        );
        final buttonShape = RoundedRectangleBorder(
          borderRadius: buttonBorderRadius,
        );
        final button = Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            borderRadius: buttonBorderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.highlight, palette.top, palette.bottom],
              stops: const [0, 0.43, 1],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.72),
              width: math.max(1.5, contentSize * 0.018),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.edge,
                offset: Offset(0, buttonHeight * 0.052),
                blurRadius: 0,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color(0x59052F3B),
                offset: Offset(0, buttonHeight * 0.085),
                blurRadius: contentSize * 0.08,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                offset: Offset(-buttonWidth * 0.025, -buttonHeight * 0.025),
                blurRadius: contentSize * 0.045,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: buttonHeight * 0.07,
                left: buttonWidth * 0.16,
                right: buttonWidth * 0.16,
                height: buttonHeight * 0.24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: buttonBorderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.32),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    buttonWidth * 0.1,
                    buttonHeight * 0.09,
                    buttonWidth * 0.1,
                    buttonHeight * 0.08,
                  ),
                  child: isKindergarten
                      ? _KindergartenButtonContent(
                          caption: display.caption,
                          size: contentSize,
                        )
                      : _GradeButtonContent(
                          display: display,
                          size: contentSize,
                        ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  shape: buttonShape,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    customBorder: buttonShape,
                    splashColor: Colors.white24,
                    highlightColor: Colors.white10,
                  ),
                ),
              ),
            ],
          ),
        );

        return button;
      },
    );
  }
}

class _GradeButtonContent extends StatelessWidget {
  const _GradeButtonContent({required this.display, required this.size});

  final _GradeDisplay display;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _OutlinedGradeText(
          display.number ?? '',
          fontSize: size * 0.55,
          outlineColor: const Color(0x4D173E62),
        ),
        SizedBox(height: size * 0.005),
        _OutlinedGradeText(
          '${display.caption} ${display.number ?? ''}'.trim(),
          fontSize: size * 0.15,
          outlineColor: const Color(0x66173E62),
        ),
      ],
    );
  }
}

class _KindergartenButtonContent extends StatelessWidget {
  const _KindergartenButtonContent({required this.caption, required this.size});

  final String caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: size * 0.31,
          shadows: const [
            Shadow(
              color: Color(0x5C6A2600),
              offset: Offset(0, 3),
              blurRadius: 2,
            ),
          ],
        ),
        SizedBox(height: size * 0.035),
        _OutlinedGradeText(
          caption,
          fontSize: size * 0.145,
          outlineColor: const Color(0x667C2F00),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _GradeCirclePalette {
  const _GradeCirclePalette({
    required this.highlight,
    required this.top,
    required this.bottom,
    required this.edge,
  });

  factory _GradeCirclePalette.forGrade(
    String? number, {
    required int fallbackIndex,
    required bool isKindergarten,
  }) {
    if (isKindergarten) {
      return palettes.first;
    }
    final gradeNumber = int.tryParse(number ?? '');
    final paletteIndex = gradeNumber == null
        ? 1 + (fallbackIndex % (palettes.length - 1))
        : gradeNumber.clamp(1, 5);
    return palettes[paletteIndex];
  }

  static const palettes = <_GradeCirclePalette>[
    _GradeCirclePalette(
      highlight: Color(0xFFFFCE3E),
      top: Color(0xFFFFA91F),
      bottom: Color(0xFFF07808),
      edge: Color(0xFFD95704),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFFB8F33B),
      top: Color(0xFF7ED321),
      bottom: Color(0xFF45AC13),
      edge: Color(0xFF2B8810),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFF5ED1FF),
      top: Color(0xFF20A5E9),
      bottom: Color(0xFF0873C6),
      edge: Color(0xFF07569F),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFFC879F4),
      top: Color(0xFF9850D7),
      bottom: Color(0xFF6425B4),
      edge: Color(0xFF46168A),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFFFF89B4),
      top: Color(0xFFF25994),
      bottom: Color(0xFFC92369),
      edge: Color(0xFF9C164F),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFF68E9E7),
      top: Color(0xFF28C7C8),
      bottom: Color(0xFF0795A4),
      edge: Color(0xFF057581),
    ),
  ];

  final Color highlight;
  final Color top;
  final Color bottom;
  final Color edge;
}

class _OutlinedGradeText extends StatelessWidget {
  const _OutlinedGradeText(
    this.text, {
    required this.fontSize,
    required this.outlineColor,
    this.maxLines = 1,
  });

  final String text;
  final double fontSize;
  final Color outlineColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 0.95,
      letterSpacing: -0.8,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            text.toUpperCase(),
            maxLines: maxLines,
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = math.max(1.3, fontSize * 0.12)
                ..strokeJoin = StrokeJoin.round
                ..color = outlineColor,
            ),
          ),
          Text(
            text.toUpperCase(),
            maxLines: maxLines,
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Color(0x4D411300),
                  offset: Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeDisplay {
  const _GradeDisplay({required this.caption, this.number});

  factory _GradeDisplay.fromGrade(GradeModel grade) {
    final label = grade.label?.trim() ?? '';
    final numberMatch = RegExp(r'\d+').firstMatch(label);
    if (numberMatch == null) {
      return _GradeDisplay(caption: label.replaceFirst(RegExp(r'\s+'), '\n'));
    }

    final caption = label
        .replaceRange(numberMatch.start, numberMatch.end, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return _GradeDisplay(
      caption: caption.isEmpty ? label : caption,
      number: numberMatch.group(0),
    );
  }

  final String caption;
  final String? number;
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.elevatedSurface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, color: colors.brandStrong, size: 18),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.brandStrong,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
