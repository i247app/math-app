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
              // 1. Header Section (Giả lập phần đã có sẵn của bạn)
              HeaderSection(),

              const SizedBox(height: 20),

              // 2. Main Title
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

              // 3. Card 1: Ôn tập và bổ sung (Màu xanh ngọc)
              const TopicCard(
                color: Color(0xFF98D8D0), // Màu xanh ngọc
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

              // 4. Card 2: Phép cộng trừ (Màu xanh dương nhạt)
              const TopicCard(
                color: Color(0xFF9AE1FC), // Màu xanh dương
                title: "PHÉP CỘNG, PHÉP TRỪ QUA 10 TRONG PHẠM VI 20",
                items: [
                  "Ôn tập số đến 100",
                  "So sánh, ước lượng",
                  "Cộng – trừ cơ bản, thứ tự số (số liền trước, số liền sau)",
                ],
              ),

              const SizedBox(height: 15),

              // 5. Card 3: Các số đến 1000 (Màu vàng)
              const TopicCard(
                color: Color(0xFFFCE196), // Màu vàng
                title: "CÁC SỐ ĐẾN 1000",
                items: [
                  "Ôn tập số đến 100",
                  "So sánh, ước lượng",
                  "Cộng – trừ cơ bản, thứ tự số (số liền trước, số liền sau)",
                ],
              ),

              const SizedBox(height: 30),

              // 6. Button Tiếp Tục
              Center(
                child: SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E2714), // Màu nâu đậm
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
