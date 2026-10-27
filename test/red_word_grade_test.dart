import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/classroom/classroom_script.dart';
import 'package:micro_teaching_studio/features/grammar/grammar_script.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_script.dart';
import 'package:micro_teaching_studio/features/greetings/red_word_grade.dart';
import 'package:micro_teaching_studio/features/presentation/presentation_script.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/vocabulary/vocab_script.dart';

void main() {
  test('a fully correct reference is excellent for every chat answer', () {
    final spoken = <(String, String, List<String>)>[
      for (final question in GreetingsScript.questions)
        (question.partId, question.referenceText, question.redWords),
      for (final question in ClassroomScript.plan.questions)
        (question.partId, question.referenceText, question.redWords),
      for (final question in GrammarScript.plan.questions)
        (question.partId, question.referenceText, question.redWords),
      for (final question in PresentationScript.plan.questions)
        (question.partId, question.referenceText, question.redWords),
      for (final turn in VocabScript.questions)
        (turn.partId, turn.referenceText, turn.redWords),
    ];
    for (final question in spoken) {
      final verdict = gradeRedWords(
        redWords: question.$3,
        words: _spoken(question.$2),
      );
      expect(
        verdict.grade,
        RedWordGrade.excellent,
        reason:
            '${question.$1} matched ${verdict.matched}/${verdict.total}',
      );
    }
  });

  test('two red words need both, and a similar word does not count', () {
    final red = GreetingsScript.questions.first.redWords;
    expect(
      gradeRedWords(
        redWords: red,
        words: _spoken('Yes, students are making a lot of noise.'),
      ).grade,
      RedWordGrade.excellent,
    );
    final similar = _spoken('Yes, students are making a lot of noise.');
    final noise = similar.lastIndexWhere((word) => word.word == 'noise');
    similar[noise] = PronunciationWordScore(
      word: 'noise',
      accuracy: 40,
      errorType: 'Mispronunciation',
    );
    final missed = gradeRedWords(redWords: red, words: similar);
    expect(missed.matched, 1);
    expect(missed.grade, RedWordGrade.retry);

    final soft = _spoken('Yes, students are making a lot of noise.');
    final making = soft.indexWhere((word) => word.word == 'making');
    soft[making] = const PronunciationWordScore(
      word: 'making',
      accuracy: 80,
      errorType: 'None',
    );
    expect(
      gradeRedWords(redWords: red, words: soft).grade,
      RedWordGrade.excellent,
    );
    soft[making] = const PronunciationWordScore(
      word: 'making',
      accuracy: 79,
      errorType: 'None',
    );
    expect(
      gradeRedWords(redWords: red, words: soft).grade,
      RedWordGrade.retry,
    );
  });

  test('more than half of a longer answer still earns the point path', () {
    final red = GreetingsScript.questions[1].redWords;
    final words = [
      for (final word in red)
        PronunciationWordScore(word: word, accuracy: 95, errorType: 'None'),
    ];
    for (var index = 6; index < words.length; index++) {
      words[index] = PronunciationWordScore(
        word: words[index].word,
        accuracy: 40,
        errorType: 'Mispronunciation',
      );
    }
    final verdict = gradeRedWords(redWords: red, words: words);
    expect(verdict.total, 10);
    expect(verdict.matched, 6);
    expect(verdict.grade, RedWordGrade.needsImprovement);
    expect(verdict.accepted, isTrue);

    for (var index = 4; index < 6; index++) {
      words[index] = PronunciationWordScore(
        word: words[index].word,
        accuracy: 40,
        errorType: 'Mispronunciation',
      );
    }
    final short = gradeRedWords(redWords: red, words: words);
    expect(short.matched, 4);
    expect(short.grade, RedWordGrade.retry);
  });

  test('I am counts as the red word I am jumping', () {
    final verdict = gradeRedWords(
      redWords: const ['jump', 'and', 'say', "i'm", 'jumping'],
      words: _spoken('He asked students to jump and say I am jumping'),
    );
    expect(verdict.grade, RedWordGrade.excellent);
  });
}

List<PronunciationWordScore> _spoken(String reference) {
  return [
    for (final part in reference.split(RegExp("[^A-Za-z0-9']+")))
      if (part.isNotEmpty)
        PronunciationWordScore(
          word: part,
          accuracy: 95,
          errorType: 'None',
        ),
  ];
}
