import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/profile/profile_avatar.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';
import 'package:numi_flutter/features/settings/settings_style.dart';

class AddProfileAvatar extends StatelessWidget {
  const AddProfileAvatar({
    super.key,
    required this.avatarKey,
    required this.avatarUrl,
    required this.scale,
    required this.onChanged,
    required this.onClear,
  });

  final String? avatarKey;
  final String? avatarUrl;
  final double scale;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final key = avatarKey?.trim();
    final url = avatarUrl?.trim();
    final hasCatalogAvatar = ProfileAvatarCatalog.urlForKey(key) != null;
    final size = 124 * scale;

    return Center(
      child: Semantics(
        button: true,
        label: context.getText(AppKeys.chooseAvatar),
        child: SizedBox(
          width: size + 24 * scale,
          height: size + 24 * scale,
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
                        blurRadius: 12 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: ProfileAvatarImage(
                    size: size,
                    avatarKey: key,
                    avatarUrl: hasCatalogAvatar ? null : url,
                    foregroundColor: const Color(0xFFD3DEE1),
                    borderColor: Colors.white,
                    borderWidth: 4 * scale,
                  ),
                ),
              ),
              if (key != null && key.isNotEmpty)
                Positioned(
                  left: 14 * scale,
                  bottom: 18 * scale,
                  child: Material(
                    color: const Color(0xFFFFD8D8),
                    elevation: 5,
                    shadowColor:
                        const Color(0xFFE83434).withValues(alpha: 0.16),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onClear,
                      child: SizedBox(
                        width: 38 * scale,
                        height: 38 * scale,
                        child: Icon(
                          Icons.close_rounded,
                          color: const Color(0xFFE83434),
                          size: 22 * scale,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 10 * scale,
                bottom: 18 * scale,
                child: Material(
                  color: settingsTeal,
                  elevation: 5,
                  shadowColor: settingsTeal.withValues(alpha: 0.24),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _openAvatarSheet(context, key),
                    child: SizedBox(
                      width: 36 * scale,
                      height: 36 * scale,
                      child: Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: 18 * scale,
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
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              10 * scale,
              20 * scale,
              bottomInset + 20 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28 * scale),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24 * scale,
                  offset: Offset(0, -8 * scale),
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
                      width: 46 * scale,
                      height: 5 * scale,
                      margin: EdgeInsets.only(bottom: 14 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E9EC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    context.getText(AppKeys.chooseAvatar),
                    style: GoogleFonts.andika(
                      color: settingsTeal,
                      fontSize: FontSize.xxxl * scale,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16 * scale,
                        crossAxisSpacing: 16 * scale,
                      ),
                      itemCount: ProfileAvatarCatalog.options.length,
                      itemBuilder: (context, index) {
                        final option = ProfileAvatarCatalog.options[index];
                        final isSelected = option.key == selectedKey;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).pop(option.key),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ProfileAvatarImage(
                                  size: 82 * scale,
                                  avatarKey: option.key,
                                  borderColor: isSelected
                                      ? settingsTeal
                                      : Colors.transparent,
                                  borderWidth: 4 * scale,
                                ),
                                if (isSelected)
                                  Positioned(
                                    right: 4 * scale,
                                    bottom: 4 * scale,
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: settingsTeal,
                                      size: 24 * scale,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
