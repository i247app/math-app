part of '../setting_tab.dart';

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
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(color: _teal, width: 1.2),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: _teal,
              size: 19 * scale,
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

class _AccountDetailsPanel extends StatelessWidget {
  const _AccountDetailsPanel({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.usernameController,
    required this.phoneController,
    required this.emailController,
    required this.isEditing,
    required this.isSaving,
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
  final bool isSaving;
  final bool isPickingAvatar;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onAvatarTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final fieldGap = 20 * scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isEditing) ...[
          Align(
            alignment: Alignment.centerRight,
            child: _AccountEditButton(
              enabled: true,
              scale: scale,
              onTap: onEdit,
            ),
          ),
          SizedBox(height: 10 * scale),
        ],
        _AccountAvatar(
          avatarUrl: avatarUrl,
          avatarPath: avatarPath,
          isEditing: isEditing,
          isPickingAvatar: isPickingAvatar,
          scale: scale,
          onCameraTap: onAvatarTap,
        ),
        SizedBox(height: 4 * scale),
        _AccountTextField(
          label: context.getText(AppKeys.username),
          controller: usernameController,
          isEditing: isEditing,
          trailing: Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF087A40),
            size: 19 * scale,
          ),
          scale: scale,
        ),
        SizedBox(height: fieldGap),
        _AccountPhoneField(
          label: context.getText(AppKeys.phoneNumber),
          controller: phoneController,
          isEditing: isEditing,
          scale: scale,
        ),
        SizedBox(height: fieldGap),
        _AccountTextField(
          label: context.getText(AppKeys.email),
          controller: emailController,
          isEditing: isEditing,
          keyboardType: TextInputType.emailAddress,
          scale: scale,
        ),
        if (isEditing) ...[
          SizedBox(height: 22 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CancelButton(
                scale: scale,
                onTap: isSaving ? () {} : onCancel,
              ),
              SizedBox(width: 14 * scale),
              Opacity(
                opacity: isSaving ? 0.72 : 1,
                child: _SaveButton(
                  scale: scale,
                  onTap: isSaving ? () {} : onSave,
                ),
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
    final size = 126 * scale;

    return Center(
      child: SizedBox(
        width: size + 30 * scale,
        height: size + 30 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8601C).withValues(alpha: 0.16),
                    blurRadius: 14 * scale,
                    offset: Offset(0, 5 * scale),
                  ),
                ],
              ),
              child: ProfileAvatarImage(
                size: size,
                avatarPath: avatarPath,
                avatarUrl: avatarUrl,
                borderColor: const Color(0xFFFF7451),
                borderWidth: 3.8 * scale,
                padding: EdgeInsets.all(6 * scale),
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
            style: GoogleFonts.andika(
              color: _deepInk,
              fontSize: FontSize.large * scale,
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
              textStyle: GoogleFonts.andika(
                color: Colors.black,
                fontSize: FontSize.title * scale,
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
                style: GoogleFonts.andika(
                  color: const Color(0xFF604950),
                  fontSize: FontSize.normal * scale,
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
          height: 60 * scale,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: const Color(0xFFCFCFCF),
              width: 1.2 * scale,
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
        GoogleFonts.andika(
          color: _deepInk,
          fontSize: FontSize.large * scale,
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
    this.enabled = true,
  });

  final double scale;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = enabled ? _teal : const Color(0xFFBFC9CA);
    final foregroundColor = enabled ? Colors.white : const Color(0xFFF4F6F6);

    return Material(
      color: backgroundColor,
      elevation: enabled ? 9 : 0,
      shadowColor: Colors.black.withValues(alpha: enabled ? 0.30 : 0),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 142 * scale,
          height: 60 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.getText(AppKeys.save),
                style: GoogleFonts.andika(
                  color: foregroundColor,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 10 * scale),
              Icon(
                Icons.arrow_forward_rounded,
                color: foregroundColor,
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
                context.getText(AppKeys.cancel).toUpperCase(),
                style: GoogleFonts.andika(
                  color: const Color(0xFFB74419),
                  fontSize: FontSize.normal * scale,
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
