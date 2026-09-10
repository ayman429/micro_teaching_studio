import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/analytics/models/feedback_tier.dart';
import 'package:micro_teaching_studio/features/analytics/models/stored_part_state.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._firestore, this._prefs, this._auth);

  final FirebaseFirestore _firestore;
  final AppPreferences _prefs;
  final FirebaseAuth _auth;

  String get _uid {
    final authUid = _auth.currentUser?.uid.trim() ?? '';
    if (authUid.isNotEmpty) return authUid;
    return _prefs.getUid().trim();
  }

  CollectionReference<Map<String, dynamic>> get _userProgress =>
      _firestore.collection(AnalyticsConstants.userProgressCollection);

  CollectionReference<Map<String, dynamic>> get _partProgress =>
      _firestore.collection(AnalyticsConstants.partProgressCollection);

  CollectionReference<Map<String, dynamic>> get _attempts =>
      _firestore.collection(AnalyticsConstants.attemptsCollection);

  CollectionReference<Map<String, dynamic>> get _attemptWords =>
      _firestore.collection(AnalyticsConstants.attemptWordsCollection);

  CollectionReference<Map<String, dynamic>> get _attemptPhonemes =>
      _firestore.collection(AnalyticsConstants.attemptPhonemesCollection);

  var _hydrated = false;
  Future<void>? _hydrateInFlight;
  final Map<String, StoredPartState> _parts = {};
  final Map<String, Map<String, dynamic>> _partDocs = {};
  final Set<String> _completedIds = {};

  bool get isHydrated => _hydrated;

  Set<String> get cachedCompletedIds => Set<String>.from(_completedIds);

  StoredPartState peekStoredState(String partId) {
    return _parts[partId] ??
        const StoredPartState(attemptCount: 0, locked: false);
  }

  void resetCache() {
    _hydrated = false;
    _hydrateInFlight = null;
    _parts.clear();
    _partDocs.clear();
    _completedIds.clear();
  }

  Future<void> hydrate() {
    if (_hydrated) return Future.value();
    return _hydrateInFlight ??= _hydrateOnce().whenComplete(() {
      _hydrateInFlight = null;
    });
  }

  Future<void> _hydrateOnce() async {
    final uid = _uid;
    if (uid.isEmpty) {
      _hydrated = true;
      return;
    }
    try {
      final results = await Future.wait([
        _partProgress
            .where('uid', isEqualTo: uid)
            .get()
            .timeout(AnalyticsConstants.writeTimeout),
        _attempts
            .where('uid', isEqualTo: uid)
            .get()
            .timeout(AnalyticsConstants.writeTimeout),
        _attemptWords
            .where('uid', isEqualTo: uid)
            .get()
            .timeout(AnalyticsConstants.writeTimeout),
        _attemptPhonemes
            .where('uid', isEqualTo: uid)
            .get()
            .timeout(AnalyticsConstants.writeTimeout),
      ]);
      final partSnap = results[0];
      final attemptSnap = results[1];
      final wordSnap = results[2];
      final phonemeSnap = results[3];

      final attemptsById = <String, Map<String, dynamic>>{};
      for (final doc in attemptSnap.docs) {
        attemptsById[doc.id] = doc.data();
      }
      final wordsByAttempt =
          <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
      for (final doc in wordSnap.docs) {
        final attemptId = (doc.data()['attemptId'] as String?)?.trim() ?? '';
        if (attemptId.isEmpty) continue;
        wordsByAttempt.putIfAbsent(attemptId, () => []).add(doc);
      }
      final phonemesByAttempt =
          <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
      for (final doc in phonemeSnap.docs) {
        final attemptId = (doc.data()['attemptId'] as String?)?.trim() ?? '';
        if (attemptId.isEmpty) continue;
        phonemesByAttempt.putIfAbsent(attemptId, () => []).add(doc);
      }

      _parts.clear();
      _partDocs.clear();
      _completedIds.clear();
      for (final doc in partSnap.docs) {
        final data = doc.data();
        final partId = (data['partId'] as String?)?.trim() ?? '';
        if (partId.isEmpty) continue;
        _partDocs[partId] = data;
        final attemptId = (data['latestAttemptId'] as String?)?.trim() ?? '';
        final attemptData = attemptId.isEmpty ? null : attemptsById[attemptId];
        final result = attemptData == null
            ? null
            : _resultFrom(
                attemptData,
                wordsByAttempt[attemptId] ?? const [],
                phonemesByAttempt[attemptId] ?? const [],
              );
        _parts[partId] = _storedFromPart(data, result);
        if (_parts[partId]!.locked) _completedIds.add(partId);
      }
      _hydrated = true;
    } catch (error, stack) {
      log('analytics hydrate: $error', stackTrace: stack);
      _hydrated = false;
      rethrow;
    }
  }

  Future<Set<String>> loadCompletedPartIds() async {
    await hydrate();
    return cachedCompletedIds;
  }

  Future<StoredPartState> loadStoredState(String partId) async {
    await hydrate();
    return peekStoredState(partId);
  }

  Future<Map<String, dynamic>?> _readPartProgress(
    String uid,
    String partId,
  ) async {
    final cached = _partDocs[partId];
    if (cached != null) return cached;
    try {
      final snapshot = await _partProgress
          .doc(_partDocId(uid, partId))
          .get()
          .timeout(AnalyticsConstants.writeTimeout);
      final data = snapshot.data();
      if (data != null) _partDocs[partId] = data;
      return data;
    } on FirebaseException catch (error, stack) {
      log('analytics read part: ${error.code} $error', stackTrace: stack);
      return null;
    }
  }

  void _rememberPart({
    required String partId,
    required Map<String, dynamic> data,
    PronunciationResult? result,
  }) {
    final stored = _storedFromPart(data, result);
    _partDocs[partId] = Map<String, dynamic>.from(data);
    _parts[partId] = stored;
    if (stored.locked) {
      _completedIds.add(partId);
    }
  }

  StoredPartState _storedFromPart(
    Map<String, dynamic> data,
    PronunciationResult? result,
  ) {
    final attemptCount = (data['attemptCount'] as num?)?.toInt() ?? 0;
    final status = data['status'] as String? ?? '';
    final latestBand = data['latestBand'] as String? ?? '';
    final locked = status == AnalyticsConstants.statusCompleted ||
        data['locked'] == true ||
        latestBand == AnalyticsConstants.bandExcellent ||
        attemptCount >= PronunciationConstants.maxAttempts;
    return StoredPartState(
      attemptCount: attemptCount,
      locked: locked,
      result: result,
    );
  }

  PronunciationResult? _resultFrom(
    Map<String, dynamic> data,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> wordSnap,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> phonemeSnap,
  ) {
    final phonemesByWord =
        <int, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
    for (final doc in phonemeSnap) {
      final index = (doc.data()['wordIndex'] as num?)?.toInt() ?? 0;
      phonemesByWord.putIfAbsent(index, () => []).add(doc);
    }
    final wordDocs = [...wordSnap]..sort((a, b) {
        final left = (a.data()['wordIndex'] as num?)?.toInt() ?? 0;
        final right = (b.data()['wordIndex'] as num?)?.toInt() ?? 0;
        return left.compareTo(right);
      });
    final words = wordDocs.map((doc) {
      final map = doc.data();
      final wordIndex = (map['wordIndex'] as num?)?.toInt() ?? 0;
      final phonemeDocs = [...(phonemesByWord[wordIndex] ?? [])]..sort((a, b) {
          final left = (a.data()['phonemeIndex'] as num?)?.toInt() ?? 0;
          final right = (b.data()['phonemeIndex'] as num?)?.toInt() ?? 0;
          return left.compareTo(right);
        });
      return PronunciationWordScore(
        word: map['expectedWord'] as String? ?? '',
        accuracy: _asDouble(map['accuracy']),
        errorType: map['errorType'] as String? ?? 'None',
        phonemes: phonemeDocs.map((phonemeDoc) {
          final phoneme = phonemeDoc.data();
          return PronunciationPhonemeScore(
            phoneme: phoneme['expectedPhoneme'] as String? ?? '',
            accuracy: _asDouble(phoneme['accuracy']),
            heardPhoneme: _emptyToNull(phoneme['heardPhoneme'] as String?),
            nBest: _nBestFromMap(phoneme),
          );
        }).toList(),
      );
    }).toList();
    return PronunciationResult(
      raw: const {},
      pronScore: _asDouble(data['pronScore']),
      accuracyScore: _asDouble(data['accuracyScore']),
      fluencyScore: _asDouble(data['fluencyScore']),
      completenessScore: _asDouble(data['completenessScore']),
      prosodyScore: _asDouble(data['prosodyScore']),
      words: words,
      band: PronunciationResult.bandFromName(data['band'] as String?),
      heardText: _emptyToNull(data['heardText'] as String?),
      recognitionStatus: _emptyToNull(data['recognitionStatus'] as String?),
      httpStatus: (data['httpStatus'] as num?)?.toInt() ?? 200,
      weakestWord: _emptyToNull(data['weakestWord'] as String?),
      weakestPhoneme: _emptyToNull(data['weakestPhoneme'] as String?),
      heardPhoneme: _emptyToNull(data['heardPhoneme'] as String?),
    );
  }

  List<PronunciationPhonemeCandidate> _nBestFromMap(Map<String, dynamic> map) {
    final candidates = <PronunciationPhonemeCandidate>[];
    for (var i = 1; i <= 3; i++) {
      final phoneme = (map['nBest$i'] as String?)?.trim() ?? '';
      if (phoneme.isEmpty) continue;
      candidates.add(
        PronunciationPhonemeCandidate(
          phoneme: phoneme,
          accuracy: _asDouble(map['nBest${i}Score']),
        ),
      );
    }
    return candidates;
  }

  String? _emptyToNull(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  Future<void> recordScoredAttempt({
    required AssessmentPartContext part,
    required PronunciationResult result,
    required int attemptNumber,
    required String twinTip,
    required DateTime startedAt,
    required DateTime endedAt,
    required String language,
    required String region,
  }) {
    return _record(
      part: part,
      attemptNumber: attemptNumber,
      startedAt: startedAt,
      endedAt: endedAt,
      language: language,
      region: region,
      outcome: AnalyticsConstants.outcomeScored,
      result: result,
      twinTip: twinTip,
    );
  }

  Future<void> recordFailedAttempt({
    required AssessmentPartContext part,
    required int attemptNumber,
    required DateTime startedAt,
    required DateTime endedAt,
    required String errorMessage,
    String language = PronunciationConstants.defaultLanguage,
    String region = PronunciationConstants.defaultRegion,
  }) {
    return _record(
      part: part,
      attemptNumber: attemptNumber,
      startedAt: startedAt,
      endedAt: endedAt,
      language: language,
      region: region,
      outcome: AnalyticsConstants.outcomeFailed,
      errorMessage: errorMessage,
    );
  }

  Future<void> markCompleted(
    String partId, {
    required Set<String> completedIds,
  }) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final part = AssessmentPartContext.fromPartId(partId);
    final now = FieldValue.serverTimestamp();
    final writer = _BatchWriter(_firestore);
    await writer.set(
      _partProgress.doc(_partDocId(uid, part.partId)),
      {
        ..._placement(uid, part),
        'status': AnalyticsConstants.statusCompleted,
        'locked': true,
        'completedAt': now,
        'updatedAt': now,
      },
      merge: true,
    );
    await writer.set(
      _userProgress.doc(uid),
      _userProgressPayload(uid, completedIds, now),
      merge: true,
    );
    await writer.flush();
    final cached = Map<String, dynamic>.from(_partDocs[partId] ?? {});
    cached['status'] = AnalyticsConstants.statusCompleted;
    cached['locked'] = true;
    cached.addAll(_placement(uid, part));
    _rememberPart(
      partId: part.partId,
      data: cached,
      result: peekStoredState(partId).result,
    );
  }

  Future<void> _record({
    required AssessmentPartContext part,
    required int attemptNumber,
    required DateTime startedAt,
    required DateTime endedAt,
    required String language,
    required String region,
    required String outcome,
    PronunciationResult? result,
    String twinTip = '',
    String errorMessage = '',
  }) async {
    final uid = _uid;
    if (uid.isEmpty) {
      log('analytics skip: no signed-in uid');
      return;
    }
    log(
      'analytics record ${part.partId} outcome=$outcome '
      'auth=${_auth.currentUser != null}',
    );

    final attemptRef = _attempts.doc();
    final attemptId = attemptRef.id;
    final band = result == null ? '' : _bandName(result.band);
    final scored = outcome == AnalyticsConstants.outcomeScored;
    final feedbackLevel = FeedbackTier.fromOverall(
      scored: scored,
      pronScore: result?.pronScore,
      recognitionStatus: result?.recognitionStatus,
    );
    final lists = _WordLists.from(result);
    final counts = _WordCounts.from(result);
    final previous = await _readPartProgress(uid, part.partId);
    final progressPayload = _partProgressPayload(
      uid: uid,
      part: part,
      attemptId: attemptId,
      attemptNumber: attemptNumber,
      band: band,
      pronScore: result?.pronScore,
      feedbackLabel: FeedbackTier.labelOf(feedbackLevel),
      previous: previous,
      scored: scored,
    );

    await _commitOne(attemptRef, {
      ..._placement(uid, part),
      'attemptId': attemptId,
      'referenceText': _clip(part.referenceText, 8000),
      'referenceIpa': _clip(part.referenceIpa ?? '', 400),
      'attemptNumber': attemptNumber,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': Timestamp.fromDate(endedAt),
      'durationMs': endedAt.difference(startedAt).inMilliseconds,
      'outcome': outcome,
      'band': band,
      'feedbackLevel': feedbackLevel,
      'feedbackLabel': FeedbackTier.labelOf(feedbackLevel),
      'twinTip': _clip(twinTip, 2000),
      'heardText': _clip(result?.heardText ?? '', 8000),
      'recognitionStatus': _clip(result?.recognitionStatus ?? '', 64),
      'pronScore': result?.pronScore,
      'accuracyScore': result?.accuracyScore,
      'fluencyScore': result?.fluencyScore,
      'completenessScore': result?.completenessScore,
      'prosodyScore': result?.prosodyScore,
      'httpStatus': result?.httpStatus,
      'language': _clip(language, 16),
      'region': _clip(region, 64),
      'engine': AnalyticsConstants.engineAzureSpeech,
      'wordExcellentCount': counts.excellent,
      'wordNeedsImprovCount': counts.needsImprov,
      'wordIncorrectCount': counts.incorrect,
      'wordOmissionCount': counts.omission,
      'wordInsertionCount': counts.insertion,
      'correctWords': _clip(lists.correct, 8000),
      'needsImprovWords': _clip(lists.needsImprov, 8000),
      'incorrectWords': _clip(lists.incorrect, 8000),
      'phonemeExcellentCount': counts.phonemeExcellent,
      'phonemeNeedsImprovCount': counts.phonemeNeedsImprov,
      'phonemeIncorrectCount': counts.phonemeIncorrect,
      'weakestWord': _clip(result?.weakestWord ?? '', 160),
      'weakestPhoneme': _clip(result?.weakestPhoneme ?? '', 64),
      'heardPhoneme': _clip(result?.heardPhoneme ?? '', 64),
      'errorMessage': _clip(errorMessage, 200),
      'createdAt': FieldValue.serverTimestamp(),
    }, label: 'attempt');
    _rememberPart(
      partId: part.partId,
      data: progressPayload,
      result: scored ? result : peekStoredState(part.partId).result,
    );
    try {
      await _commitOne(
        _partProgress.doc(_partDocId(uid, part.partId)),
        progressPayload,
        merge: true,
        label: 'part_progress',
      );
    } catch (_) {}
    try {
      await _commitOne(
        _userProgress.doc(uid),
        {
          ..._identity(uid),
          'lastAttemptAt': Timestamp.fromDate(endedAt),
          'lastPartId': part.partId,
          'lastBand': band,
          'lastFeedbackLabel': FeedbackTier.labelOf(feedbackLevel),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        merge: true,
        label: 'user_progress',
      );
    } catch (_) {}

    if (result != null) {
      try {
        final details = _BatchWriter(_firestore);
        await _writeWords(
          details,
          uid,
          part,
          attemptId,
          attemptNumber,
          result,
        );
        await details.flush();
      } catch (error, stack) {
        log('analytics details: $error', stackTrace: stack);
      }
    }
  }

  Future<void> _writeWords(
    _BatchWriter writer,
    String uid,
    AssessmentPartContext part,
    String attemptId,
    int attemptNumber,
    PronunciationResult result,
  ) async {
    for (var wordIndex = 0; wordIndex < result.words.length; wordIndex++) {
      final word = result.words[wordIndex];
      final wordBand = _bandName(word.band);
      await writer.set(_attemptWords.doc(), {
        ..._placement(uid, part),
        'attemptId': attemptId,
        'attemptNumber': attemptNumber,
        'wordIndex': wordIndex,
        'expectedWord': _clip(word.word, 160),
        'errorType': _clip(word.errorType, 64),
        'accuracy': word.accuracy,
        'band': wordBand,
        'color': FeedbackTier.wordColor(wordBand),
        'isExcellent': wordBand == AnalyticsConstants.bandExcellent,
        'isNeedsImprov': wordBand == AnalyticsConstants.bandNeedsImprov,
        'isIncorrect': wordBand == AnalyticsConstants.bandIncorrect,
        'createdAt': FieldValue.serverTimestamp(),
      });
      for (var phonemeIndex = 0;
          phonemeIndex < word.phonemes.length;
          phonemeIndex++) {
        final phoneme = word.phonemes[phonemeIndex];
        if (phoneme.phoneme.isEmpty) continue;
        final phonemeBand = _bandName(phoneme.band);
        await writer.set(_attemptPhonemes.doc(), {
          ..._placement(uid, part),
          'attemptId': attemptId,
          'attemptNumber': attemptNumber,
          'wordIndex': wordIndex,
          'expectedWord': _clip(word.word, 160),
          'phonemeIndex': phonemeIndex,
          'expectedPhoneme': _clip(phoneme.phoneme, 64),
          'heardPhoneme': _clip(phoneme.heardPhoneme ?? '', 64),
          'accuracy': phoneme.accuracy,
          'band': phonemeBand,
          'color': FeedbackTier.wordColor(phonemeBand),
          'isMismatch': phoneme.hasWrongSound,
          'nBest1': _clip(phoneme.nBest.elementAtOrNull(0)?.phoneme ?? '', 64),
          'nBest1Score': phoneme.nBest.elementAtOrNull(0)?.accuracy,
          'nBest2': _clip(phoneme.nBest.elementAtOrNull(1)?.phoneme ?? '', 64),
          'nBest2Score': phoneme.nBest.elementAtOrNull(1)?.accuracy,
          'nBest3': _clip(phoneme.nBest.elementAtOrNull(2)?.phoneme ?? '', 64),
          'nBest3Score': phoneme.nBest.elementAtOrNull(2)?.accuracy,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Map<String, dynamic> _partProgressPayload({
    required String uid,
    required AssessmentPartContext part,
    required String attemptId,
    required int attemptNumber,
    required String band,
    required double? pronScore,
    required String feedbackLabel,
    required Map<String, dynamic>? previous,
    required bool scored,
  }) {
    final alreadyCompleted =
        previous?['status'] == AnalyticsConstants.statusCompleted;
    final previousBestScore = _asDouble(previous?['bestPronScore']);
    final previousBestBand = previous?['bestBand'] as String? ?? '';
    final locked = alreadyCompleted ||
        (scored &&
            (band == AnalyticsConstants.bandExcellent ||
                attemptNumber >= PronunciationConstants.maxAttempts));
    final isBest = scored &&
        _isBetter(
          band: band,
          score: pronScore,
          previousBand: previousBestBand,
          previousScore: previousBestScore,
        );
    return {
      ..._placement(uid, part),
      'status': locked
          ? AnalyticsConstants.statusCompleted
          : AnalyticsConstants.statusInProgress,
      'locked': locked,
      'latestFeedbackLabel': feedbackLabel,
      'attemptCount': attemptNumber,
      'maxAttempts': PronunciationConstants.maxAttempts,
      'latestAttemptId': attemptId,
      'latestBand': band,
      'latestPronScore': pronScore,
      'bestAttemptId': isBest ? attemptId : previous?['bestAttemptId'],
      'bestBand': isBest ? band : previousBestBand,
      'bestPronScore': isBest ? pronScore : previousBestScore,
      'firstAttemptAt': previous?['firstAttemptAt'] ?? FieldValue.serverTimestamp(),
      'lastAttemptAt': FieldValue.serverTimestamp(),
      if (locked) 'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _userProgressPayload(
    String uid,
    Set<String> completedIds,
    FieldValue now,
  ) {
    final snapshot = CourseProgressSnapshot(completedIds: completedIds);
    return {
      ..._identity(uid),
      'overallPercent': snapshot.overallProgress * 100,
      'overallScore5': snapshot.overallProgress * 5,
      'partsCompletedCount': completedIds.length,
      'partsTotalCount': CourseProgressIds.all().length,
      'module1Percent': snapshot.moduleProgress(1) * 100,
      'module2Percent': snapshot.moduleProgress(2) * 100,
      'module3Percent': snapshot.moduleProgress(3) * 100,
      'updatedAt': now,
    };
  }

  Map<String, dynamic> _placement(String uid, AssessmentPartContext part) {
    return {
      ..._identity(uid),
      'moduleNumber': part.moduleNumber,
      'moduleTitle': part.moduleTitle,
      'sessionNumber': part.sessionNumber,
      'sessionTitle': part.sessionTitle,
      'partId': part.partId,
      'partType': part.partType,
      'partLabel': _clip(part.partLabel, 160),
      'itemKind': part.itemKind,
      'itemName': _clip(part.itemName, 160),
    };
  }

  Map<String, String> _identity(String uid) {
    return {
      'uid': uid,
      'userName': _clip(_prefs.getUserName(), 64),
      'fullName': _clip(_prefs.getFullName(), 120),
    };
  }

  Future<void> _commitOne(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data, {
    bool merge = false,
    required String label,
  }) async {
    final writer = _BatchWriter(_firestore);
    await writer.set(ref, data, merge: merge);
    try {
      await writer.flush();
    } catch (error, stack) {
      log('analytics $label: $error', stackTrace: stack);
      rethrow;
    }
  }

  String _clip(String value, int max) {
    final text = value.trim();
    if (text.length <= max) return text;
    return text.substring(0, max);
  }

  String _partDocId(String uid, String partId) => '${uid}__$partId';

  String _bandName(PronunciationBand band) {
    switch (band) {
      case PronunciationBand.excellent:
        return AnalyticsConstants.bandExcellent;
      case PronunciationBand.needsImprov:
        return AnalyticsConstants.bandNeedsImprov;
      case PronunciationBand.incorrect:
        return AnalyticsConstants.bandIncorrect;
    }
  }

  bool _isBetter({
    required String band,
    required double? score,
    required String previousBand,
    required double? previousScore,
  }) {
    final rank = _bandRank(band);
    final previousRank = _bandRank(previousBand);
    if (rank > previousRank) return true;
    if (rank < previousRank) return false;
    return (score ?? 0) >= (previousScore ?? 0);
  }

  int _bandRank(String band) {
    switch (band) {
      case AnalyticsConstants.bandExcellent:
        return 3;
      case AnalyticsConstants.bandNeedsImprov:
        return 2;
      case AnalyticsConstants.bandIncorrect:
        return 1;
      default:
        return 0;
    }
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }
}

class _WordLists {
  const _WordLists({
    required this.correct,
    required this.needsImprov,
    required this.incorrect,
  });

  final String correct;
  final String needsImprov;
  final String incorrect;

  factory _WordLists.from(PronunciationResult? result) {
    if (result == null) {
      return const _WordLists(correct: '', needsImprov: '', incorrect: '');
    }
    final excellent = <String>[];
    final needs = <String>[];
    final wrong = <String>[];
    for (final word in result.words) {
      if (word.word.trim().isEmpty) continue;
      switch (word.band) {
        case PronunciationBand.excellent:
          excellent.add(word.word);
        case PronunciationBand.needsImprov:
          needs.add(word.word);
        case PronunciationBand.incorrect:
          wrong.add(word.word);
      }
    }
    return _WordLists(
      correct: excellent.join(', '),
      needsImprov: needs.join(', '),
      incorrect: wrong.join(', '),
    );
  }
}

class _WordCounts {
  const _WordCounts({
    required this.excellent,
    required this.needsImprov,
    required this.incorrect,
    required this.omission,
    required this.insertion,
    required this.phonemeExcellent,
    required this.phonemeNeedsImprov,
    required this.phonemeIncorrect,
  });

  final int excellent;
  final int needsImprov;
  final int incorrect;
  final int omission;
  final int insertion;
  final int phonemeExcellent;
  final int phonemeNeedsImprov;
  final int phonemeIncorrect;

  factory _WordCounts.from(PronunciationResult? result) {
    if (result == null) {
      return const _WordCounts(
        excellent: 0,
        needsImprov: 0,
        incorrect: 0,
        omission: 0,
        insertion: 0,
        phonemeExcellent: 0,
        phonemeNeedsImprov: 0,
        phonemeIncorrect: 0,
      );
    }
    var excellent = 0;
    var needsImprov = 0;
    var incorrect = 0;
    var omission = 0;
    var insertion = 0;
    var phonemeExcellent = 0;
    var phonemeNeedsImprov = 0;
    var phonemeIncorrect = 0;
    for (final word in result.words) {
      if (word.isOmission) omission++;
      if (word.isInsertion) insertion++;
      switch (word.band) {
        case PronunciationBand.excellent:
          excellent++;
        case PronunciationBand.needsImprov:
          needsImprov++;
        case PronunciationBand.incorrect:
          incorrect++;
      }
      for (final phoneme in word.phonemes) {
        if (phoneme.phoneme.isEmpty) continue;
        switch (phoneme.band) {
          case PronunciationBand.excellent:
            phonemeExcellent++;
          case PronunciationBand.needsImprov:
            phonemeNeedsImprov++;
          case PronunciationBand.incorrect:
            phonemeIncorrect++;
        }
      }
    }
    return _WordCounts(
      excellent: excellent,
      needsImprov: needsImprov,
      incorrect: incorrect,
      omission: omission,
      insertion: insertion,
      phonemeExcellent: phonemeExcellent,
      phonemeNeedsImprov: phonemeNeedsImprov,
      phonemeIncorrect: phonemeIncorrect,
    );
  }
}

class _BatchWriter {
  _BatchWriter(this._db) : _batch = _db.batch();

  final FirebaseFirestore _db;
  WriteBatch _batch;
  var _count = 0;

  Future<void> set(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    final compact = Map<String, dynamic>.fromEntries(
      data.entries.where((entry) => entry.value != null),
    );
    if (merge) {
      _batch.set(ref, compact, SetOptions(merge: true));
    } else {
      _batch.set(ref, compact);
    }
    _count++;
    if (_count >= AnalyticsConstants.batchLimit) {
      await flush();
    }
  }

  Future<void> flush() async {
    if (_count == 0) return;
    try {
      await _batch.commit().timeout(AnalyticsConstants.writeTimeout);
    } catch (error, stack) {
      log('analytics batch: $error', stackTrace: stack);
      rethrow;
    } finally {
      _batch = _db.batch();
      _count = 0;
    }
  }
}
