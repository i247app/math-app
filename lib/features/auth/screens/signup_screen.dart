import 'package:numi/features/auth/controllers/auth_state.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_view.dart';

/// Signup email entry point, before collecting registration profile details.
class SignupScreen extends AuthEntryView {
  const SignupScreen({super.key, required super.bindings})
    : super(mode: AuthEntryMode.signup);
}
