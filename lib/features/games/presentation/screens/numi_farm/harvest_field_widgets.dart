part of '../numi_farm_stage_screen.dart';

class _FarmField extends StatelessWidget {
  const _FarmField({
    required this.itemCount,
    required this.pickedCarrots,
    required this.onCarrotTap,
  });

  final int itemCount;
  final Set<int> pickedCarrots;
  final ValueChanged<int> onCarrotTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F6D4), Color(0xFFD5EDB8)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _farmLeaf.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: _farmDeepGreen.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 310 ? 3 : 4;
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) => _CarrotPlot(
              isPicked: pickedCarrots.contains(index),
              onTap: () => onCarrotTap(index),
            ),
          );
        },
      ),
    );
  }
}

class _CarrotPlot extends StatelessWidget {
  const _CarrotPlot({required this.isPicked, required this.onTap});

  final bool isPicked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isPicked,
      label: context.getText(AppKeys.gamesFarmCarrot),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isPicked
                  ? Colors.white.withValues(alpha: 0.38)
                  : Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPicked
                    ? _farmGreen.withValues(alpha: 0.36)
                    : Colors.white.withValues(alpha: 0.72),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
              child: isPicked
                  ? const _PickedCarrotSpot(key: ValueKey('picked'))
                  : const _CarrotIllustration(key: ValueKey('carrot')),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedCarrotSpot extends StatelessWidget {
  const _PickedCarrotSpot({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 20,
          decoration: BoxDecoration(
            color: _farmSoil.withValues(alpha: 0.44),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: _farmGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 23),
        ),
      ],
    );
  }
}

class _CarrotIllustration extends StatelessWidget {
  const _CarrotIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: CustomPaint(painter: _CarrotPainter(), child: SizedBox.expand()),
    );
  }
}

class _CarrotPainter extends CustomPainter {
  const _CarrotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.36);
    final leafPaint = Paint()..color = _farmLeaf;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (final angle in <double>[-0.55, -0.18, 0.18, 0.55]) {
      canvas.save();
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -size.height * 0.18),
            width: size.width * 0.16,
            height: size.height * 0.38,
          ),
          Radius.circular(size.width * 0.08),
        ),
        leafPaint,
      );
      canvas.restore();
    }
    canvas.restore();

    final carrotPath = Path()
      ..moveTo(size.width * 0.29, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.29,
        size.width * 0.71,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.63,
        size.height * 0.76,
        size.width * 0.50,
        size.height * 0.92,
      )
      ..quadraticBezierTo(
        size.width * 0.37,
        size.height * 0.76,
        size.width * 0.29,
        size.height * 0.38,
      )
      ..close();
    canvas.drawPath(carrotPath, Paint()..color = _farmOrange);

    final detailPaint = Paint()
      ..color = const Color(0xFFE36C22)
      ..strokeWidth = math.max(1.5, size.width * 0.025)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.51 + i * 0.11);
      canvas.drawLine(
        Offset(size.width * 0.40, y),
        Offset(size.width * 0.55, y + size.height * 0.025),
        detailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CarrotPainter oldDelegate) => false;
}

class _FarmBottomBar extends StatelessWidget {
  const _FarmBottomBar({
    required this.picked,
    required this.target,
    required this.isSolved,
    required this.isWrong,
    required this.onPressed,
  });

  final int picked;
  final int target;
  final bool isSolved;
  final bool isWrong;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 112),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWrong
                  ? const Color(0xFFE53935)
                  : _farmGreen.withValues(alpha: 0.12),
              width: isWrong ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_basket_rounded, color: _farmOrange),
              const SizedBox(width: 8),
              Text(
                '$picked/$target',
                style: TextStyle(
                  color: isWrong ? const Color(0xFFD32F2F) : _farmInk,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: picked == 0 || isSolved || isWrong ? null : onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: isSolved ? _farmLeaf : _farmGreen,
              disabledBackgroundColor: isSolved
                  ? _farmLeaf
                  : isWrong
                  ? const Color(0xFFE53935)
                  : _farmGreen.withValues(alpha: 0.16),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isSolved
                  ? context.getText(AppKeys.gamesFarmCorrect)
                  : isWrong
                  ? context.getText(AppKeys.gamesFarmIncorrect)
                  : context.getText(AppKeys.gamesFarmCheck),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
