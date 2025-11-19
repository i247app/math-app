import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
