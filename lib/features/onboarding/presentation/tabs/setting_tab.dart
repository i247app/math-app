import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/avatar_picker.dart';
import '../../data/otp_auth_api.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _orange = Color(0xFFDE5E31);

enum _AccountView { settings, account, profile }

class SettingTab extends StatefulWidget {
  const SettingTab({
    super.key,
    required this.user,
    required this.onLogout,
    required this.bottomPadding,
    required this.scale,
  });

  final LoginUser? user;
  final VoidCallback onLogout;
  final double bottomPadding;
  final double scale;

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final AvatarPickerService _avatarPicker = const AvatarPickerService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  _AccountView _view = _AccountView.settings;
  bool _isForwardTransition = true;
  bool _isEditing = false;
  bool _isPickingAccountAvatar = false;
  String? _localAvatarPath;
  String? _draftAvatarPath;
  String? _snapshotUsername;
  String? _snapshotPhone;
  String? _snapshotEmail;
  String? _snapshotAvatarPath;

  @override
  void initState() {
    super.initState();
    _applyUser(widget.user);
  }

  @override
  void didUpdateWidget(covariant SettingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user && !_isEditing) {
      _applyUser(widget.user);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _applyUser(LoginUser? user) {
    _usernameController.text = _fallbackUsername(user);
    _phoneController.text = _displayPhone(user?.phone);
    _emailController.text = user?.email?.trim() ?? '';
  }

  void _openView(_AccountView view) {
    HapticFeedback.selectionClick();
    if (_isEditing) {
      _restoreEditSnapshot();
    }
    setState(() {
      _view = view;
      _isForwardTransition = true;
      _isEditing = false;
      _isPickingAccountAvatar = false;
      _draftAvatarPath = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _returnToSettings() {
    HapticFeedback.selectionClick();
    if (_isEditing) {
      _restoreEditSnapshot();
    }
    setState(() {
      _view = _AccountView.settings;
      _isForwardTransition = false;
      _isEditing = false;
      _isPickingAccountAvatar = false;
      _draftAvatarPath = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _startEditing() {
    HapticFeedback.selectionClick();
    setState(() {
      _snapshotUsername = _usernameController.text;
      _snapshotPhone = _phoneController.text;
      _snapshotEmail = _emailController.text;
      _snapshotAvatarPath = _localAvatarPath;
      _draftAvatarPath = _localAvatarPath;
      _isEditing = true;
    });
  }

  void _saveEditing() {
    HapticFeedback.mediumImpact();
    setState(() {
      _localAvatarPath = _draftAvatarPath;
      _draftAvatarPath = null;
      _isEditing = false;
      _isPickingAccountAvatar = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _cancelEditing() {
    HapticFeedback.selectionClick();
    _restoreEditSnapshot();
    setState(() {
      _draftAvatarPath = null;
      _isEditing = false;
      _isPickingAccountAvatar = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _restoreEditSnapshot() {
    _usernameController.text = _snapshotUsername ?? _usernameController.text;
    _phoneController.text = _snapshotPhone ?? _phoneController.text;
    _emailController.text = _snapshotEmail ?? _emailController.text;
    _localAvatarPath = _snapshotAvatarPath;
  }

  Future<void> _pickAccountAvatar() async {
    if (!_isEditing || _isPickingAccountAvatar) {
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _isPickingAccountAvatar = true);

    try {
      final path = await _avatarPicker.pickAvatarPath();
      if (!mounted) {
        return;
      }

      setState(() {
        if (path != null) {
          _draftAvatarPath = path;
        }
        _isPickingAccountAvatar = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isPickingAccountAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chọn ảnh lúc này.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        26 * scale,
        24 * scale,
        widget.bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AccountTitleRow(
            title: _view == _AccountView.settings
                ? 'Cài đặt'
                : _view == _AccountView.account
                    ? 'Tài khoản'
                    : 'Hồ sơ',
            canGoBack: _view != _AccountView.settings,
            scale: scale,
            onBack: _returnToSettings,
          ),
          SizedBox(height: 24 * scale),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  for (final child in previousChildren) child,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              final isIncoming = child.key == ValueKey(_viewKey(_view));
              final forward = _isForwardTransition;
              final beginX = isIncoming
                  ? (forward ? 0.10 : -0.10)
                  : (forward ? -0.08 : 0.08);
              final offset = Tween<Offset>(
                begin: Offset(beginX, 0),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: switch (_view) {
              _AccountView.settings => _SettingsMenuPanel(
                  key: ValueKey(_viewKey(_AccountView.settings)),
                  avatarUrl: widget.user?.avatarUrl,
                  avatarPath: _localAvatarPath,
                  username: _fallbackUsername(widget.user),
                  scale: scale,
                  onAccountTap: () => _openView(_AccountView.account),
                  onProfileTap: () => _openView(_AccountView.profile),
                  onLogoutTap: widget.onLogout,
                ),
              _AccountView.account => _AccountDetailsPanel(
                  key: ValueKey(_viewKey(_AccountView.account)),
                  avatarUrl: widget.user?.avatarUrl,
                  avatarPath: _isEditing ? _draftAvatarPath : _localAvatarPath,
                  usernameController: _usernameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  isEditing: _isEditing,
                  isPickingAvatar: _isPickingAccountAvatar,
                  onEdit: _startEditing,
                  onSave: _saveEditing,
                  onCancel: _cancelEditing,
                  onAvatarTap: _pickAccountAvatar,
                  scale: scale,
                ),
              _AccountView.profile => _ProfilePlaceholderPanel(
                  key: ValueKey(_viewKey(_AccountView.profile)),
                  scale: scale,
                ),
            },
          ),
        ],
      ),
    );
  }

  static String _fallbackUsername(LoginUser? user) {
    final name = user?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'alex_parent';
  }

  static String _displayPhone(String? value) {
    final phone = value?.trim();
    if (phone == null || phone.isEmpty) {
      return '090 123 4567';
    }

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('84') && digits.length > 2) {
      return _formatLocalPhone('0${digits.substring(2)}');
    }

    return _formatLocalPhone(digits);
  }

  static String _formatLocalPhone(String digits) {
    if (digits.length == 10 && digits.startsWith('0')) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} '
          '${digits.substring(6)}';
    }

    return digits;
  }

  static String _viewKey(_AccountView view) {
    return switch (view) {
      _AccountView.settings => 'settings-menu',
      _AccountView.account => 'account-details',
      _AccountView.profile => 'profile-placeholder',
    };
  }
}

class _AccountTitleRow extends StatelessWidget {
  const _AccountTitleRow({
    required this.title,
    required this.canGoBack,
    required this.scale,
    required this.onBack,
  });

  final String title;
  final bool canGoBack;
  final double scale;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (!canGoBack) {
      return Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _teal,
                fontFamily: 'Nunito',
                fontSize: 24 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: HapticFeedback.selectionClick,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: EdgeInsets.all(2 * scale),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: _teal,
                  size: 28 * scale,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 34 * scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _teal,
                size: 22 * scale,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _teal,
              fontFamily: 'Nunito',
              fontSize: 24 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        SizedBox(
          width: 34 * scale,
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: HapticFeedback.selectionClick,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: EdgeInsets.all(2 * scale),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: _teal,
                    size: 28 * scale,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountEditButton extends StatelessWidget {
  const _AccountEditButton({
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Material(
        color: const Color(0xFFF7FBFD),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10 * scale),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Container(
            width: 42 * scale,
            height: 42 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(color: const Color(0xFFE4A9C7), width: 1.3),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: const Color(0xFFD12788),
              size: 22 * scale,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.borderColor,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color borderColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: CircleBorder(
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: foregroundColor, size: iconSize),
        ),
      ),
    );
  }
}

class _SettingsMenuPanel extends StatelessWidget {
  const _SettingsMenuPanel({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.username,
    required this.scale,
    required this.onAccountTap,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final String username;
  final double scale;
  final VoidCallback onAccountTap;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4 * scale),
        _SettingsAvatar(
          avatarUrl: avatarUrl,
          avatarPath: avatarPath,
          scale: scale,
        ),
        SizedBox(height: 14 * scale),
        Text(
          username,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _deepInk,
            fontFamily: 'Nunito',
            fontSize: 26 * scale,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 34 * scale),
        _SettingsActionCard(
          icon: Icons.account_circle_outlined,
          iconColor: const Color(0xFFC21873),
          iconBackground: const Color(0xFFFFF0F7),
          title: 'Tài Khoản',
          subtitle: 'Quản lý thông tin tài khoản',
          scale: scale,
          onTap: onAccountTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF008A52),
          iconBackground: const Color(0xFFD6FFE3),
          title: 'Hồ Sơ',
          subtitle: 'Xem và chỉnh sửa hồ sơ',
          scale: scale,
          onTap: onProfileTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.logout_rounded,
          iconColor: _orange,
          iconBackground: const Color(0xFFFFD8D8),
          title: 'Logout',
          subtitle: 'Đăng xuất khỏi tài khoản',
          isDestructive: true,
          scale: scale,
          onTap: () {
            HapticFeedback.selectionClick();
            onLogoutTap();
          },
        ),
      ],
    );
  }
}

class _SettingsAvatar extends StatelessWidget {
  const _SettingsAvatar({
    required this.avatarUrl,
    required this.avatarPath,
    required this.scale,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final path = avatarPath?.trim();
    final size = 118 * scale;

    Widget avatarChild;
    if (path != null && path.isNotEmpty) {
      avatarChild = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AccountDefaultAvatar(scale: scale),
      );
    } else if (url != null && url.isNotEmpty) {
      avatarChild = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AccountDefaultAvatar(scale: scale),
      );
    } else {
      avatarChild = Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Image.asset(
          'assets/images/welcome_numi_character.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      width: size + 22 * scale,
      height: size + 22 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(4 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF61AE),
                  width: 4 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF61AE).withValues(alpha: 0.18),
                    blurRadius: 16 * scale,
                    offset: Offset(0, 7 * scale),
                  ),
                ],
              ),
              child: ClipOval(child: avatarChild),
            ),
          ),
          Positioned(
            right: 6 * scale,
            bottom: 16 * scale,
            child: Container(
              width: 26 * scale,
              height: 26 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF55E66E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.scale,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final double scale;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0xFF5E7775).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: Container(
          height: 78 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Row(
            children: [
              Container(
                width: 46 * scale,
                height: 46 * scale,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24 * scale),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDestructive ? _orange : _deepInk,
                        fontFamily: 'Nunito',
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 7 * scale),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF604950),
                        fontFamily: 'Nunito',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFD5A8BA),
                size: 28 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountDetailsPanel extends StatelessWidget {
  const _AccountDetailsPanel({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.usernameController,
    required this.phoneController,
    required this.emailController,
    required this.isEditing,
    required this.isPickingAvatar,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onAvatarTap,
    required this.scale,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool isEditing;
  final bool isPickingAvatar;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onAvatarTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            opacity: isEditing ? 0 : 1,
            duration: const Duration(milliseconds: 160),
            child: _AccountEditButton(
              enabled: !isEditing,
              scale: scale,
              onTap: onEdit,
            ),
          ),
        ),
        SizedBox(height: isEditing ? 4 * scale : 6 * scale),
        _AccountAvatar(
          avatarUrl: avatarUrl,
          avatarPath: avatarPath,
          isEditing: isEditing,
          isPickingAvatar: isPickingAvatar,
          scale: scale,
          onCameraTap: onAvatarTap,
        ),
        SizedBox(height: 8 * scale),
        _AccountTextField(
          label: 'Username',
          controller: usernameController,
          isEditing: isEditing,
          trailing: Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF087A40),
            size: 19 * scale,
          ),
          scale: scale,
        ),
        SizedBox(height: 22 * scale),
        _AccountPhoneField(
          label: 'Số Điện Thoại',
          controller: phoneController,
          isEditing: isEditing,
          scale: scale,
        ),
        SizedBox(height: 22 * scale),
        _AccountTextField(
          label: 'Email',
          controller: emailController,
          isEditing: isEditing,
          keyboardType: TextInputType.emailAddress,
          scale: scale,
        ),
        if (isEditing) ...[
          SizedBox(height: 34 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CancelButton(
                scale: scale,
                onTap: onCancel,
              ),
              SizedBox(width: 14 * scale),
              _SaveButton(
                scale: scale,
                onTap: onSave,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({
    required this.avatarUrl,
    required this.avatarPath,
    required this.isEditing,
    required this.isPickingAvatar,
    required this.scale,
    required this.onCameraTap,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final bool isEditing;
  final bool isPickingAvatar;
  final double scale;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final path = avatarPath?.trim();
    final size = 142 * scale;

    return Center(
      child: SizedBox(
        width: size + 30 * scale,
        height: size + 30 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(6 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF61AE),
                  width: 5 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF61AE).withValues(alpha: 0.20),
                    blurRadius: 18 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFBDE6FF),
                    width: 5 * scale,
                  ),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: path != null && path.isNotEmpty
                      ? Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _AccountDefaultAvatar(scale: scale);
                          },
                        )
                      : url == null || url.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(24 * scale),
                              child: Image.asset(
                                'assets/images/welcome_numi_character.png',
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Padding(
                                  padding: EdgeInsets.all(24 * scale),
                                  child: Image.asset(
                                    'assets/images/welcome_numi_character.png',
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ),
            if (isPickingAvatar)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            if (isEditing)
              Positioned(
                right: 16 * scale,
                bottom: 20 * scale,
                child: _RoundIconButton(
                  icon: Icons.photo_camera_outlined,
                  size: 38 * scale,
                  iconSize: 20 * scale,
                  borderColor: const Color(0xFFC21873),
                  foregroundColor: const Color(0xFF253228),
                  backgroundColor: Colors.white,
                  onTap: onCameraTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AccountDefaultAvatar extends StatelessWidget {
  const _AccountDefaultAvatar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24 * scale),
      child: Image.asset(
        'assets/images/welcome_numi_character.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AccountTextField extends StatelessWidget {
  const _AccountTextField({
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.scale,
    this.trailing,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final double scale;
  final Widget? trailing;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return _AccountFieldShell(
      label: label,
      trailing: trailing,
      scale: scale,
      child: _PlainAccountTextField(
        controller: controller,
        enabled: isEditing,
        keyboardType: keyboardType,
        scale: scale,
      ),
    );
  }
}

class _AccountPhoneField extends StatelessWidget {
  const _AccountPhoneField({
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.scale,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _AccountFieldShell(
      label: label,
      scale: scale,
      child: Row(
        children: [
          Container(
            width: 28 * scale,
            height: 20 * scale,
            decoration: BoxDecoration(
              color: AppColors.vietnamRed,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
            child: Icon(
              Icons.star_rounded,
              color: const Color(0xFFFFE14D),
              size: 13 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            '+84',
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 17 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          Container(
            width: 1 * scale,
            height: 35 * scale,
            margin: EdgeInsets.symmetric(horizontal: 18 * scale),
            color: const Color(0xFFDCE5E3),
          ),
          Expanded(
            child: _PlainAccountTextField(
              controller: controller,
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              scale: scale,
              textStyle: TextStyle(
                color: Colors.black,
                fontFamily: 'Nunito',
                fontSize: 21 * scale,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountFieldShell extends StatelessWidget {
  const _AccountFieldShell({
    required this.label,
    required this.child,
    required this.scale,
    this.trailing,
  });

  final String label;
  final Widget child;
  final double scale;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF604950),
                  fontFamily: 'Nunito',
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        SizedBox(height: 12 * scale),
        Container(
          height: 68 * scale,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF7F9),
            borderRadius: BorderRadius.circular(11 * scale),
            border: Border.all(
              color: const Color(0xFF0D0D0D).withValues(
                alpha: label == 'Số Điện Thoại' ? 0.38 : 0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }
}

class _PlainAccountTextField extends StatelessWidget {
  const _PlainAccountTextField({
    required this.controller,
    required this.enabled,
    required this.scale,
    this.keyboardType,
    this.textStyle,
  });

  final TextEditingController controller;
  final bool enabled;
  final double scale;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        TextStyle(
          color: _deepInk,
          fontFamily: 'Nunito',
          fontSize: 17 * scale,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        );

    return TextField(
      controller: controller,
      readOnly: !enabled,
      enableInteractiveSelection: enabled,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: style,
      decoration: const InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _teal,
      elevation: 9,
      shadowColor: Colors.black.withValues(alpha: 0.30),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 142 * scale,
          height: 60 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lưu',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 10 * scale),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFD995),
      elevation: 0,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 138 * scale,
          height: 60 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                color: const Color(0xFFB74419),
                size: 20 * scale,
              ),
              SizedBox(width: 4 * scale),
              Text(
                'HỦY',
                style: TextStyle(
                  color: const Color(0xFFB74419),
                  fontFamily: 'Nunito',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePlaceholderPanel extends StatelessWidget {
  const _ProfilePlaceholderPanel({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 430 * scale),
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_2_outlined,
            color: _teal,
            size: 54 * scale,
          ),
          SizedBox(height: 18 * scale),
          Text(
            'Hồ sơ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Hồ sơ sẽ được cập nhật sau.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontFamily: 'Nunito',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
