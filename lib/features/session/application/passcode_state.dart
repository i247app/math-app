import 'package:numi/features/auth/data/auth_models.dart';

enum PasscodeMode { setup, unlock }

enum PasscodeOutcomeType { sessionReady, resumeAuthentication, cancelled }

class PasscodeOutcome {
  const PasscodeOutcome._({
    required this.type,
    this.user,
    this.loginName,
    this.isNewlyRegistered = false,
  });

  const PasscodeOutcome.sessionReady({
    required LoginUser user,
    required bool isNewlyRegistered,
  }) : this._(
         type: PasscodeOutcomeType.sessionReady,
         user: user,
         isNewlyRegistered: isNewlyRegistered,
       );

  const PasscodeOutcome.resumeAuthentication({
    required LoginUser user,
    required String loginName,
  }) : this._(
         type: PasscodeOutcomeType.resumeAuthentication,
         user: user,
         loginName: loginName,
       );

  const PasscodeOutcome.cancelled()
    : this._(type: PasscodeOutcomeType.cancelled);

  final PasscodeOutcomeType type;
  final LoginUser? user;
  final String? loginName;
  final bool isNewlyRegistered;
}

class PasscodeState {
  const PasscodeState({
    this.mode = PasscodeMode.setup,
    this.user,
    this.loginName,
    this.isNewlyRegistered = false,
    this.canSkip = false,
    this.isBusy = false,
    this.error,
    this.errorId = 0,
    this.isCheckingAvailability = false,
    this.rememberedUser,
    this.rememberedLoginName,
    this.outcome,
    this.outcomeId = 0,
  });

  final PasscodeMode mode;
  final LoginUser? user;
  final String? loginName;
  final bool isNewlyRegistered;
  final bool canSkip;
  final bool isBusy;
  final String? error;
  final int errorId;
  final bool isCheckingAvailability;
  final LoginUser? rememberedUser;
  final String? rememberedLoginName;
  final PasscodeOutcome? outcome;
  final int outcomeId;

  bool get canLoginWithPin =>
      rememberedUser != null && rememberedLoginName != null;

  PasscodeState copyWith({
    PasscodeMode? mode,
    LoginUser? user,
    String? loginName,
    bool? isNewlyRegistered,
    bool? canSkip,
    bool? isBusy,
    String? error,
    int? errorId,
    bool? isCheckingAvailability,
    LoginUser? rememberedUser,
    String? rememberedLoginName,
    PasscodeOutcome? outcome,
    int? outcomeId,
    bool clearPending = false,
    bool clearError = false,
    bool clearRememberedAccount = false,
    bool clearOutcome = false,
  }) {
    return PasscodeState(
      mode: mode ?? this.mode,
      user: clearPending ? null : user ?? this.user,
      loginName: clearPending ? null : loginName ?? this.loginName,
      isNewlyRegistered: clearPending
          ? false
          : isNewlyRegistered ?? this.isNewlyRegistered,
      canSkip: clearPending ? false : canSkip ?? this.canSkip,
      isBusy: clearPending ? false : isBusy ?? this.isBusy,
      error: clearPending || clearError ? null : error ?? this.error,
      errorId: errorId ?? this.errorId,
      isCheckingAvailability:
          isCheckingAvailability ?? this.isCheckingAvailability,
      rememberedUser: clearRememberedAccount
          ? null
          : rememberedUser ?? this.rememberedUser,
      rememberedLoginName: clearRememberedAccount
          ? null
          : rememberedLoginName ?? this.rememberedLoginName,
      outcome: clearOutcome ? null : outcome ?? this.outcome,
      outcomeId: outcomeId ?? this.outcomeId,
    );
  }
}
