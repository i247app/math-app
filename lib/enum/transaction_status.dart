enum TransactionStatus {
  unknown(0),
  newEntry(48),
  hold(49),
  voidStatus(86),
  voidPlus(87),
  approved(50),
  cancelRefund(158),
  approveXInfo(120),
  paid(51),
  paidXInfo(123),
  cancelAfterPaid(102),
  block(88),
  holdBySender(215),
  refund(52),
  gPaid(124),
  pending(126),
  gVoid(125),
  gDue(89),
  kycNotValid(216);

  const TransactionStatus(this.value);

  final int value;

  static TransactionStatus fromValue(int value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TransactionStatus.newEntry,
    );
  }
}

extension TransactionStatusCancelable on TransactionStatus {
  bool get isCancelable {
    switch (this) {
      case TransactionStatus.hold:
      case TransactionStatus.approved:
      case TransactionStatus.approveXInfo:
      case TransactionStatus.newEntry:
      case TransactionStatus.holdBySender:
      case TransactionStatus.paid:
      case TransactionStatus.paidXInfo:
      case TransactionStatus.unknown:
        return true;
      default:
        return false;
    }
  }
}

extension TransactionStatusRequestCancelable on TransactionStatus {
  bool get isRequestCancelable {
    switch (this) {
      case TransactionStatus.hold:
      case TransactionStatus.approved:
      case TransactionStatus.approveXInfo:
        return true;
      default:
        return false;
    }
  }
}

extension TransactionStatusUpdatable on TransactionStatus {
  bool get isUpdatable {
    switch (this) {
      case TransactionStatus.newEntry:
      
      case TransactionStatus.unknown:
      case TransactionStatus.kycNotValid:
        return true;
      default:
        return false;
    }
  }
}

extension TransactionStatusVoidable on TransactionStatus {
  bool get isVoidable {
    switch (this) {
      case TransactionStatus.voidStatus:
        return true;
      default:
        return false;
    }
  }
}
