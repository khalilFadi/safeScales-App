import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_scales/themes/app_theme.dart';
import 'package:safe_scales/ui/widgets/lesson_activity_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('active activity shows icon and chevron, not lock or check', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LessonActivityCard(
          title: 'Reading',
          description: 'Learn about Social Media Norms',
          icon: FontAwesomeIcons.fileLines,
          status: LessonActivityStatus.active,
          onTap: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('activity-icon-Reading')), findsOneWidget);
    expect(find.byKey(const Key('activity-chevron-Reading')), findsOneWidget);
    expect(find.byKey(const Key('activity-check-Reading')), findsNothing);
    expect(find.byKey(const Key('activity-lock-Reading')), findsNothing);
  });

  testWidgets('completed activity uses check icon and pale green background', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LessonActivityCard(
          title: 'Reading',
          description: 'Learn about Social Media Norms',
          icon: FontAwesomeIcons.fileLines,
          status: LessonActivityStatus.completed,
          onTap: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('activity-check-Reading')), findsOneWidget);
    expect(find.byKey(const Key('activity-icon-Reading')), findsNothing);
    expect(find.byKey(const Key('activity-lock-Reading')), findsNothing);

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(LessonActivityCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.paleGreen);
  });

  testWidgets('locked activity shows lock instead of chevron', (tester) async {
    await tester.pumpWidget(
      _wrap(
        LessonActivityCard(
          title: 'Quiz',
          description: 'Test what you\'ve learned',
          icon: FontAwesomeIcons.penRuler,
          status: LessonActivityStatus.locked,
          onTap: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('activity-lock-Quiz')), findsOneWidget);
    expect(find.byKey(const Key('activity-chevron-Quiz')), findsNothing);
    expect(find.byKey(const Key('activity-check-Quiz')), findsNothing);
  });
}
