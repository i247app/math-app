import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_logger.dart';

/// Emits concise Cubit/Bloc lifecycle diagnostics in debug builds.
///
/// States can contain profile and authentication data, so this deliberately
/// reports state types rather than serializing state values.
class AppDebugBlocObserver extends BlocObserver {
  const AppDebugBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    AppLogger.debug(
      'BLOC',
      '${bloc.runtimeType}: '
          '${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
    );
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(
      'BLOC',
      '${bloc.runtimeType} failed',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
