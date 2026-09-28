/// Only mstatus and the OTP flag matching the identifier control signup.
class IdentifierAvailability {
  const IdentifierAvailability({
    required this.mstatus,
    required this.otpEnabled,
  });

  final int mstatus;
  final bool? otpEnabled;

  static IdentifierAvailability? fromResponse(
    Object? response,
    String identifier,
  ) {
    if (response is! Map || response['mstatus'] is! int) return null;
    final status = response['mstatus'] as int;
    if (status != 200) {
      return IdentifierAvailability(mstatus: status, otpEnabled: null);
    }

    final otpEnabled =
        response[identifier.contains('@')
            ? 'email_otp_enable'
            : 'phone_otp_enable'];
    if (otpEnabled is! bool) return null;
    return IdentifierAvailability(mstatus: status, otpEnabled: otpEnabled);
  }
}
