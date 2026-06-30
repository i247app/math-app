part of '../../presentation/student_homework_attempt_screen.dart';

class _StudentHomeworkAttemptLoader extends StatefulWidget {
  const _StudentHomeworkAttemptLoader({
    super.key,
    required this.scale,
    this.message,
  });

  final double scale;
  final String? message;

  @override
  State<_StudentHomeworkAttemptLoader> createState() =>
      _StudentHomeworkAttemptLoaderState();
}

class _StudentHomeworkAttemptLoaderState
    extends State<_StudentHomeworkAttemptLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['n', 'u', 'm', 'i', 'n', 'u', 'm', 'i'];

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(letters.length, (index) {
                  final delayedProgress =
                      (_controller.value - (index * 0.075)) % 1.0;
                  final lift = delayedProgress <= 0.20
                      ? -34 *
                            widget.scale *
                            math.sin(delayedProgress / 0.20 * math.pi)
                      : 0.0;

                  return Transform.translate(
                    offset: Offset(0, lift),
                    child: Text(
                      letters[index],
                      style: TextStyle(
                        color: _homeworkAttemptTeal,
                        fontSize: 40 * widget.scale,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 3 * widget.scale,
                      ),
                    ),
                  );
                }),
              ),
              if (widget.message != null) ...[
                SizedBox(height: 18 * widget.scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32 * widget.scale),
                  child: Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _homeworkAttemptMuted,
                      fontSize: 16 * widget.scale,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
