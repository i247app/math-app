import 'package:numi/core/data/app_failure.dart';

enum AsyncPhase { idle, loading, ready, failure }

/// Standard state for server-backed data.
///
/// A resource may be [AsyncPhase.failure] and still retain [data]; that lets
/// UI keep showing its last successful content after a refresh failure.
class AsyncResource<T> {
  const AsyncResource({
    required this.phase,
    this.data,
    this.hasData = false,
    this.failure,
    this.updatedAt,
    this.isRefreshing = false,
  });

  const AsyncResource.idle()
    : phase = AsyncPhase.idle,
      data = null,
      hasData = false,
      failure = null,
      updatedAt = null,
      isRefreshing = false;

  factory AsyncResource.loading({T? data, bool hasData = false}) {
    return AsyncResource(
      phase: AsyncPhase.loading,
      data: data,
      hasData: hasData,
    );
  }

  factory AsyncResource.ready(T data, {required DateTime updatedAt}) {
    return AsyncResource(
      phase: AsyncPhase.ready,
      data: data,
      hasData: true,
      updatedAt: updatedAt,
    );
  }

  factory AsyncResource.failed(
    AppFailure failure, {
    T? data,
    bool hasData = false,
  }) {
    return AsyncResource(
      phase: AsyncPhase.failure,
      data: data,
      hasData: hasData,
      failure: failure,
    );
  }

  final AsyncPhase phase;
  final T? data;
  final bool hasData;
  final AppFailure? failure;
  final DateTime? updatedAt;
  final bool isRefreshing;

  bool get isInitialLoading => phase == AsyncPhase.loading && !hasData;

  AsyncResource<T> refreshing() {
    if (!hasData) {
      return AsyncResource.loading();
    }
    return AsyncResource(
      phase: AsyncPhase.ready,
      data: data,
      hasData: true,
      updatedAt: updatedAt,
      isRefreshing: true,
    );
  }
}
