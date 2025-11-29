import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final Color color;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: color.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              "Màn hình $title",
              style: GoogleFonts.nunito(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
