enum CancelRequestStatus {
  requestToCancel(208),
  processCancelFailed(211),
  processCancelSuccess(213),
  selfProcessCancelSuccess(214);

  final int id;

  const CancelRequestStatus(this.id);

  static CancelRequestStatus? fromValue(int value) {
    for (var status in CancelRequestStatus.values) {
      if (status.id == value) return status;
    }
    return null;
  }
}

extension CancelRequestStatusExtension on CancelRequestStatus {
  bool get isSuccess =>
      this == CancelRequestStatus.processCancelSuccess ||
      this == CancelRequestStatus.selfProcessCancelSuccess;

  bool get isFailed => this == CancelRequestStatus.processCancelFailed;

  bool get isRequesting => this == CancelRequestStatus.requestToCancel;
}
