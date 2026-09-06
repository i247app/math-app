import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/session/controllers/passcode_state.dart';
import 'package:numi/features/session/data/passcode_service.dart';

class PasscodeCubit extends Cubit<PasscodeState> {
  PasscodeCubit({required PasscodeService passcodeService})
    : _passcodeService = passcodeService,
      super(const PasscodeState());

  final PasscodeService _passcodeService;

  Future<void> checkLoginAvailability() async {
    if (state.isCheckingAvailability) {
      return;
    }
    emit(
      state.copyWith(
        isCheckingAvailability: true,
        clearRememberedAccount: true,
        clearError: true,
      ),
    );
    try {
      final account = await _passcodeService.lastPasscodeAccount();
      if (isClosed) {
        return;
      }
      if (account == null) {
        emit(
          state.copyWith(
            isCheckingAvailability: false,
            clearRememberedAccount: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          isCheckingAvailability: false,
          rememberedUser: _userForAccount(account),
          rememberedLoginName: account.loginName,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isCheckingAvailability: false,
            clearRememberedAccount: true,
          ),
        );
      }
    }
  }

  Future<bool> openRememberedUnlock() async {
    await checkLoginAvailability();
    if (isClosed || !state.canLoginWithPin) {
      return false;
    }
    openPinLogin();
    return true;
  }

  void openPinLogin() {
    final user = state.rememberedUser;
    final loginName = state.rememberedLoginName;
    if (user == null || loginName == null) {
      return;
    }
    emit(
      state.copyWith(
        mode: PasscodeMode.unlock,
        user: user,
        loginName: loginName,
        canSkip: false,
        isBusy: false,
        isNewlyRegistered: false,
        clearError: true,
        clearOutcome: true,
      ),
    );
  }

  Future<bool> prepareAfterAuthentication({
    required LoginUser user,
    required String? loginName,
    required bool isNewlyRegistered,
  }) async {
    await _rememberAccount(user, loginName);
    var hasPasscode = false;
    try {
      hasPasscode = await _passcodeService.hasPasscode(user.id);
    } catch (_) {
      // Fall back to setup; the setup screen can surface storage failures.
    }
    if (isClosed) {
      return false;
    }
    if (hasPasscode) {
      _emitOutcome(
        PasscodeOutcome.sessionReady(
          user: user,
          isNewlyRegistered: isNewlyRegistered,
        ),
      );
      return false;
    }
    emit(
      state.copyWith(
        mode: PasscodeMode.setup,
        user: user,
        loginName: loginName,
        isNewlyRegistered: isNewlyRegistered,
        canSkip: true,
        isBusy: false,
        clearError: true,
        clearOutcome: true,
      ),
    );
    return true;
  }

  Future<void> submit(String passcode) async {
    final user = state.user;
    if (state.isBusy || user == null) {
      return;
    }
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      switch (state.mode) {
        case PasscodeMode.setup:
          await _passcodeService.setPasscode(
            userId: user.id,
            passcode: passcode,
          );
          if (!isClosed) {
            _emitOutcome(
              PasscodeOutcome.sessionReady(
                user: user,
                isNewlyRegistered: state.isNewlyRegistered,
              ),
            );
          }
        case PasscodeMode.unlock:
          if (!await _passcodeService.hasPasscode(user.id)) {
            cancel();
            await checkLoginAvailability();
            return;
          }
          final isValid = await _passcodeService.verifyPasscode(
            userId: user.id,
            passcode: passcode,
          );
          if (isClosed) {
            return;
          }
          if (!isValid) {
            emit(
              state.copyWith(
                isBusy: false,
                error: AppStrings.current(AppKeys.passcodeIncorrect),
                errorId: state.errorId + 1,
              ),
            );
            return;
          }
          final loginName = state.loginName;
          if (loginName == null || loginName.isEmpty) {
            cancel();
            return;
          }
          _emitOutcome(
            PasscodeOutcome.resumeAuthentication(
              user: user,
              loginName: loginName,
            ),
          );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isBusy: false,
            error: AppStrings.current(AppKeys.passcodeSaveFailed),
            errorId: state.errorId + 1,
          ),
        );
      }
    }
  }

  void skipSetup() {
    final user = state.user;
    if (state.mode != PasscodeMode.setup || !state.canSkip || user == null) {
      return;
    }
    _emitOutcome(
      PasscodeOutcome.sessionReady(
        user: user,
        isNewlyRegistered: state.isNewlyRegistered,
      ),
    );
  }

  void cancel() {
    emit(
      state.copyWith(
        clearPending: true,
        outcome: const PasscodeOutcome.cancelled(),
        outcomeId: state.outcomeId + 1,
      ),
    );
  }

  void consumeOutcome() =>
      emit(state.copyWith(clearPending: true, clearOutcome: true));

  void _emitOutcome(PasscodeOutcome outcome) {
    emit(
      state.copyWith(
        isBusy: false,
        clearError: true,
        outcome: outcome,
        outcomeId: state.outcomeId + 1,
      ),
    );
  }

  Future<void> _rememberAccount(LoginUser user, String? loginName) async {
    final normalized = loginName?.trim();
    final fallbackPhone = user.phone?.trim();
    final fallbackEmail = user.email?.trim();
    final resolved = normalized != null && normalized.isNotEmpty
        ? normalized
        : fallbackPhone != null && fallbackPhone.isNotEmpty
        ? fallbackPhone
        : fallbackEmail;
    if (user.id <= 0 || resolved == null || resolved.isEmpty) {
      return;
    }
    try {
      await _passcodeService.rememberLoginAccount(
        userId: user.id,
        loginName: resolved,
      );
    } catch (_) {
      // Remembered PIN login is optional and must not block authentication.
    }
  }

  static LoginUser _userForAccount(PasscodeLoginAccount account) {
    final isEmail = account.loginName.contains('@');
    return LoginUser(
      id: account.userId,
      email: isEmail ? account.loginName : null,
      phone: isEmail ? null : account.loginName,
    );
  }
}
