part of '../../presentation/assessment_screen.dart';

class _GeneratingQuestionLoaderState extends State<_GeneratingQuestionLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['n', 'u', 'm', 'i', 'n', 'u', 'm', 'i'];

    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(letters.length, (index) {
                  final delayedProgress =
                      (controller.value - (index * 0.075)) % 1.0;
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
                        color: _assessmentTeal,
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
                      color: _assessmentMuted,
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
