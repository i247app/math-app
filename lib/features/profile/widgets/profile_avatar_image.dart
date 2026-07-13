import 'dart:io';

import 'package:flutter/material.dart';

import 'package:numi/features/profile/presentation/catalog/profile_avatar_catalog.dart';

class ProfileAvatarImage extends StatelessWidget {
  const ProfileAvatarImage({
    super.key,
    required this.size,
    this.avatarKey,
    this.avatarUrl,
    this.avatarPath,
    this.backgroundColor = const Color(0xFFE2EAED),
    this.foregroundColor = const Color(0xFF2A7D75),
    this.borderColor,
    this.borderWidth = 0,
    this.padding = EdgeInsets.zero,
    this.fallbackAsset,
    this.fallbackIcon = Icons.person_rounded,
    this.iconScale = 0.66,
  });

  final double size;
  final String? avatarKey;
  final String? avatarUrl;
  final String? avatarPath;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final String? fallbackAsset;
  final IconData fallbackIcon;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    final localPath = avatarPath?.trim();
    final assetPath = ProfileAvatarCatalog.assetPathForKey(avatarKey);
    final url = _resolvedUrl;

    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor == null || borderWidth <= 0
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipOval(
        child: localPath != null && localPath.isNotEmpty
            ? Image.file(
                File(localPath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _assetNetworkOrFallback(assetPath, url),
              )
            : _assetNetworkOrFallback(assetPath, url),
      ),
    );
  }

  Widget _assetNetworkOrFallback(String? assetPath, String? url) {
    return assetPath != null
        ? Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _networkOrFallback(url),
          )
        : _networkOrFallback(url);
  }

  Widget _networkOrFallback(String? url) {
    return url == null
        ? _fallback()
        : Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallback(),
          );
  }

  String? get _resolvedUrl {
    final explicitUrl = avatarUrl?.trim();
    if (explicitUrl != null && explicitUrl.isNotEmpty) {
      return explicitUrl;
    }

    final catalogUrl = ProfileAvatarCatalog.urlForKey(avatarKey);
    return catalogUrl?.isNotEmpty == true ? catalogUrl : null;
  }

  Widget _fallback() {
    final asset = fallbackAsset?.trim();
    if (asset != null && asset.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.all(size * 0.16),
        child: Image.asset(asset, fit: BoxFit.contain),
      );
    }

    return Icon(fallbackIcon, color: foregroundColor, size: size * iconScale);
  }
}
