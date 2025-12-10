import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';

import '../../math_selection_screen/widget/topic_card.dart';

class MathSelectionScreen extends StatelessWidget {
  const MathSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              HeaderSection(),

              const SizedBox(height: 20),

              
              Text(
                "Chọn dạng Toán\nđã học!",
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF222222),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 20),

              
              const TopicCard(
                color: Color(0xFF98D8D0), 
                title: "ÔN TẬP VÀ BỔ SUNG",
                items: [
                  "Ôn tập số đến 100",
                  "So sánh, ước lượng",
                  "Cộng – trừ cơ bản, thứ tự số (số liền trước, số liền sau)",
                  "Điểm và đoạn thẳng",
                  "Đơn vị đo: đề-xi-mét.",
                ],
              ),

              const SizedBox(height: 15),

              
              const TopicCard(
                color: Color(0xFF9AE1FC), 
                title: "PHÉP CỘNG, PHÉP TRỪ QUA 10 TRONG PHẠM VI 20",
                items: [
                  "Ôn tập số đến 100",
                  "So sánh, ước lượng",
                  "Cộng – trừ cơ bản, thứ tự số (số liền trước, số liền sau)",
                ],
              ),

              const SizedBox(height: 15),

              
              const TopicCard(
                color: Color(0xFFFCE196), 
                title: "CÁC SỐ ĐẾN 1000",
                items: [
                  "Ôn tập số đến 100",
                  "So sánh, ước lượng",
                  "Cộng – trừ cơ bản, thứ tự số (số liền trước, số liền sau)",
                ],
              ),

              const SizedBox(height: 30),

              
              Center(
                child: SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E2714), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "Tiếp Tục",
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
