enum VCBStatus {
  init('INIT'),
  pendingKyc('PENDING_KYC'),
  pendingCore('PENDING_CORE'),
  core('CORE'),
  pendingCancel('PENDING_CANCEL'),
  cancelled('CANCELLED'),
  declined('DECLINED');

  const VCBStatus(this.value);

  final String value;

  static VCBStatus fromString(String value) {
    return VCBStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VCBStatus.init,
    );
  }

  bool get isCompleted => this == VCBStatus.core;

  bool get isFailed => this == VCBStatus.declined;

  bool get isCancelled => this == VCBStatus.cancelled;

  bool get isPendingKYC => this == VCBStatus.pendingKyc;

  bool get isInitial => this == VCBStatus.init;

  bool get isPendingCancel => this == VCBStatus.pendingCancel;

  bool get isDeclined => this == VCBStatus.declined;

  bool get isPendingCore => this == VCBStatus.pendingCore;

  bool get isCore => this == VCBStatus.core;

  bool get hasAction => isInitial || isPendingKYC || isPendingCore || isCore;
}
