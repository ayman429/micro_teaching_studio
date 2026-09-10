import 'dart:async';
import 'dart:developer';

import 'package:micro_teaching_studio/features/analytics/data/analytics_repository.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_state.dart';
import 'package:micro_teaching_studio/features/home/data/course_progress_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseProgressCubit extends Cubit<CourseProgressState> {
  CourseProgressCubit(this._store, this._analytics)
      : super(const CourseProgressState()) {
    reload();
  }

  final CourseProgressStore _store;
  final AnalyticsRepository _analytics;

  void reload() {
    _analytics.resetCache();
    emit(CourseProgressState(completedIds: _store.load()));
    unawaited(_hydrateFromCloud());
  }

  Future<void> ensureHydrated() => _hydrateFromCloud();

  bool get isHydrated => _analytics.isHydrated;

  Future<void> completePart(String id) async {
    if (state.completedIds.contains(id)) return;
    final next = {...state.completedIds, id};
    emit(CourseProgressState(completedIds: next));
    await _store.save(next);
    try {
      await _analytics.markCompleted(id, completedIds: next);
    } catch (error, stack) {
      log('progress complete: $error', stackTrace: stack);
    }
  }

  Future<void> _hydrateFromCloud() async {
    try {
      await _analytics.hydrate();
      final remote = _analytics.cachedCompletedIds;
      final local = state.completedIds;
      final merged = {...local, ...remote};
      if (merged.length != local.length || !local.containsAll(remote)) {
        emit(CourseProgressState(completedIds: merged));
        await _store.save(merged);
      }
      for (final id in local.difference(remote)) {
        unawaited(
          _analytics
              .markCompleted(id, completedIds: merged)
              .onError((error, stack) {
            log('progress backfill: $error', stackTrace: stack);
          }),
        );
      }
    } catch (error, stack) {
      log('progress hydrate: $error', stackTrace: stack);
    }
  }
}
