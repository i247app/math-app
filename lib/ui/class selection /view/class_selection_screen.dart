import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/ui/math%20test%20process/view/math_test_intro_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';

import '../data/class_item_data.dart';
import '../widget/class_card_widget.dart';

class ClassSelectionScreen extends StatelessWidget {
  const ClassSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the data for the classes
    final List<ClassItemData> classes = [
      ClassItemData(
        title: "Mẫu giáo",
        imagePath: "assets/imgs/maugiao.jpg",
        color: const Color(0xFF9FE6D8), // Teal/Green color
      ),
      ClassItemData(
        title: "Lớp 1",
        imagePath: "assets/imgs/lop1.jpg",
        color: const Color(0xFFFFD561), // Yellow color
      ),
      ClassItemData(
        title: "Lớp 2",
        imagePath: "assets/imgs/lop2.jpg", // Assuming you have this
        color: const Color(0xFFFF8A65), // Orange color
      ),
      ClassItemData(
        title: "Lớp 3",
        imagePath: "assets/imgs/lop3.jpg", // Assuming you have this
        color: const Color(0xFFAEDEF4), // Light Blue color
      ),
      ClassItemData(
        title: "Lớp 4",
        imagePath: "assets/imgs/lop4.jpg", // Assuming you have this
        color: const Color(0xFFC5E1A5), // Light Green color
      ),
      ClassItemData(
        title: "Lớp 5",
        imagePath: "assets/imgs/lop5.jpg",
        color: const Color(0xFFF8BBD0), // Pink color
        hasBadge: true, // Special flag for Class 5
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(),
              const SizedBox(height: 40),

              // 2. TITLE SECTION
              Text(
                "Chọn Lớp Học\ncủa bạn!",
                style: GoogleFonts.nunito(
                  fontSize: 40,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1C),
                ),
              ),

              const SizedBox(height: 30),

              // 3. GRID SECTION
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: classes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 items per row
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 20, // Space between rows
                    childAspectRatio:
                        0.75, // Adjust height of cards relative to width
                  ),
                  itemBuilder: (context, index) {
                    return ClassCard(data: classes[index]);
                  },
                ),
              ),

              // 4. BUTTON SECTION
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Continue Action
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MathTestIntroScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF3E2723,
                    ), // Dark Brown color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Tiếp Tục",
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
