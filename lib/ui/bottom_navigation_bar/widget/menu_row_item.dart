import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuRowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final bool isLast;

  const MenuRowItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 26, color: Colors.black87),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
      ],
    );
  }
}
