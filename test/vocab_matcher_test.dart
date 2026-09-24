import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/vocabulary/vocab_script.dart';

void main() {
  test('teaching stages need meaning, definition, and a concept check', () {
    expect(
      matchesTeachingStages(
        'The three stages are explaining meaning, giving the definition, and a concept check.',
      ),
      isTrue,
    );
    expect(
      matchesTeachingStages('He explained the meaning and the definition'),
      isFalse,
    );
  });

  test('monument explanation needs the picture and a historic structure', () {
    expect(
      matchesMonumentExplanation(
        'He showed a picture and said a monument is a huge special ancient Egyptian structure.',
      ),
      isTrue,
    );
    expect(
      matchesMonumentExplanation('A monument is a building'),
      isFalse,
    );
  });

  test('student question is about a big stone mall', () {
    expect(
      matchesStudentMallQuestion(
        'Is the big stone shopping mall next to my house a monument?',
      ),
      isTrue,
    );
    expect(matchesStudentMallQuestion('Is the pyramid a monument?'), isFalse);
  });

  test('teacher reply thanks the student and mentions the pyramids', () {
    expect(
      matchesTeacherReply(
        'The teacher thanked him and said the pyramids were built by the pharaohs.',
      ),
      isTrue,
    );
    expect(matchesTeacherReply('The mall is very big'), isFalse);
  });

  test('magnificent explanation includes the board drawing', () {
    expect(
      matchesMagnificentExplanation(
        'Magnificent means very beautiful and grand, then he drew a stick figure on the board.',
      ),
      isTrue,
    );
    expect(
      matchesMagnificentExplanation('Magnificent means beautiful and grand'),
      isFalse,
    );
  });

  test('mask question names the mask and why students said yes', () {
    expect(
      matchesMaskQuestion(
        'They looked at the golden mask of Tutankhamun and said yes because it is beautiful and shiny.',
      ),
      isTrue,
    );
    expect(matchesMaskQuestion('The students said yes'), isFalse);
  });

  test('quiz blanks accept magnificent and monument or monuments', () {
    expect(matchesMagnificentBlank('Magnificent'), isTrue);
    expect(matchesMagnificentBlank('a magnificent view'), isTrue);
    expect(matchesMagnificentBlank('heritage'), isFalse);
    expect(matchesMonumentBlank('monument'), isTrue);
    expect(matchesMonumentBlank('monuments'), isTrue);
    expect(matchesMonumentBlank('pyramid'), isFalse);
  });
}
