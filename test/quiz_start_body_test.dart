import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_scales/models/question.dart';
import 'package:safe_scales/ui/widgets/quiz_start_body.dart';

Question _question(int index) {
  return Question.singleAnswer(
    id: 'q$index',
    questionText: 'Question $index',
    options: const ['A', 'B'],
    correctAnswerIndex: 0,
    explanation: 'Because',
  );
}

QuestionSet _set({
  required String title,
  required ActivityType activityType,
  int passingScore = 80,
}) {
  return QuestionSet(
    id: 'set-1',
    title: title,
    description: 'Description',
    activityType: activityType,
    subject: 'Social Media',
    passingScore: passingScore,
    questions: List<Question>.generate(10, _question),
  );
}

Widget _app({
  required QuestionSet questionSet,
  required Size size,
  double textScale = 1.0,
  bool showTableOfContentsHint = true,
}) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2E83E8)),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 18),
        bodySmall: TextStyle(fontSize: 15),
        labelMedium: TextStyle(fontSize: 15),
      ),
    ),
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: QuizStartBody(
          questionSet: questionSet,
          onStart: () {},
          showTableOfContentsHint: showTableOfContentsHint,
        ),
      ),
    ),
  );
}

void main() {
  test('required correct answers rounds 80% of 10 to 8', () {
    expect(
      QuizStartBody.requiredCorrectAnswers(
        passingScorePercent: 80,
        totalQuestions: 10,
      ),
      8,
    );
  });

  testWidgets('Details header stays larger than Details body text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        questionSet: _set(
          title: 'Social Media Norms Post-Quiz',
          activityType: ActivityType.postQuiz,
        ),
        size: const Size(390, 844),
      ),
    );

    final Text header = tester.widget<Text>(
      find.byKey(const Key('quiz-start-details-header')),
    );
    final DefaultTextStyle body = tester.widget<DefaultTextStyle>(
      find.byKey(const Key('quiz-start-details-body')),
    );

    expect(header.style?.fontSize, 18);
    expect(body.style.fontSize, QuizStartBody.detailsBodyFontSize);
    expect(header.style!.fontSize! > body.style.fontSize!, isTrue);
  });

  testWidgets('short iPhone-sized viewport keeps START visible', (
    WidgetTester tester,
  ) async {
    // Short height + large text scale mimics iPhone 14 overflow.
    await tester.binding.setSurfaceSize(const Size(390, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _app(
        questionSet: _set(
          title: 'Social Media Norms Post-Quiz',
          activityType: ActivityType.postQuiz,
        ),
        size: const Size(390, 520),
        textScale: 1.4,
      ),
    );

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('To Pass this Quiz'), findsOneWidget);
    expect(find.text('START').hitTestable(), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(
        'You can use the audio feature to listen to the question instead of reading.',
      ),
      80,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('START').hitTestable(), findsOneWidget);
  });

  testWidgets('pre-quiz intro omits passing card and table-of-contents hint', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        questionSet: _set(
          title: 'Social Media Norms Quiz',
          activityType: ActivityType.preQuiz,
          passingScore: 0,
        ),
        size: const Size(390, 844),
        showTableOfContentsHint: false,
      ),
    );

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('To Pass this Quiz'), findsNothing);
    expect(
      find.text(
        'You can use the table of contents to return to previous questions',
      ),
      findsNothing,
    );
    expect(
      find.text(
        'You can use the audio feature to listen to the question instead of reading.',
      ),
      findsOneWidget,
    );
    expect(find.text('START'), findsOneWidget);
  });
}
