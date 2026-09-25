import 'package:numi/features/auth/controllers/auth_state.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_view.dart';

/// Login entry point. The shared view owns only the common presentation.
class LoginScreen extends AuthEntryView {
  const LoginScreen({super.key, required super.bindings})
    : super(mode: AuthEntryMode.login);
}
