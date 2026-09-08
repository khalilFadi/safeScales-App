import 'package:flutter_test/flutter_test.dart';
import 'package:safe_scales/models/lesson_progress.dart';
import 'package:safe_scales/models/question.dart';

QuizAttempt _attempt({
  required ActivityType type,
  required int correctAnswers,
}) {
  return QuizAttempt(
    id: 'a',
    quizId: 'q',
    lessonId: 'l1',
    type: type,
    correctAnswers: correctAnswers,
    totalQuestions: 10,
    responses: const [],
    startedAt: DateTime(2026, 1, 1),
    completedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('completedActivityCount tracks pre-quiz, reading, and post-quiz', () {
    final progress = LessonProgress(
      lessonId: 'l1',
      isReadingComplete: false,
      bookmarks: {},
      requiredPassingScore: 70,
      postQuizAttempts: [],
    );

    expect(progress.completedActivityCount, 0);
    expect(progress.areAllActivitiesComplete, isFalse);

    progress.preQuizAttempt = _attempt(
      type: ActivityType.preQuiz,
      correctAnswers: 5,
    );
    expect(progress.completedActivityCount, 1);

    progress.isReadingComplete = true;
    expect(progress.completedActivityCount, 2);
    expect(progress.areAllActivitiesComplete, isFalse);

    progress.postQuizAttempts.add(
      _attempt(type: ActivityType.postQuiz, correctAnswers: 9),
    );
    expect(progress.completedActivityCount, 3);
    expect(progress.areAllActivitiesComplete, isTrue);
  });

  test('failing post-quiz does not mark the quiz activity complete', () {
    final progress = LessonProgress(
      lessonId: 'l1',
      isReadingComplete: true,
      bookmarks: {},
      requiredPassingScore: 70,
      postQuizAttempts: [
        _attempt(type: ActivityType.postQuiz, correctAnswers: 5),
      ],
      preQuizAttempt: _attempt(type: ActivityType.preQuiz, correctAnswers: 4),
    );

    expect(progress.isPostQuizComplete(), isFalse);
    expect(progress.completedActivityCount, 2);
    expect(progress.areAllActivitiesComplete, isFalse);
  });
}
