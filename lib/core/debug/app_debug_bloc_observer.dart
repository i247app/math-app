import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Emits concise Cubit/Bloc lifecycle diagnostics in debug builds.
///
/// States can contain profile and authentication data, so this deliberately
/// reports state types rather than serializing state values.
class AppDebugBlocObserver extends BlocObserver {
  const AppDebugBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    debugPrint(
      '[Bloc] ${bloc.runtimeType}: '
      '${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
    );
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('[Bloc] ${bloc.runtimeType} error: $error');
    super.onError(bloc, error, stackTrace);
  }
}
