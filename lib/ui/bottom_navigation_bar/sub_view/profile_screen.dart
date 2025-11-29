import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/profile_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../widget/curved_header_background.dart';
import '../widget/info_card.dart';
import '../widget/menu_row_item.dart';
import '../widget/profile_avatar_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _onRefresh() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = userProvider.user?.id;
    if (uid != null && uid.isNotEmpty) {
      await context.read<ProfileProvider>().fetchProfile(uid);
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final uid = userProvider.user?.id;
      if (uid != null && uid.isNotEmpty) {
        context.read<ProfileProvider>().fetchProfile(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;

        return Scaffold(
          body: Stack(
            children: [
              const CurvedHeaderBackground(),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFFFFB300),
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        ProfileAvatarSection(
                          name: profile?.name ?? 'User',
                          email: profile?.email ?? '',
                        ),

                        const SizedBox(height: 30),
                        InfoCard(
                          children: [
                            MenuRowItem(
                              icon: Icons.table_chart_outlined,
                              title:
                                  "Lớp hiện tại: ${profile?.grade ?? 'Chưa có'}",
                            ),
                            MenuRowItem(
                              icon: Icons.notifications_none_rounded,
                              title: "Học Kì hiện tại: Học Kỳ I",
                            ),
                            MenuRowItem(
                              icon: Icons.translate,
                              title:
                                  "Hiện tại level: ${profile?.level ?? 'Chưa có'}",
                              isLast: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Khối 2: Cài đặt
                        const InfoCard(
                          children: [
                            MenuRowItem(
                              icon: Icons.password,
                              title: "Security",
                            ),
                            MenuRowItem(
                              icon: Icons.palette_outlined,
                              title: "Theme",
                              trailingText: "Light mode",
                              isLast: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Khối 3: Hỗ trợ
                        const InfoCard(
                          children: [
                            MenuRowItem(
                              icon: Icons.person_search_outlined,
                              title: "Help & Support",
                            ),
                            MenuRowItem(
                              icon: Icons.chat_bubble_outline,
                              title: "Contact us",
                            ),
                            MenuRowItem(
                              icon: Icons.lock_outline,
                              title: "Privacy policy",
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
