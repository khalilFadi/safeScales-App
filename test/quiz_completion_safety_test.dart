import 'package:flutter_test/flutter_test.dart';
import 'package:safe_scales/models/lesson_progress.dart';
import 'package:safe_scales/models/question.dart';
import 'package:safe_scales/utils/safe_data.dart';

void main() {
  group('safe_data quiz completion helpers', () {
    test('asInt accepts int, double, and numeric strings', () {
      expect(asInt(3), 3);
      expect(asInt(4.0), 4);
      expect(asInt('5'), 5);
      expect(asInt('6.2'), 6);
      expect(asInt(null, fallback: 7), 7);
      expect(asInt(double.infinity, fallback: 0), 0);
    });

    test('parseQuestionResponses handles JSONB, strings, and mixed numbers', () {
      expect(
        parseQuestionResponses([
          [0],
          [1.0, 2],
        ]),
        [
          [0],
          [1, 2],
        ],
      );
      expect(parseQuestionResponses('[[0],[1]]'), [
        [0],
        [1],
      ]);
      expect(parseQuestionResponses(null), isEmpty);
      expect(parseQuestionResponses({'0': 1}), isEmpty);
    });

    test('parseDateTime accepts ISO strings and DateTime objects', () {
      final now = DateTime.utc(2026, 9, 8);
      expect(parseDateTime(now), now);
      expect(parseDateTime('2026-09-08T00:00:00.000Z').toUtc(), now);
      expect(parseDateTime(null), isA<DateTime>());
    });

    test('joinSelectedOptions does not throw on out-of-range indices', () {
      expect(joinSelectedOptions(['A', 'B'], [0, 9]), 'A, Unknown option');
      expect(joinSelectedOptions(['A'], []), 'Not answered');
    });

    test('normalizeUserDragonRecord upgrades legacy phase lists', () {
      final fromList = normalizeUserDragonRecord(['egg', 'stage1']);
      expect(fromList['phases'], ['egg', 'stage1']);
      expect(fromList['name'], 'no name');

      final fromMap = normalizeUserDragonRecord({
        'name': 'Spark',
        'phases': ['egg'],
      });
      expect(fromMap['name'], 'Spark');
      expect(fromMap['phases'], ['egg']);

      final fromNull = normalizeUserDragonRecord(null);
      expect(fromNull['phases'], ['egg']);
    });

    test('safeScorePercent never divides by zero', () {
      expect(safeScorePercent(0, 0), 0);
      expect(safeScorePercent(3, 4), 75);
    });
  });

  group('QuizAttempt.score', () {
    test('returns 0 when totalQuestions is 0', () {
      final attempt = QuizAttempt(
        id: '1',
        quizId: 'lesson_preQuiz',
        lessonId: 'lesson',
        type: ActivityType.preQuiz,
        correctAnswers: 0,
        totalQuestions: 0,
        responses: const [],
        startedAt: DateTime(2026, 1, 1),
        completedAt: DateTime(2026, 1, 1),
      );
      expect(attempt.score, 0);
    });
  });
}
