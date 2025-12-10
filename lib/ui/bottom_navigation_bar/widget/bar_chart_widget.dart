import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Center(
        child: SizedBox(
          width: 300,
          height: 250,
          child: Stack(
            children: [
              // Bars
              Positioned(
                bottom: 0,
                left: 20,
                child: _buildBar(
                  width: 47.93087113757332,
                  height: 50,
                  color: const Color(0xFF8BC34A),
                  angle: 0,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 90,
                child: _buildBar(
                  width: 47.93087113757332,
                  height: 100,
                  color: const Color(0xFFFF8484),
                  angle: 0,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 160,
                child: _buildBar(
                  width: 47.93087113757332,
                  height: 150,
                  color: const Color(0xFFDED2FB),
                  angle: 0,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 230,
                child: _buildBar(
                  width: 47.93087113757332,
                  height: 200,
                  color: const Color(0xFF7B94C9),
                  angle: 0,
                ),
              ),
              // Connecting line
              CustomPaint(
                size: const Size(300, 250),
                painter: _BarChartLinePainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar({
    required double width,
    required double height,
    required Color color,
    required double angle,
  }) {
    return Transform.rotate(
      angle: angle * 3.14159 / 180, // Convert degrees to radians
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _BarChartLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Points for the tops of the bars (adjusted for positions and heights)
    final points = [
      Offset(20 + 47.93 / 2, 250 - 50), // Center of first bar
      Offset(90 + 47.93 / 2, 250 - 100), // Center of second bar
      Offset(160 + 47.93 / 2, 250 - 150), // Center of third bar
      Offset(230 + 47.93 / 2, 250 - 200), // Center of fourth bar
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
