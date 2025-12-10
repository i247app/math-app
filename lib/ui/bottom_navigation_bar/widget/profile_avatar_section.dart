import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onEditTap;

  const ProfileAvatarSection({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFFFCC80),
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person_4_rounded,
                        size: 80,
                        color: Colors.brown,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.1).toInt()),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        Text(
          email,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
