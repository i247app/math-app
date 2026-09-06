part of '../monster_rescue_stage_screen.dart';

class _GateCard extends StatelessWidget {
  const _GateCard({
    super.key,
    required this.gate,
    required this.teamSize,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final RescueGate gate;
  final int teamSize;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final result = gate.apply(teamSize);
    return Semantics(
      button: true,
      label: '${gate.label}, $teamSize thành $result',
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            height: 137,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.32), blurRadius: 15),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gate.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 37,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$teamSize → $result 🐾',
                    style: const TextStyle(
                      color: _rescueInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumiSquad extends StatelessWidget {
  const _NumiSquad({required this.count, this.previousCount});

  final int count;
  final int? previousCount;

  @override
  Widget build(BuildContext context) {
    final visible = count.clamp(0, 14);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: -5,
            runSpacing: -5,
            children: List.generate(
              visible,
              (index) => AnimatedScale(
                duration: Duration(milliseconds: 220 + (index * 25)),
                scale: previousCount != null && index >= previousCount!
                    ? 1.28
                    : 1,
                curve: Curves.elasticOut,
                child: const Text('🐾', style: TextStyle(fontSize: 27)),
              ),
            ),
          ),
        ),
        if (count > visible)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '+${count - visible}',
              style: const TextStyle(
                color: _rescueInk,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _TeamBox extends StatelessWidget {
  const _TeamBox({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _rescueInk,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$count 🐾',
            style: const TextStyle(
              color: _rescueInk,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BossCore extends StatelessWidget {
  const _BossCore({
    super.key,
    required this.requiredNumi,
    required this.broken,
    required this.enabled,
    required this.onTap,
  });

  final int requiredNumi;
  final bool broken;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: broken ? _rescueTeal.withValues(alpha: 0.35) : _rescueCoral,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: broken ? _rescueSky : Colors.white,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                broken ? Icons.bolt_rounded : Icons.lock_rounded,
                color: Colors.white,
                size: 27,
              ),
              const SizedBox(height: 5),
              Text(
                broken ? '✓' : '$requiredNumi 🐾',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.08, size.height)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.06,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.94,
        size.width * 0.92,
        0,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB79063)
        ..strokeWidth = 40
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE5C99F)
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
