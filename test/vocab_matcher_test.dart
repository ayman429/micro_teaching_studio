import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/vocabulary/vocab_script.dart';

void main() {
  test('quiz blanks accept magnificent and monument or monuments', () {
    expect(matchesMagnificentBlank('Magnificent'), isTrue);
    expect(matchesMagnificentBlank('a magnificent view'), isTrue);
    expect(matchesMagnificentBlank('heritage'), isFalse);
    expect(matchesMonumentBlank('monument'), isTrue);
    expect(matchesMonumentBlank('monuments'), isTrue);
    expect(matchesMonumentBlank('pyramid'), isFalse);
  });
}
