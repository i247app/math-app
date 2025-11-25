enum PlaidLinkFlow { bankLoginAutomatically, manualEntry, verifyAccount, manualInstantMatch }

extension PlaidLinkFlowExtension on PlaidLinkFlow {
  String get value {
    switch (this) {
      case PlaidLinkFlow.bankLoginAutomatically:
        return 'bank_login';
      case PlaidLinkFlow.manualEntry:
        return 'manual_entry';
      case PlaidLinkFlow.verifyAccount:
        return 'verify_account';
      case PlaidLinkFlow.manualInstantMatch:
        return 'manual_instant_match';
    }
  }
}
