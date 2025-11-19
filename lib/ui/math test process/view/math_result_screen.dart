import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/imgs/cloud.png',
              fit: BoxFit.cover,
              height: 500,
              width: double.infinity,
              errorBuilder: (c, e, s) => Container(
                height: 500,
                color: Colors.white.withAlpha((255 * 0.5).toInt()),
              ),
            ),
          ),

          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "TỐT LẮM!",
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF01579B),
                  ),
                ),
                Text(
                  "Đã hoàn thành 8/15 câu!",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0277BD),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  width: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/imgs/bee13.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.amber,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 120,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: Text(
                            "80%",
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/imgs/grass_background.png',
              fit: BoxFit.cover,
              height: 150,
              errorBuilder: (c, e, s) =>
                  Container(height: 150, color: Colors.green),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Column(
                  children: [
                    HeaderSection(),
                    const SizedBox(height: 10),
                    const SizedBox(height: 250),
                    const StatsRow(),
                    const SizedBox(height: 15),
                    const LevelChartSection(),
                    const SuggestionAndButtons(),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: -10,
            child: Image.asset(
              'assets/imgs/bee15.png',
              height: 180,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.bug_report, size: 100),
            ),
          ),
        ],
      ),
    );
  }
}

class BeeWithBoard extends StatelessWidget {
  const BeeWithBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/imgs/bee13.png',
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) =>
                Container(color: Colors.amber, width: 100, height: 100),
          ),
          Positioned(
            top: 50,
            right: 40,
            child: Transform.rotate(
              angle: -0.2,
              child: Text(
                "80%",
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          icon: Icons.check,
          iconColor: Colors.green,
          value: "12",
          label: "Đúng",
          bgColor: const Color(0xFFE8F5E9),
          borderColor: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.close,
          iconColor: Colors.red,
          value: "3",
          label: "Sai",
          bgColor: const Color(0xFFFFEBEE),
          borderColor: Colors.red,
        ),
        _buildStatCard(
          icon: Icons.access_time,
          iconColor: Colors.orange,
          value: "5:13",
          label: "Thời gian",
          bgColor: const Color(0xFFFFFDE7),
          borderColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: borderColor == Colors.orange
                  ? const Color(0xFFF57F17)
                  : borderColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class LevelChartSection extends StatelessWidget {
  const LevelChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          // height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(height: 20, color: Colors.deepPurple.shade200),
              const SizedBox(width: 8),
              _buildBar(height: 35, color: Colors.orange.shade300),
              const SizedBox(width: 8),
              _buildBar(height: 50, color: Colors.teal.shade300),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  Container(
                    width: 20,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Bạn đang ở",
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D47A1),
          ),
        ),
        Text(
          "Level 2 - Trung Bình",
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  Widget _buildBar({required double height, required Color color}) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class SuggestionAndButtons extends StatelessWidget {
  const SuggestionAndButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 100),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gợi ý học tập:",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              _buildBulletPoint("Bé cần cải thiện kỹ năng nhân chia cơ bản"),
              _buildBulletPoint(
                "Điểm mạnh của bé là so sánh số - hãy phát huy nhé!",
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E2723), // Màu nâu
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Trang Chủ",
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E2723), // Màu nâu
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Tiếp tục luyện",
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(fontSize: 18, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
