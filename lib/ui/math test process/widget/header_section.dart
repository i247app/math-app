import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello",
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.black87,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/imgs/bee.jpg',
                    width: 35,
                    errorBuilder: (c, o, s) =>
                        const Icon(Icons.bug_report, color: Colors.yellow),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userProvider.userName,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange.shade100, width: 2),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.orange.shade100,
            backgroundImage: userProvider.user?.avatarUrl != null
                ? NetworkImage(userProvider.user!.avatarUrl!)
                : const AssetImage("assets/imgs/woman.png"),
            onBackgroundImageError: (_, _) {},
          ),
        ),
      ],
    );
  }
}
