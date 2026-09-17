part of '../setting_tab.dart';

extension _SettingNavigationActions on _SettingTabState {
  int? get _effectiveUserId {
    final userId = widget.user?.id;
    return userId != null && userId > 0 ? userId : null;
  }

  void _onPasscodeChanged() {
    if (mounted) {
      _updateState(() {});
    }
  }

  void _schedulePasscodeStatusLoad() {
    if (_isPasscodeStatusLoadScheduled) {
      return;
    }

    _isPasscodeStatusLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPasscodeStatusLoadScheduled = false;
      if (!mounted || !widget.isActive) {
        return;
      }
      _passcodeController.load(_effectiveUserId);
    });
  }

  Future<void> _performPushView(
    SettingPageView view, {
    StudentProfile? editingProfile,
    bool openAddProfileOnStart = false,
  }) async {
    if (view != SettingPageView.account) {
      HapticFeedback.selectionClick();
    }
    FocusScope.of(context).unfocus();

    final screen = _settingScreenForView(
      view,
      editingProfile,
      openAddProfileOnStart: openAddProfileOnStart,
    );
    final route =
        view == SettingPageView.account || view == SettingPageView.profile
        ? CupertinoPageRoute<bool>(builder: (_) => screen)
        : MaterialPageRoute<bool>(builder: (_) => screen);
    final didSave = await Navigator.of(context).push<bool>(route);

    if (!mounted) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await _loadProfiles();
    if (didSave == true) {
      widget.onProfileSaved?.call();
    }
  }

  Widget _settingScreenForView(
    SettingPageView view,
    StudentProfile? editingProfile, {
    bool openAddProfileOnStart = false,
  }) {
    final args = SettingScreenArgs(
      user: widget.user,
      profiles: _profiles,
      activeProfile: widget.activeProfile,
      profileLoadError: _profileLoadError,
      onLogout: widget.onLogout,
      onActivateProfile: widget.onActivateProfile,
      onRefreshProfiles: widget.onRefreshProfiles,
      onProfileSaved: widget.onProfileSaved,
      scale: widget.scale,
    );

    return switch (view) {
      SettingPageView.account => SettingAccountScreen(args: args),
      SettingPageView.profile => SettingSafeScreen(
        child: SettingTab.page(
          user: args.user,
          profiles: args.profiles,
          activeProfile: args.activeProfile,
          profileLoadError: args.profileLoadError,
          onLogout: args.onLogout,
          onActivateProfile: args.onActivateProfile,
          onRefreshProfiles: args.onRefreshProfiles,
          onProfileSaved: args.onProfileSaved,
          bottomPadding: 0,
          scale: args.scale,
          initialView: SettingPageView.profile,
          isPushedPage: true,
          openAddProfileOnStart: openAddProfileOnStart,
        ),
      ),
      SettingPageView.addProfile => SettingSafeScreen(
        child: SettingTab.page(
          user: args.user,
          profiles: args.profiles,
          activeProfile: args.activeProfile,
          profileLoadError: args.profileLoadError,
          onLogout: args.onLogout,
          onActivateProfile: args.onActivateProfile,
          onRefreshProfiles: args.onRefreshProfiles,
          onProfileSaved: () => Navigator.of(context).pop(true),
          bottomPadding: 0,
          scale: args.scale,
          initialView: SettingPageView.addProfile,
          initialEditingProfile: editingProfile,
          isPushedPage: true,
        ),
      ),
      SettingPageView.settings => SettingSafeScreen(
        child: SettingTab.page(
          user: args.user,
          profiles: args.profiles,
          activeProfile: args.activeProfile,
          profileLoadError: args.profileLoadError,
          onLogout: args.onLogout,
          onActivateProfile: args.onActivateProfile,
          onRefreshProfiles: args.onRefreshProfiles,
          onProfileSaved: args.onProfileSaved,
          bottomPadding: 0,
          scale: args.scale,
          initialView: SettingPageView.profile,
          isPushedPage: true,
        ),
      ),
    };
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    HapticFeedback.selectionClick();
    if (_isChangingLanguage) {
      return;
    }

    final lingo = LingoScope.read(context);
    if (lingo.language == language) {
      return;
    }

    _updateState(() => _isChangingLanguage = true);
    try {
      await _runWithDeferredLoading(
        action: () => lingo.setLanguage(language),
        show: () =>
            _showFullScreenLoading(context.getText(AppKeys.switchingLanguage)),
        hide: _hideFullScreenLoading,
      );
      if (mounted) {
        _updateState(() => _isChangingLanguage = false);
      }
    } catch (_) {
      if (mounted) {
        _updateState(() => _isChangingLanguage = false);
      }
    }
  }

  Future<T> _runWithDeferredLoading<T>({
    required Future<T> Function() action,
    required VoidCallback show,
    required VoidCallback hide,
  }) async {
    var completed = false;
    var visible = false;
    Future<void>.delayed(settingsLoadingDelay, () {
      if (completed || !mounted) {
        return;
      }
      visible = true;
      show();
    });

    try {
      return await action();
    } finally {
      completed = true;
      if (visible && mounted) {
        hide();
      }
    }
  }

  void _showFullScreenLoading(String message) {
    showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.white,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) {
        return PopScope(canPop: false, child: LoadingScreen(message: message));
      },
    );
  }

  void _hideFullScreenLoading() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _returnToSettings() {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget._isPushedPage) {
      Navigator.of(context).maybePop();
    }
  }
}
