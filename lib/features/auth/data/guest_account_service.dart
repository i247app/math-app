import 'package:numi/features/auth/models/guest_account.dart';

abstract interface class GuestAccountService {
  GuestAccount? get current;

  Future<int?> readStoredUid();

  Future<GuestAccount> ensureGuest();

  Future<void> clear();
}
