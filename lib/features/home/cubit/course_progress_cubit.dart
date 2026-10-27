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
    emit(
      CourseProgressState(
        completedIds: _store.load(),
        finishedSessions: _store.loadNamed('finished'),
        restudiedSessions: _store.loadNamed('restudy'),
        pointIds: _store.loadNamed('points'),
      ),
    );
    unawaited(_hydrateFromCloud());
  }

  Future<void> ensureHydrated() => _hydrateFromCloud();

  bool get isHydrated => _analytics.isHydrated;

  Future<void> completePart(String id) async {
    if (state.completedIds.contains(id)) return;
    final next = {...state.completedIds, id};
    emit(state.copyWith(completedIds: next));
    await _store.save(next);
    try {
      await _analytics.markCompleted(id, completedIds: next);
    } catch (error, stack) {
      log('progress complete: $error', stackTrace: stack);
    }
  }

  void finishSession(int module, int session) {
    final key = '$module-$session';
    if (state.finishedSessions.contains(key)) return;
    final next = {...state.finishedSessions, key};
    emit(state.copyWith(finishedSessions: next));
    unawaited(_store.saveNamed('finished', next));
  }

  Future<void> markRestudied(int module, int session) async {
    final key = '$module-$session';
    if (state.restudiedSessions.contains(key)) return;
    final next = {...state.restudiedSessions, key};
    emit(state.copyWith(restudiedSessions: next));
    await _store.saveNamed('restudy', next);
  }

  Future<void> awardPoint(String id) async {
    if (id.isEmpty || state.pointIds.contains(id)) return;
    final next = {...state.pointIds, id};
    emit(state.copyWith(pointIds: next));
    await _store.saveNamed('points', next);
    try {
      await _analytics.saveTaskPoints(next);
    } catch (error, stack) {
      log('task point: $error', stackTrace: stack);
    }
  }

  Future<void> _hydrateFromCloud() async {
    try {
      await _analytics.hydrate();
      final remote = _analytics.cachedCompletedIds;
      final local = state.completedIds;
      final merged = {...local, ...remote};
      if (merged.length != local.length || !local.containsAll(remote)) {
        emit(state.copyWith(completedIds: merged));
        await _store.save(merged);
      }
      final remotePoints = _analytics.cachedTaskPointIds;
      if (remotePoints.isNotEmpty) {
        final points = {...state.pointIds, ...remotePoints};
        if (points.length != state.pointIds.length) {
          emit(state.copyWith(pointIds: points));
          await _store.saveNamed('points', points);
        }
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
