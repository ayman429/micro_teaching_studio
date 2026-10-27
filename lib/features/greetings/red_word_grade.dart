import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

enum RedWordGrade { excellent, needsImprovement, retry }

class RedWordVerdict {
  const RedWordVerdict({
    required this.grade,
    required this.matched,
    required this.total,
  });

  final RedWordGrade grade;
  final int matched;
  final int total;

  bool get accepted => grade != RedWordGrade.retry;
}

class _Span {
  const _Span({required this.next, required this.correct});

  final int next;
  final bool correct;
}

RedWordVerdict gradeRedWords({
  required List<String> redWords,
  required List<PronunciationWordScore> words,
}) {
  var index = 0;
  var matched = 0;
  for (final red in redWords) {
    var found = false;
    while (index < words.length) {
      final span = _matchAt(red, words, index);
      if (span == null) {
        index++;
        continue;
      }
      index = span.next;
      if (span.correct) matched++;
      found = true;
      break;
    }
    if (!found) break;
  }
  return RedWordVerdict(
    grade: _grade(matched, redWords.length),
    matched: matched,
    total: redWords.length,
  );
}

RedWordGrade _grade(int matched, int total) {
  if (total <= 0) return RedWordGrade.retry;
  if (matched == total) return RedWordGrade.excellent;
  if (matched <= 1 || matched * 2 < total) return RedWordGrade.retry;
  return RedWordGrade.needsImprovement;
}

_Span? _matchAt(String red, List<PronunciationWordScore> words, int index) {
  if (index >= words.length) return null;
  final word = words[index];
  if (word.isInsertion) return null;
  final want = _token(red);
  if (_same(want, word)) {
    return _Span(next: index + 1, correct: _correct(word));
  }
  final next = _nextSpoken(words, index + 1);
  if (next == null) return null;
  final second = words[next];
  final heard = _token(word.word);
  if (want == 'im' &&
      heard == 'i' &&
      (_token(second.word) == 'am' || _token(second.word) == 'm')) {
    return _Span(
      next: next + 1,
      correct: _correct(word) && _correct(second),
    );
  }
  if (want == 'its' && heard == 'it' && _token(second.word) == 'is') {
    return _Span(
      next: next + 1,
      correct: _correct(word) && _correct(second),
    );
  }
  return null;
}

int? _nextSpoken(List<PronunciationWordScore> words, int start) {
  for (var index = start; index < words.length; index++) {
    if (!words[index].isInsertion) return index;
  }
  return null;
}

bool _correct(PronunciationWordScore word) {
  if (word.isInsertion || word.isOmission) return false;
  if (word.errorType.toLowerCase() != 'none') return false;
  return (word.accuracy ?? 0) >= PronunciationConstants.excellentMin;
}

bool _same(String want, PronunciationWordScore word) {
  final heard = _token(word.word);
  if (heard == want) return true;
  final possessive = word.word.contains("'") && heard == '${want}s';
  return possessive;
}

String _token(String value) {
  var text = value.toLowerCase().replaceAll('behaviour', 'behavior');
  text = text.replaceAll(RegExp("[^a-z0-9']"), '');
  return text.replaceAll("'", '');
}
