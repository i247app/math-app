import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/application/read_models/profile_avatar_catalog.dart';
import 'package:numi/shared/widgets/profile_avatar_image.dart';

class AddProfileAvatar extends StatelessWidget {
  const AddProfileAvatar({
    super.key,
    required this.avatarKey,
    required this.avatarUrl,
    required this.onChanged,
    required this.onClear,
  });

  final String? avatarKey;
  final String? avatarUrl;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final key = avatarKey?.trim();
    final url = avatarUrl?.trim();
    final hasCatalogAvatar = ProfileAvatarCatalog.urlForKey(key) != null;
    const size = 124.0;

    return Center(
      child: Semantics(
        button: true,
        label: context.getText(AppKeys.chooseAvatar),
        child: SizedBox(
          width: size + 24,
          height: size + 24,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => _openAvatarSheet(context, key),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EAED),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ProfileAvatarImage(
                    size: size,
                    avatarKey: key,
                    avatarUrl: hasCatalogAvatar ? null : url,
                    foregroundColor: const Color(0xFFD3DEE1),
                    borderColor: Colors.white,
                    borderWidth: 4,
                  ),
                ),
              ),
              if (key != null && key.isNotEmpty)
                Positioned(
                  left: 14,
                  bottom: 18,
                  child: Material(
                    color: const Color(0xFFFFD8D8),
                    elevation: 5,
                    shadowColor: const Color(
                      0xFFE83434,
                    ).withValues(alpha: 0.16),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onClear,
                      child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.close_rounded,
                          color: Color(0xFFE83434),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 10,
                bottom: 18,
                child: Material(
                  color: AppColors.tealIcon,
                  elevation: 5,
                  shadowColor: AppColors.tealIcon.withValues(alpha: 0.24),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _openAvatarSheet(context, key),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAvatarSheet(
    BuildContext context,
    String? selectedKey,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return FractionallySizedBox(
          heightFactor: 0.68,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E9EC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    context.getText(AppKeys.chooseAvatar),
                    style: GoogleFonts.andika(
                      color: AppColors.tealIcon,
                      fontSize: FontSize.xxxl,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                        itemCount: ProfileAvatarCatalog.options.length,
                        itemBuilder: (context, index) {
                          final option = ProfileAvatarCatalog.options[index];
                          final isSelected = option.key == selectedKey;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () =>
                                  Navigator.of(context).pop(option.key),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ProfileAvatarImage(
                                    size: 82,
                                    avatarKey: option.key,
                                    borderColor: isSelected
                                        ? AppColors.tealIcon
                                        : Colors.transparent,
                                    borderWidth: 4,
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.tealIcon,
                                        size: 24,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }
}
