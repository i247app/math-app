import 'package:numi/features/profile/presentation/models/profile_avatar_option.dart';

class ProfileAvatarCatalog {
  const ProfileAvatarCatalog._();

  static const options = <ProfileAvatarOption>[
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-92ad1bf7-289a-4efa-836b-863cb4b6e5a8.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-92ad1bf7-289a-4efa-836b-863cb4b6e5a8.png',
      assetPath:
          'assets/avatars/20260530-92ad1bf7-289a-4efa-836b-863cb4b6e5a8.png',
    ),
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-44517641-967a-4ffb-b08f-efb6d6f087d2.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-44517641-967a-4ffb-b08f-efb6d6f087d2.png',
      assetPath:
          'assets/avatars/20260530-44517641-967a-4ffb-b08f-efb6d6f087d2.png',
    ),
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-efdbb9df-d6ec-4ad6-9f61-f0bc1e8ad4dd.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-efdbb9df-d6ec-4ad6-9f61-f0bc1e8ad4dd.png',
      assetPath:
          'assets/avatars/20260530-efdbb9df-d6ec-4ad6-9f61-f0bc1e8ad4dd.png',
    ),
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-b618570e-20ed-41a3-bfbc-53fa7577d47d.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-b618570e-20ed-41a3-bfbc-53fa7577d47d.png',
      assetPath:
          'assets/avatars/20260530-b618570e-20ed-41a3-bfbc-53fa7577d47d.png',
    ),
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-3b3dedb2-f0da-424a-8236-43d332555a35.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-3b3dedb2-f0da-424a-8236-43d332555a35.png',
      assetPath:
          'assets/avatars/20260530-3b3dedb2-f0da-424a-8236-43d332555a35.png',
    ),
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-e08c6d07-6812-4155-be41-d7edec85013b.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-e08c6d07-6812-4155-be41-d7edec85013b.png',
      assetPath:
          'assets/avatars/20260530-e08c6d07-6812-4155-be41-d7edec85013b.png',
    ),
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-b3cdd011-da7c-423c-97d7-c358d9535c69.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-b3cdd011-da7c-423c-97d7-c358d9535c69.png',
      assetPath:
          'assets/avatars/20260530-b3cdd011-da7c-423c-97d7-c358d9535c69.png',
    ),
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-598c7654-c1b1-422d-9857-7d44cb39113e.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-598c7654-c1b1-422d-9857-7d44cb39113e.png',
      assetPath:
          'assets/avatars/20260530-598c7654-c1b1-422d-9857-7d44cb39113e.png',
    ),
    ProfileAvatarOption(
      key: 'profile-avatars/20260530-6fe2364f-2bdf-4eed-ba12-29ffb719ab91.png',
      url:
          'https://numinumi.s3.us-west-2.amazonaws.com/profile-avatars/20260530-6fe2364f-2bdf-4eed-ba12-29ffb719ab91.png',
      assetPath:
          'assets/avatars/20260530-6fe2364f-2bdf-4eed-ba12-29ffb719ab91.png',
    ),
  ];

  static final Map<String, ProfileAvatarOption> _optionsByKey =
      Map.unmodifiable(<String, ProfileAvatarOption>{
        for (final option in options) option.key: option,
      });

  static String? urlForKey(String? key) {
    final normalized = key?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return _optionsByKey[normalized]?.url;
  }

  static String? assetPathForKey(String? key) {
    final normalized = key?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return _optionsByKey[normalized]?.assetPath;
  }
}
