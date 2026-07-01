part of '../../../home_screen.dart';

class _ParentStreakDay extends StatelessWidget {
  const _ParentStreakDay({required this.label, required this.state});

  final String label;
  final _ParentStreakDayState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9A6B61),
            fontSize: FontSize.caption * 0.77,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 31,
          height: 31,
          child: switch (state) {
            _ParentStreakDayState.done => const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF4FB465),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 19),
            ),
            _ParentStreakDayState.current => const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFF5F19),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            _ParentStreakDayState.upcoming => const CustomPaint(
              painter: _ParentDashedCirclePainter(),
              child: Center(
                child: Text(
                  '5',
                  style: TextStyle(
                    color: Color(0xFFC98E7E),
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          },
        ),
      ],
    );
  }
}
