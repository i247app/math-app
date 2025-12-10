
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
class AvatarPickerWidget extends StatelessWidget {
  final XFile? selectedImage;
  final VoidCallback onTap;

  const AvatarPickerWidget({
    super.key,
    required this.selectedImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.shade100, width: 4),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.orange.shade50,
              backgroundImage: selectedImage != null
                  ? FileImage(File(selectedImage!.path))
                  : null,
              child: selectedImage == null
                  ? ClipOval(
                      child: Image.asset(
                        'assets/imgs/woman.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.orange,
                            ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhấn để chọn ảnh đại diện',
          style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
